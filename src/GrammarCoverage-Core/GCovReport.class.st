"
I write the outcome of a run into its output directory:

- `summary.md`: the goals by kind and state, the checks, and each failure group with its reduced sentence;
- `goals.tsv`: every goal, its state and the sentence that covers it;
- `checks.tsv`: every check of every sentence;
- `coverage-map.tsv`: what the system under test made of the target of each sentence;
- `grammar.txt`: the grammar as read;
- `sentences/`: every sentence the oracle accepted;
- `failures/`: the reduced sentence of each failure group.
"
Class {
	#name : 'GCovReport',
	#superclass : 'Object',
	#instVars : [
		'run'
	],
	#category : 'GrammarCoverage-Core-Run',
	#package : 'GrammarCoverage-Core',
	#tag : 'Run'
}

{ #category : 'instance creation' }
GCovReport class >> run: aRun [

	^ self new
		  setRun: aRun;
		  yourself
]

{ #category : 'writing' }
GCovReport >> extension [

	^ run language fileExtension
]

{ #category : 'writing' }
GCovReport >> field: anObject [
	"anObject as a field of a TSV file: on one line, without tabs"

	^ anObject asString collect: [ :character |
			  (character = Character tab or: [ character = Character cr or: [ character = Character lf ] ])
				  ifTrue: [ Character space ]
				  ifFalse: [ character ] ]
]

{ #category : 'writing' }
GCovReport >> file: aFileReference contents: aString [

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream | stream nextPutAll: aString ]
]

{ #category : 'writing' }
GCovReport >> freshDirectory: aFileReference [

	aFileReference ensureDeleteAll.
	^ aFileReference ensureCreateDirectory
]

{ #category : 'writing' }
GCovReport >> line: aString on: aStream [

	aStream
		nextPutAll: aString;
		lf
]

{ #category : 'initialization' }
GCovReport >> setRun: aRun [

	run := aRun
]

{ #category : 'writing' }
GCovReport >> summary [

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: '# ' , run label;
				  lf;
				  lf.
			  self
				  line: '- Grammar: ' , run grammar name , ', ' , run grammar productions size printString , ' productions, start symbol `'
					  , run grammar start , '`'
				  on: stream.
			  self line: '- Oracle: ' , run oracle name on: stream.
			  run target ifNotNil: [ :target | self line: '- System under test: ' , target name on: stream ].
			  self line: '- Sentences the oracle accepted: ' , run sentences size printString on: stream.
			  stream lf.
			  self writeGoalTableOn: stream.
			  run target ifNotNil: [
					  self writeCheckTableOn: stream.
					  self writeFailureGroupsOn: stream.
					  self writeFailingGoalsOn: stream ].
			  self writeUncoveredGoalsOn: stream ]
]

{ #category : 'writing' }
GCovReport >> tsv: aFileReference header: aHeader rows: aCollection [

	self file: aFileReference contents: (String streamContents: [ :stream |
				 { aHeader } , aCollection asArray do: [ :row |
						 row do: [ :each | stream nextPutAll: (self field: each) ] separatedBy: [ stream tab ].
						 stream lf ] ])
]

{ #category : 'writing' }
GCovReport >> write [

	| directory |
	directory := run outputDirectory ensureCreateDirectory.
	self writeGrammarIn: directory.
	self writeSentencesIn: directory.
	self writeGoalsIn: directory.
	self writeChecksIn: directory.
	self writeCoverageMapIn: directory.
	self writeFailuresIn: directory.
	self writeSummaryIn: directory.
	self file: directory / 'progress.log' contents: (String lf join: run log)
]

{ #category : 'writing' }
GCovReport >> writeCheckTableOn: aStream [

	| checks |
	checks := OrderedCollection new.
	run sentences do: [ :sentence |
		sentence results do: [ :result | (checks includes: result check) ifFalse: [ checks add: result check ] ] ].
	self line: '## Checks' on: aStream.
	aStream lf.
	self line: '| Check | Passed | Failed | Skipped |' on: aStream.
	self line: '|---|---|---|---|' on: aStream.
	checks do: [ :check |
			| results |
			results := run sentences flatCollect: [ :sentence | sentence results select: [ :result | result check = check ] ].
			self
				line: '| ' , check , ' | ' , (results count: [ :result | result isPass ]) printString , ' | '
					, (results count: [ :result | result isFailure ]) printString , ' | '
					, (results count: [ :result | result isSkipped ]) printString , ' |'
				on: aStream ].
	aStream lf
]

{ #category : 'writing' }
GCovReport >> writeChecksIn: aDirectory [

	| rows |
	rows := OrderedCollection new.
	run sentences do: [ :sentence |
			sentence results do: [ :result |
					rows add: {
							sentence name.
							sentence goal key.
							result check.
							result state.
							result message.
							(result details truncateTo: 500) } ] ].
	self tsv: aDirectory / 'checks.tsv' header: #( 'sentence' 'goal' 'check' 'state' 'message' 'details' ) rows: rows
]

{ #category : 'writing' }
GCovReport >> writeCoverageMapIn: aDirectory [

	self
		tsv: aDirectory / 'coverage-map.tsv'
		header: #( 'goal' 'kind' 'sentence' 'start' 'stop' 'text' 'made into' )
		rows: (run sentences collect: [ :sentence |
					 {
						 sentence goal key.
						 sentence goal kind.
						 sentence name.
						 (sentence targetStart ifNil: [ '' ]).
						 (sentence targetStop ifNil: [ '' ]).
						 (sentence targetText truncateTo: 80).
						 (' ' join: sentence coverageMap) } ])
]

{ #category : 'writing' }
GCovReport >> writeFailingGoalsOn: aStream [

	| failing |
	failing := run statuses values select: [ :status | status outcome = #failed ].
	self line: '## Goals that fail in every sentence tried' on: aStream.
	aStream lf.
	failing isEmpty ifTrue: [ ^ self line: 'None.' on: aStream ].
	failing do: [ :status |
			self
				line: '- `' , status goal key , '`: ' , status goal description , ' -- '
					, (status sentence failures ifEmpty: [ '' ] ifNotEmpty: [ :failures | failures first signature ])
				on: aStream ].
	aStream lf
]

{ #category : 'writing' }
GCovReport >> writeFailureGroupsOn: aStream [

	self line: '## Failures' on: aStream.
	aStream lf.
	run failureGroups isEmpty ifTrue: [ ^ self line: 'None.' on: aStream ].
	self
		line: 'Failures are grouped by check, message and reduced sentence: a group is one cause, as far as reduction tells.'
		on: aStream.
	run failureGroups doWithIndex: [ :group :index |
			| name failure goals |
			name := index printPaddedWith: $0 to: 3.
			goals := (group sentences collect: [ :sentence | sentence goal key ] as: Set) asArray sort.
			aStream lf.
			self line: '### ' , name , '. ' , group signature on: aStream.
			aStream lf.
			self
				line:
					group size printString , ' sentences fail this way, generated for: `' , ('`, `' join: (goals first: (goals size min: 12)))
					, '`' , (goals size > 12
						 ifTrue: [ ' and ' , (goals size - 12) printString , ' more' ]
						 ifFalse: [ '' ]) , '.'
				on: aStream.
			aStream lf.
			self line: 'Reduced sentence, `failures/' , name , '.' , self extension , '`:' on: aStream.
			aStream lf.
			self line: '```' , self extension on: aStream.
			self line: group reduced text on: aStream.
			self line: '```' on: aStream.
			failure := (group failureIn: group reduced) ifNil: [ group failureIn: group smallest ].
			(failure isNotNil and: [ failure details isNotEmpty ]) ifTrue: [
					aStream lf.
					self line: '```text' on: aStream.
					self line: (failure details truncateTo: 3000) on: aStream.
					self line: '```' on: aStream ] ].
	aStream lf
]

{ #category : 'writing' }
GCovReport >> writeFailuresIn: aDirectory [

	| directory |
	directory := self freshDirectory: aDirectory / 'failures'.
	run failureGroups doWithIndex: [ :group :index |
			| name |
			name := index printPaddedWith: $0 to: 3.
			self file: directory / (name , '.' , self extension) contents: group reduced text.
			group reduced text = group smallest text ifFalse: [
				self file: directory / (name , '-original.' , self extension) contents: group smallest text ] ]
]

{ #category : 'writing' }
GCovReport >> writeGoalTableOn: aStream [

	| states |
	states := #( #covered #rejected #impossible #untried ).
	self line: '## Goals' on: aStream.
	aStream lf.
	self
		line:
		'A goal is covered when a sentence the oracle accepts holds it. It passes when one of those sentences passes every check, and fails when every one tried fails.'
		on: aStream.
	aStream lf.
	self line: '| Kind | Goals | Covered | Passes | Fails | Rejected by the oracle | Impossible to build | Not tried |' on: aStream.
	self line: '|---|---|---|---|---|---|---|---|' on: aStream.
	run generator kindsInOrder , #( nil ) do: [ :kind |
			| statuses |
			statuses := run statuses values select: [ :status | kind isNil or: [ status goal kind = kind ] ].
			statuses isEmpty ifFalse: [
					aStream
						nextPutAll: '| ';
						nextPutAll: (kind ifNil: [ '**all**' ] ifNotNil: [ kind asString ]);
						nextPutAll: ' | ';
						print: statuses size;
						nextPutAll: ' | ';
						print: (statuses count: [ :status | status state = #covered ]).
					#( #passed #failed ) do: [ :outcome |
							aStream
								nextPutAll: ' | ';
								nextPutAll: (run target ifNil: [ '-' ] ifNotNil: [ (statuses count: [ :status | status outcome = outcome ]) printString ]) ].
					states allButFirstDo: [ :state |
							aStream
								nextPutAll: ' | ';
								print: (statuses count: [ :status | status state = state ]) ].
					self line: ' |' on: aStream ] ].
	aStream lf
]

{ #category : 'writing' }
GCovReport >> writeGoalsIn: aDirectory [

	self
		tsv: aDirectory / 'goals.tsv'
		header: #( 'goal' 'kind' 'state' 'outcome' 'sentence' 'passing sentence' 'candidates' 'source' 'description' 'detail' )
		rows: (run statuses values collect: [ :status |
					 {
						 status goal key.
						 status goal kind.
						 status state.
						 (status outcome ifNil: [ '' ]).
						 (status sentence ifNil: [ '' ] ifNotNil: [ :sentence | sentence name ]).
						 (status passing ifNil: [ '' ] ifNotNil: [ :sentence | sentence name ]).
						 status candidates.
						 (status goal source ifNil: [ '' ]).
						 status goal description.
						 status detail } ])
]

{ #category : 'writing' }
GCovReport >> writeGrammarIn: aDirectory [

	self file: aDirectory / 'grammar.txt' contents: run grammar grammarText withUnixLineEndings
]

{ #category : 'writing' }
GCovReport >> writeSentencesIn: aDirectory [

	| directory |
	directory := self freshDirectory: aDirectory / 'sentences'.
	run sentences do: [ :sentence | self file: directory / (sentence name , '.' , self extension) contents: sentence text ]
]

{ #category : 'writing' }
GCovReport >> writeSummaryIn: aDirectory [

	self file: aDirectory / 'summary.md' contents: self summary
]

{ #category : 'writing' }
GCovReport >> writeUncoveredGoalsOn: aStream [

	| uncovered |
	uncovered := run statuses values reject: [ :status | status isCovered ].
	self line: '## Goals not covered' on: aStream.
	aStream lf.
	uncovered isEmpty ifTrue: [ ^ self line: 'None.' on: aStream ].
	self
		line:
		'A goal is rejected when the oracle refused every candidate tried; the detail is its diagnostic for the first. A goal is impossible when no candidate could be built.'
		on: aStream.
	aStream lf.
	uncovered do: [ :status |
			self
				line:
					'- `' , status goal key , '` (' , status state , ', ' , status candidates printString , ' candidates): '
					, status goal description , ' -- ' , ((self field: status detail) truncateTo: 300)
				on: aStream ]
]
