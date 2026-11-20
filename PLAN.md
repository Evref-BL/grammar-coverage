# Grammar-driven completeness for FAST-Java

**Status, 19 November 2026: implemented.** `README.md` describes the result.
`GCovJLSReader` replaced the Python prototype this plan mentions, and reads the same grammars.
The prototype, `jls-probe-suite.st` and the census scripts the plan starts from were never part
of this repository; `scripts/census.sh` now runs the census.
Three things differ from the plan:
- Reduction groups failures by reduced program.
- A failing goal is retried in other programs.
- The Java adapter biases contexts away from annotation element values.

Goal: prove that FAST-Java handles every construct of the Java grammar, for each JLS
edition, with machinery that is re-run when a new edition appears. Real projects stay a
complement: they find the combinations a grammar-driven corpus does not think of.

## Research findings (19 November 2026)

**The grammar is available, per edition, in structured form.** Every JLS edition from
SE 8 to SE 27 is published as HTML at `docs.oracle.com/javase/specs/jls/seN/html/` with
each production marked up as `div.production > div.lhs + div.rhs`: nonterminals are
links, terminals are `code.literal`, alternatives are separated by `<br>`, and the
notation of §2.4 (`{x}`, `[x]`, `(one of)`, «but not» annotations) is plain text around
them. `prototype/jls_grammar.py` extracts it.

| Edition | Productions | Alternatives |
|---|---|---|
| SE 8 | 285 | 548 |
| SE 21 | 324 | 618 |
| SE 25 | 329 | 632 |
| SE 27 | 329 | 632 |

**Chapter 19 alone is not enough.** It is a recap, and the SE 25 recap references
`CompactCompilationUnit` and `SingleModuleImportDeclaration` without defining them. The
extractor reads chapters 3 to 19; with all of them, every referenced nonterminal is
defined in every edition checked. Read that way, SE 25 and SE 27 have the same grammar.

**The diff between editions is the maintenance signal.** `jls_grammar.py diff 21 25`
lists exactly what changed: compact compilation units, module imports, `_` as an unnamed
variable and pattern, concise lambda parameters, several patterns per case label,
component patterns, and statements before `this(...)`/`super(...)`. That is the list of
things a new release must check.

**No off-the-shelf grammar fits.** antlr/grammars-v4 has a JLS-derived grammar, but it
is frozen at SE 20 (last change 2025), and ANTLR-based generators such as Grammarinator
would then test that grammar, not the JLS. Generating from the JLS itself avoids a
second grammar to keep in sync.

**Coverage criteria from the literature, weakest to strongest:**

- *Alternative coverage*: every alternative of every production appears in some
  sentence. Purdom's algorithm (1972) builds a small set of short sentences that does it.
  There is no maintained implementation, but the algorithm is small: the shortest
  terminal derivation of each nonterminal, then a shortest path from the start symbol to
  each production.
- *Context-dependent branch coverage* (Lämmel, "Grammar Testing", 2001): every
  alternative of a nonterminal in every place where that nonterminal is used. This catches
  interactions such as a cast operand versus a parenthesized subtraction, which is where
  FAST-Java's past export bugs were.
- *k-path coverage* (Havrikov and Zeller, ASE 2019): every chain of k nested
  nonterminals. k = 2 is about context-dependent coverage, and higher k grows quickly.
- *EBNF boundaries*: `{x}` taken 0, 1 and 2 times, and `[x]` taken absent and present,
  because importers often break on "two or more".

**Where the grammar stops.** The JLS grammar is ambiguous, is not LL, and states some
rules in prose ("but not a ReservedKeyword", where `yield` may stand). So:

- A generated sentence is valid only if javac's parser accepts it at the matching
  `--release`. javac's parse phase (`JavacTask.parse()`, no attribution) is the right
  filter, because FAST-Java is syntactic.
- What javac refuses is recorded, not fixed: either the JLS grammar generates more than
  javac's parser accepts, or the generator has a bug.
- Rules given only in prose stay covered by `jls-probe-suite.st`.
- Preview features are out of scope: they are specified outside the JLS, in each JEP's
  spec change document.

## Oracles

Each generated file goes through FAST-Java in a headless image, as the census already
does, and must pass four checks:

1. **Parse.** SmaCC accepts every sentence javac accepts.
2. **No loss of meaning.** `export(import(source))` and `source` have the same javac tree,
   parentheses aside. This is the `SameTree` check the census already uses. It applies the
   rule that the model holds what changes behaviour: if the import drops something the
   program means, the export cannot write it back.
3. **Import integrity.** Every entity has positions inside the source, and every comment
   is attached once, to code. This is the existing `import-census.st`.
4. **Coverage map.** Each (production, alternative) is mapped to the FAST classes its
   sentence produces. An alternative that produces nothing of its own shows a construct
   the metamodel does not represent, even where the export happens to hide it.

When a check fails, the derivation tree is reduced, not the text: keep replacing subtrees
by the shortest derivation of their nonterminal while it still fails. The result is the
smallest failing program for that alternative, ready to become an SUnit test.

## Plan

1. **Grammar extraction.** Finish `jls_grammar.py`:
   - Parse alternatives into an EBNF tree, including `(one of)` lists and «» annotations.
   - Keep the JLS anchor of each production, so every finding cites its section.
   - Commit one normalized grammar per edition (8, 11, 17, 21, 25, then each new edition)
     and a diff report between consecutive ones.

   Done when every edition loads with no undefined nonterminal and the diffs match the
   JEPs of each release.
2. **Generator.**
   - Sentences that reach alternative coverage, starting from `CompilationUnit`.
   - The EBNF boundaries.
   - Hand-written samplers for the lexical leaves: identifiers, contextual keywords, every
     literal form of chapter 3 including text blocks and Unicode escapes.

   It is deterministic, and each file records the (production, alternative, context) it
   covers.

   Done when javac accepts the corpus, apart from a short, explained reject list.
3. **Oracle runner.** One command takes an edition and a FAST-Java checkout (v4 or v5),
   runs checks 1 to 4 in a fresh Moose image, and writes a report per (production,
   alternative). The javac and `SameTree` part is a small Java program, and the Pharo
   part reuses the census scripts.
4. **First run and triage** on v4 at SE 21 and SE 25, with alternative coverage. Fix v4
   first, then port to v5.
5. **Context-dependent coverage.** Raise the generator to it once alternative coverage
   is clean.
6. **Regression.** Check the minimized failing programs, and the generated corpus of each
   edition, into FAST-JAVA as data-driven tests: checks 1, 3 and 4 run in Pharo CI.
   Check 2 needs a JDK, so it runs with the runner before each release.
7. **New-edition procedure**, to repeat for each JLS release:
   1. Fetch the edition.
   2. Diff it against the previous one.
   3. Regenerate, giving the changed productions context-dependent coverage.
   4. Run the oracles.
   5. Open one v4 issue per production that fails.

## Decisions

- **Where the machinery lives:** in its own repository, this one.
- **Generic core, language adapters.** The coverage algorithms know nothing about Java:
  - the grammar model
  - alternative, context-dependent and boundary coverage
  - derivation-tree reduction
  - the coverage report

  Each language brings an adapter:
  - a grammar source (the JLS pages for Java)
  - samplers for the lexical leaves
  - a validity oracle (javac for Java)
  - the checks of its FAST importer

  The same core can then serve FAST-TypeScript or FAST-Fortran, and it can also read a
  SmaCC grammar, to generate from SmaCC's Java grammar and find what it accepts that
  javac refuses.
- **Pharo for the core and the adapters, Java only for javac.**
  - Every check that matters runs in Pharo: the SmaCC parse, the FAST import and export,
    and comment attachment.
  - Reduction calls these checks hundreds of times per failure, which is cheap in the
    image and slow across processes.
  - The minimized programs become SUnit tests in FAST-JAVA directly.
  - The Moose community reads and maintains Pharo.

  javac is the one part that must be Java. It runs as a small long-lived Java process: it
  reads source files on stdin and answers whether javac accepts each one and whether two
  sources have the same tree (`SameTree`). Pharo starts it once and talks to it, so
  reduction pays no JVM start-up.

  The Python prototype is retired once the Pharo extractor matches its output.
  Phuzzer, the existing Pharo fuzzer, generates at random and does not aim at coverage,
  so it is not a base.
