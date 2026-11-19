import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.tree.ModifiersTree;
import com.sun.source.tree.ParenthesizedTree;
import com.sun.source.tree.Tree;
import com.sun.source.util.JavacTask;

import javax.lang.model.element.Modifier;
import javax.lang.model.element.Name;
import javax.tools.Diagnostic;
import javax.tools.DiagnosticCollector;
import javax.tools.JavaCompiler;
import javax.tools.JavaFileObject;
import javax.tools.SimpleJavaFileObject;
import javax.tools.StandardJavaFileManager;
import javax.tools.ToolProvider;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.net.InetSocketAddress;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Answers, for a Java source and a release, whether javac's parser accepts it and, when it
 * does, a dump of its tree that two sources share exactly when they mean the same program.
 *
 * <p>Only the parse phase runs: no attribution, so a source is judged on its syntax and on
 * what the parser itself checks at that release. The dump walks the public
 * {@code com.sun.source.tree} API, so it follows new node kinds without change. It skips
 * parenthesized expressions, positions and comments, and javac is told not to fold adjacent
 * string literals, which it otherwise does while parsing.
 *
 * <pre>
 * java --add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED JavacOracle.java [port]
 * POST /check?release=25   body: the source   answer: "ok\n" + dump, or "error\n" + diagnostics
 * GET  /version            the javac version
 * GET  /quit               stops the server
 * </pre>
 */
public final class JavacOracle {

    private static final JavaCompiler COMPILER = ToolProvider.getSystemJavaCompiler();
    private static final StandardJavaFileManager FILES =
            COMPILER.getStandardFileManager(null, Locale.ROOT, StandardCharsets.UTF_8);
    private static final Map<Class<?>, List<Method>> GETTERS = new ConcurrentHashMap<>();
    private static final Set<String> SKIPPED = Set.of(
            "getKind", "getClass", "hashCode", "toString", "getSourceFile", "getLineMap",
            "getDocComments", "getEndPosTable", "getPackageAnnotations");

    private JavacOracle() {
    }

    public static void main(String[] args) throws IOException {
        int port = args.length > 0 ? Integer.parseInt(args[0]) : 0;
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", port), 0);
        server.createContext("/check", exchange -> {
            String query = exchange.getRequestURI().getQuery();
            String release = query != null && query.startsWith("release=") ? query.substring(8) : null;
            String source = new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
            String answer;
            try {
                answer = check(source, release);
            } catch (RuntimeException e) {
                answer = "error\ncrash: " + e;
            }
            reply(exchange, answer);
        });
        server.createContext("/version", exchange -> reply(exchange, Runtime.version().toString()));
        server.createContext("/quit", exchange -> {
            reply(exchange, "bye");
            server.stop(0);
        });
        server.start();
        System.out.println("JavacOracle listening on " + server.getAddress().getPort());
        System.out.flush();
    }

    private static void reply(HttpExchange exchange, String text) throws IOException {
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", "text/plain; charset=utf-8");
        exchange.sendResponseHeaders(200, bytes.length);
        try (OutputStream out = exchange.getResponseBody()) {
            out.write(bytes);
        }
    }

    static String check(String source, String release) {
        List<String> options = new ArrayList<>(List.of("-proc:none", "-XDallowStringFolding=false", "-Xlint:none",
                "-nowarn"));
        if (release != null && !release.isEmpty()) {
            options.addAll(List.of("--release", release));
        }
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        JavaFileObject file = new SimpleJavaFileObject(URI.create("string:///Probe.java"), JavaFileObject.Kind.SOURCE) {
            @Override
            public CharSequence getCharContent(boolean ignoreEncodingErrors) {
                return source;
            }
        };
        JavacTask task = (JavacTask) COMPILER.getTask(null, FILES, diagnostics, options, null, List.of(file));
        Iterable<? extends CompilationUnitTree> units;
        try {
            units = task.parse();
        } catch (IOException e) {
            return "error\n" + e;
        }
        StringBuilder errors = new StringBuilder();
        for (Diagnostic<? extends JavaFileObject> d : diagnostics.getDiagnostics()) {
            if (d.getKind() == Diagnostic.Kind.ERROR) {
                errors.append(d.getLineNumber()).append(':').append(d.getColumnNumber()).append(' ')
                        .append(d.getCode()).append(' ').append(d.getMessage(Locale.ROOT).replace('\n', ' '))
                        .append('\n');
            }
        }
        if (errors.length() > 0) {
            return "error\n" + errors;
        }
        StringBuilder dump = new StringBuilder();
        for (CompilationUnitTree unit : units) {
            dump(unit, dump, 0);
        }
        return "ok\n" + dump;
    }

    private static void dump(Object value, StringBuilder out, int depth) {
        if (value instanceof ParenthesizedTree p) {
            dump(p.getExpression(), out, depth);
            return;
        }
        if (value instanceof Tree tree) {
            out.append('(').append(tree.getKind());
            if (tree instanceof ModifiersTree) {
                out.append(" flags=").append(internalFlags(tree));
            }
            for (Method getter : getters(tree.getClass())) {
                Object child;
                try {
                    child = getter.invoke(tree);
                } catch (ReflectiveOperationException | RuntimeException e) {
                    continue;
                }
                if (child == null || isEmpty(child)) {
                    continue;
                }
                out.append('\n').append("  ".repeat(depth + 1)).append(getter.getName()).append('=');
                dump(child, out, depth + 1);
            }
            out.append(')');
        } else if (value instanceof Collection<?> items) {
            Collection<?> ordered = items instanceof Set<?> set && !set.isEmpty()
                    && set.iterator().next() instanceof Modifier
                    ? new TreeSet<>(items.stream().map(Object::toString).toList()) : items;
            out.append('[');
            for (Object item : ordered) {
                out.append('\n').append("  ".repeat(depth + 1));
                dump(item, out, depth + 1);
            }
            out.append(']');
        } else if (value instanceof Name || value instanceof CharSequence) {
            out.append('"').append(escape(value.toString())).append('"');
        } else if (value instanceof Character c) {
            out.append("char:").append((int) c.charValue());
        } else if (value instanceof Number || value instanceof Boolean || value instanceof Enum<?>) {
            out.append(value.getClass().getSimpleName()).append(':').append(value);
        } else {
            out.append(value.getClass().getSimpleName());
        }
    }

    private static boolean isEmpty(Object value) {
        return value instanceof Collection<?> c && c.isEmpty();
    }

    private static String escape(String text) {
        StringBuilder out = new StringBuilder();
        for (char c : text.toCharArray()) {
            if (c < 32 || c > 126 || c == '"' || c == '\\') {
                out.append(String.format("\\u%04x", (int) c));
            } else {
                out.append(c);
            }
        }
        return out.toString();
    }

    /** The parser's own flags, which tell a compact constructor from an empty canonical one. */
    private static String internalFlags(Tree modifiers) {
        try {
            return Long.toString(modifiers.getClass().getField("flags").getLong(modifiers));
        } catch (ReflectiveOperationException | RuntimeException e) {
            return "?";
        }
    }

    private static List<Method> getters(Class<?> type) {
        return GETTERS.computeIfAbsent(type, t -> {
            Set<Class<?>> interfaces = new LinkedHashSet<>();
            collectTreeInterfaces(t, interfaces);
            Map<String, Method> byName = new java.util.TreeMap<>();
            for (Class<?> i : interfaces) {
                for (Method m : i.getMethods()) {
                    if (m.getParameterCount() == 0 && !SKIPPED.contains(m.getName())
                            && m.getDeclaringClass().getPackageName().equals("com.sun.source.tree")
                            && !m.getReturnType().equals(Void.TYPE)) {
                        byName.putIfAbsent(m.getName(), m);
                    }
                }
            }
            List<Method> methods = new ArrayList<>(byName.values());
            methods.sort(Comparator.comparing(Method::getName));
            return methods;
        });
    }

    private static void collectTreeInterfaces(Class<?> type, Set<Class<?>> into) {
        for (Class<?> c = type; c != null; c = c.getSuperclass()) {
            for (Class<?> i : c.getInterfaces()) {
                if (i.getPackageName().equals("com.sun.source.tree") && into.add(i)) {
                    collectTreeInterfaces(i, into);
                }
            }
        }
    }

    static {
        // Fail early when run on a JRE without javac.
        if (COMPILER == null) {
            throw new IllegalStateException("No system Java compiler: run JavacOracle with a JDK");
        }
    }
}
