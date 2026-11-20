"Check FAST-Java on every Java file of a corpus, after load.st, with the checks of a coverage run:
the import, the positions and the meaning. The import keeps comments, and every comment of the
file must be imported once and belong to code.

GCOV_CORPUS      the directory of the Java files
GCOV_RELEASE     the release javac reads them at, by default 25
GCOV_CENSUS_OUT  the file to write, one line per file: its path in the corpus, then `pass`,
                 `refused` when javac refuses it, or the check that failed, with its message
GCOV_ORACLE_URL  the javac oracle, by default http://127.0.0.1:47811"

| environment corpus release oracleUrl out target files flat check options |
environment := Smalltalk os environment.
options := ZnOptions globalDefault clone.
options at: #maximumEntitySize put: 512 * 1024 * 1024.
corpus := (environment at: 'GCOV_CORPUS') asFileReference.
release := environment at: 'GCOV_RELEASE' ifAbsent: [ '25' ].
oracleUrl := environment at: 'GCOV_ORACLE_URL' ifAbsent: [ GCovJavacOracle defaultUrl ].
out := (environment at: 'GCOV_CENSUS_OUT') asFileReference.
target := GCovFASTJavaTarget new.
flat := [ :string |
	| line |
	line := string asString collect: [ :char |
		        (char = Character tab or: [ char = Character cr or: [ char = Character lf ] ])
			        ifTrue: [ $  ]
			        ifFalse: [ char ] ].
	line size > 1000
		ifTrue: [ line first: 1000 ]
		ifFalse: [ line ] ].
check := [ :source |
	| oracle verdict model units ast tokens sentence result comments starts outcome |
	oracle := GCovJavacOracle release: release url: oracleUrl.
	verdict := oracle verdictFor: source.
	verdict isAccepted ifFalse: [ outcome := { 'refused'. '' } ].
	outcome ifNil: [
		model := [
		         (Smalltalk at: #JavaSmaCCProgramNodeImporterVisitor) new
			         withComments;
			         parseCodeString: source ]
			         on: Error
			         do: [ :error |
				         outcome := { 'import'. error class name , ' ' , error messageText asString }.
				         nil ] ].
	outcome ifNil: [
		units := model allWithType: target compilationUnitClass.
		units size = 1 ifFalse: [ outcome := { 'import'. units size printString , ' compilation units' } ] ].
	outcome ifNil: [
		ast := (Smalltalk at: #JavaParser) parse: source.
		tokens := (ast allTokens collect: [ :token | token startPosition to: token stopPosition ]) asOrderedCollection.
		ast comments do: [ :interval | tokens add: (interval first to: interval last) ].
		sentence := GCovSentence root: nil text: source tokens: tokens asArray.
		sentence verdict: verdict.
		result := target checkPositionsOf: model in: sentence.
		result isPass ifFalse: [ outcome := { 'positions'. result message , ': ' , result details } ] ].
	outcome ifNil: [
		result := target checkMeaningOf: units anyOne in: sentence with: oracle.
		result isPass ifFalse: [
			outcome := { 'meaning'. result message }.
			"The details hold the whole export, and what javac says of it is what tells the cause"
			result message = 'the oracle refuses the export' ifTrue: [
				outcome := { 'meaning'. result message , ': ' , (oracle verdictFor: (target exportOf: units anyOne)) diagnostics } ] ] ].
	outcome ifNil: [
		comments := model allWithType: target commentClass.
		starts := comments collect: [ :comment | comment startPos ] as: Set.
		starts size = ast comments size ifFalse: [
			outcome := { 'comments'. ast comments size printString , ' written, ' , starts size printString , ' imported' } ] ].
	outcome ifNil: [
		comments size = starts size ifFalse: [ outcome := { 'comments'. 'a comment is imported several times' } ] ].
	outcome ifNil: [
		(comments anySatisfy: [ :comment | comment container isNil ]) ifTrue: [
			outcome := { 'comments'. 'a comment belongs to nothing' } ] ].
	outcome ifNil: [
		(comments anySatisfy: [ :comment | comment container isKindOf: target commentClass ]) ifTrue: [
			outcome := { 'comments'. 'a comment belongs to another comment' } ] ].
	outcome ifNil: [ { 'pass'. '' } ] ].
files := (corpus allChildrenMatching: '*.java') sort: [ :a :b | a fullName < b fullName ].
out ensureDelete.
out parent ensureCreateDirectory.
out writeStreamDo: [ :stream |
	files doWithIndex: [ :file :index |
		| source outcome |
		source := [ file contents ]
			          on: Error
			          do: [ file binaryReadStreamDo: [ :binary | (ZnCharacterEncoder newForEncoding: 'latin1') decodeBytes: binary upToEnd ] ].
		"The tree javac gives of a large file is larger than Zinc takes by default, and slower"
		outcome := [
		           options during: [
			           ZnConnectionTimeout value: 600 during: [
				           [ check value: source ] valueWithin: 600 seconds onTimeout: [ { 'timeout'. '' } ] ] ] ]
			           on: Error
			           do: [ :error | { 'error'. error class name , ' ' , error messageText asString } ].
		(Deprecation instVarNamed: 'log') ifNotNil: [ :log | log removeAll ].
		stream
			nextPutAll: (file fullName allButFirst: corpus fullName size + 1);
			tab;
			nextPutAll: outcome first;
			tab;
			nextPutAll: (flat value: outcome second);
			lf;
			flush.
		index \\ 1000 = 0 ifTrue: [
			Smalltalk garbageCollect.
			Stdio stdout nextPutAll: index printString , ' of ' , files size printString , ' files'; lf; flush ] ] ].
Stdio stdout nextPutAll: 'Census written to ' , out fullName; lf; flush
