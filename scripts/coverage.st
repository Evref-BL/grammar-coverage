"Run Grammar Coverage on FAST-Java for each JLS edition asked, after load.st.

GCOV_EDITIONS    the JLS editions, such as `8 17 21 25`; javac checks each at the same release
GCOV_OUT         the directory of the reports, one subdirectory per edition
GCOV_ORACLE_URL  the javac oracle, by default http://127.0.0.1:47811
GCOV_JLS_CACHE   where the JLS pages are kept between runs
GCOV_IMPORTER    the class of the Java importer to test, by default the first FAST lists
GCOV_COMMENTS    `smacc` checks comments through SmaCC's importer when it is loaded, `none` skips them
GCOV_FOCUS_FROM  an older edition: test only the productions the edition adds or changes from it
GCOV_KINDS       the kinds of goals, by default all of
                 `alternative sample description repetition option context`"

| environment editions output oracleUrl jlsCache importer commentImporter focusFrom kinds |
environment := Smalltalk os environment.
editions := (environment at: 'GCOV_EDITIONS' ifAbsent: [ '25' ]) substrings.
output := (environment at: 'GCOV_OUT') asFileReference.
oracleUrl := environment at: 'GCOV_ORACLE_URL' ifAbsent: [ GCovJavacOracle defaultUrl ].
jlsCache := environment at: 'GCOV_JLS_CACHE' ifAbsent: [ nil ].
importer := (environment at: 'GCOV_IMPORTER' ifAbsent: [ nil ])
	            ifNil: [ GCovFASTJavaTarget importers first ]
	            ifNotNil: [ :name | Smalltalk at: name asSymbol ].
commentImporter := ((environment at: 'GCOV_COMMENTS' ifAbsent: [ 'smacc' ]) = 'smacc' and: [
	                    Smalltalk includesKey: #JavaSmaCCProgramNodeImporterVisitor ]) ifTrue: [
	                   GCovBlockImporter
		                   named: 'JavaSmaCCProgramNodeImporterVisitor withComments'
		                   block: [ :source :model |
			                   (Smalltalk at: #JavaSmaCCProgramNodeImporterVisitor) new
				                   withComments;
				                   parseCodeString: source ] ].
focusFrom := environment at: 'GCOV_FOCUS_FROM' ifAbsent: [ nil ].
kinds := (environment at: 'GCOV_KINDS' ifAbsent: [ nil ]) ifNotNil: [ :string | string substrings collect: [ :each | each asSymbol ] ].
editions do: [ :edition |
	| reader run |
	reader := GCovJLSReader edition: edition.
	jlsCache ifNotNil: [ reader cacheDirectory: jlsCache ].
	run := GCovRun new
		       label: 'FAST-Java on JLS SE ' , edition;
		       grammar: reader grammar;
		       language: GCovJavaLanguage new;
		       oracle: (GCovJavacOracle release: edition url: oracleUrl);
		       target: (GCovFASTJavaTarget importer: importer new commentImporter: commentImporter);
		       outputDirectory: output / ('se' , edition);
		       yourself.
	kinds ifNotNil: [ run generator kinds: kinds ].
	focusFrom ifNotNil: [
		| old diff |
		old := GCovJLSReader edition: focusFrom.
		jlsCache ifNotNil: [ old cacheDirectory: jlsCache ].
		diff := GCovGrammarDiff old: old grammar new: reader grammar.
		run generator focus: diff focus.
		(output / ('se' , edition)) ensureCreateDirectory.
		(output / ('se' , edition) / ('grammar-diff-from-se' , focusFrom , '.txt')) writeStreamDo: [ :stream |
			stream nextPutAll: diff printString ] ].
	run run ]
