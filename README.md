# Grammar Coverage

Tests a language front end against the grammar of the language itself, not against sample
projects. For Java, it reads the grammar of any edition of the Java Language Specification and
generates Java programs that use every part of it. It asks javac which programs are valid. It
then checks that FAST-Java imports each valid program and keeps what the program means.

The core knows no language. A language adapter gives it a grammar, samples for what the grammar
writes in prose, an oracle that says what is valid, and the system to test.

## How a run works

1. **Grammar.** `GCovJLSReader` reads chapters 3 to 19 of the JLS pages of an edition. It
   caches the pages, then reads each production. Chapter 3 is lexical: identifiers and
   literals are tokens, written without spaces inside them.
2. **Goals.** `GCovGenerator` lists what some sentence must hold:
   - every alternative of every production (Purdom's coverage);
   - every alternative of a production at every place it is used (Laemmel's
     context-dependent coverage);
   - every repetition written 0, 1 and 2 times, and every option taken and left out;
   - every sample of a description in prose, such as a non-ASCII letter;
   - every contextual keyword written as an identifier.
3. **Sentences.** For each goal not yet covered, the generator builds the smallest program
   that holds it. When javac refuses that one, it tries others, cheapest first:
   - the same goal reached through each other place its production is used;
   - one more choice nearby, such as the `sealed` a `permits` clause needs;
   - the goal inside each enclosing construct, such as a switch expression around a `yield`.

   A sentence covers every goal its tree holds, so about 1,200 programs cover the 2,800 goals
   of SE 25.
4. **Oracle.** `javac-oracle/JavacOracle.java` runs javac's parser at the edition's release.
   For each valid program it returns the tree, without parentheses, positions or comments.
   Two programs mean the same exactly when their trees are equal.
5. **Checks.** `GCovFASTJavaTarget` checks every valid program through any importer that
   answers `parse:into:`, the protocol of FAST's `FASTTImporter`. SmaCC's importer is one of
   them. The checks:
   - **import**: one compilation unit, and no error;
   - **positions**: every entity spans whole tokens of the program;
   - **meaning**: the export of the model is valid and has the same javac tree as the
     program, so the import lost nothing the program means;
   - **comments**: with a comment before every token, each comment is imported once and
     attached to code. `FASTTImporter` cannot ask for comments, so this check needs a second
     importer that keeps them, and is skipped without one.
6. **Retry.** A goal held only by failing programs is tried in up to 10 other programs, so a
   failure in one place does not hide it. A goal *fails* when every program tried fails.
7. **Reduction.** A failing program is reduced on its derivation tree, so every step is still
   a program of the grammar that javac accepts and that fails the same way. Failures are then
   grouped by check, message and reduced program: one group per cause.

The report, in the output directory:

| File | Contents |
|---|---|
| `summary.md` | goals by kind and outcome, checks, each failure group with its reduced program, the goals that fail everywhere, the goals no valid program holds |
| `goals.tsv` | every goal, its state, its outcome and the programs that hold it |
| `checks.tsv` | every check of every program |
| `coverage-map.tsv` | for each program, the FAST classes of the entities that span what it was generated for |
| `sentences/`, `failures/` | the programs, and the reduced program of each group |
| `grammar.txt` | the grammar as read, one alternative per line |

## Running it

You need a Pharo 13 VM (by default the Pharo Launcher's) and a JDK whose javac knows the
newest edition asked, given by `JAVA_HOME`. The script downloads a Moose 13 image and
loads FAST-Java (by default its v4 branch on GitHub) and this repository into it. It then
starts the javac oracle and writes one report per edition to `reports/`.

```bash
JAVA_HOME=/opt/homebrew/opt/openjdk scripts/coverage.sh 8 17 21 25
```

To test a local FAST-Java checkout, give it as a Metacello repository. `scripts/coverage.st`
lists the other settings, such as the importer, the kinds of goals and a focus.

```bash
GCOV_FAST_JAVA=tonel:///path/to/FAST-JAVA/src scripts/coverage.sh 25
```

In an image where FAST-Java and the `fastjava` group of `BaselineOfGrammarCoverage` are
loaded, start the oracle with `javac-oracle/run.sh 47811`, then:

```smalltalk
(GCovRun new
	label: 'FAST-Java on JLS SE 25';
	grammar: (GCovJLSReader edition: '25') grammar;
	language: GCovJavaLanguage new;
	oracle: (GCovJavacOracle release: '25');
	target: (GCovFASTJavaTarget importer: GCovFASTJavaTarget importers first new);
	outputDirectory: 'coverage-se25' asFileReference;
	yourself) run
```

A grammar does not say what real code combines, so the same checks also run over a corpus of
Java files, one line per file in a TSV: its path, then `pass`, `refused` when javac refuses it,
or the check that failed and its message. The import keeps comments there, and each comment the
file writes must be imported once and belong to code. Running it on two versions of FAST-Java
and comparing the files is how a release is checked for regressions.

```bash
GCOV_CORPUS=/path/to/jdk-sources GCOV_RELEASE=25 scripts/census.sh census.tsv
```

## When a new JLS edition comes out

1. See what changed: `scripts/grammar-diff.sh 25 26`. `+` marks a production added, `-` one
   removed, and `~` one changed, with the alternatives it lost and gained. An empty diff
   means the new edition needs nothing new.
2. Make sure javac knows the edition: `JAVA_HOME` must point to that JDK or a later one.
3. Run it where the grammar changed: `GCOV_FOCUS_FROM=25 scripts/coverage.sh 26`. The
   report starts with `grammar-diff-from-se25.txt`. Then run every goal:
   `scripts/coverage.sh 26`.
4. Read the failure groups. Each reduced program becomes a FAST-Java test with its fix, on
   v4 first.
5. If the pages bring prose the reader does not know, the report says so: the goals of a
   description with no sample are *impossible to build*. Add samples in
   `GCovJavaLanguage >> samplesFor:`.

## What it cannot tell

- **Rules written in prose.** The grammar is not the whole language. Where javac's parser
  enforces a rule in prose, javac refuses the program and the goal is *rejected*. Examples:
  `_` as a method parameter, an instance initializer in a record, `sealed` on a record. A
  rejected goal is the grammar saying more than the language allows. That is not a gap.
- **Rules javac checks after parsing.** The oracle only parses, so programs can be
  semantically wrong, such as `@A(this.x)` where only a constant is allowed. A failure on
  such a program is about input Java does not allow. The Java adapter steers expressions
  away from annotations and literal receivers to avoid most of these, but read each group
  with that question in mind.
- **Combinations beyond the criteria.** Context-dependent coverage pairs each alternative
  with each place it is used, not with everything around it. Sample projects stay useful
  for what real code combines.
- **Preview features.** Their grammar is not in the JLS until they are final.
- **Bugs of the oracle.** javac 25 and 26 record twice the annotations that a top-level
  method of a compact compilation unit writes after its type parameters, as in
  `<T> @A R m() {}`, so the meaning check fails for those programs whatever the importer
  does. The same method in a class is recorded once.

## Layout

| Path | Contents |
|---|---|
| `src/` | the Pharo packages, in Tonel |
| `GrammarCoverage-Core` | the grammar model, analysis, derivations, goals, generator, run, reducer, report |
| `GrammarCoverage-Java` | the JLS reader, the Java samples and biases, the javac oracle client |
| `GrammarCoverage-FASTJava` | the FAST-Java target, for any importer |
| `javac-oracle/` | the javac oracle server, a single Java file, and its start script |
| `scripts/` | the headless runs |
| `PLAN.md` | the research and the plan this implements |

Another language needs:
- a grammar reader that builds a `GCovGrammar`;
- a `GCovLanguage` subclass;
- a `GCovOracle` subclass;
- a `GCovTarget` subclass.

The core and its reports stay as they are.
