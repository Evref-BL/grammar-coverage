"
I check the FAST-Java metamodel through an importer of Java sources into it. The importer is any object that imports with `parse:into:`, the protocol of FAST's `FASTTImporter`. `GCovFASTJavaTarget importers` lists the Java importers loaded; SmaCC's is one of them.

My checks on each sentence, which javac accepts:

- **import**: the importer makes one compilation unit of the sentence without raising.
- **positions**: every entity has a position, inside the sentence, that starts and ends at the bounds of tokens.
- **meaning**: the export of the compilation unit is accepted by javac and has the same tree as the sentence. What the import loses of the program, the export cannot write back. The exporter is FAST-Java's unless told otherwise.
- **comments**: with a comment before every token and one at the end, each comment is imported once, attached to code. `FASTTImporter` has no way to ask for comments, so this check needs a comment importer, any object that imports with `parse:into:` and keeps comments; without one it is skipped.

The coverage map of a sentence names the classes of the entities that span exactly the text that covers its goal.

```language=text
GCovFASTJavaTarget importer: GCovFASTJavaTarget importers first new.
```
"
Class {
	#name : 'GCovFASTJavaTarget',
	#superclass : 'GCovTarget',
	#instVars : [
		'importer',
		'commentImporter',
		'exporter'
	],
	#category : 'GrammarCoverage-FASTJava-Target',
	#package : 'GrammarCoverage-FASTJava',
	#tag : 'Target'
}

{ #category : 'instance creation' }
GCovFASTJavaTarget class >> importer: anImporter [

	^ self new
		  importer: anImporter;
		  yourself
]

{ #category : 'instance creation' }
GCovFASTJavaTarget class >> importer: anImporter commentImporter: aCommentImporter [

	^ self new
		  importer: anImporter;
		  commentImporter: aCommentImporter;
		  yourself
]

{ #category : 'instance creation' }
GCovFASTJavaTarget class >> importers [
	"The importer classes of FAST that handle Java sources, found through FAST's importer API"

	| agnostic |
	agnostic := Smalltalk at: #FASTAgnosticImporter ifAbsent: [ ^ #(  ) ].
	^ (agnostic new importerClasses select: [ :class | class handlesFile: 'Probe.java' asFileReference ]) asArray
]

{ #category : 'checking' }
GCovFASTJavaTarget >> check: aSentence with: anOracle [

	^ self check: aSentence with: anOracle only: nil
]

{ #category : 'checking' }
GCovFASTJavaTarget >> check: aSentence with: anOracle only: aCheck [
	"Every check needs the import; the others run when aCheck names them or is nil"

	| model unit results |
	model := [ importer parse: aSentence text into: nil ]
		         on: Error
		         do: [ :error |
			         ^ { (GCovCheckResult
				            fail: #import
				            message: 'the importer raised ' , error class name
				            details: error messageText asString) } ].
	unit := self compilationUnitOf: model.
	unit ifNil: [
			^ { (GCovCheckResult
				   fail: #import
				   message: 'the importer made no single compilation unit'
				   details: (model allWithType: self compilationUnitClass) size printString , ' compilation units') } ].
	results := OrderedCollection with: (GCovCheckResult pass: #import).
	(aCheck isNil or: [ aCheck = #positions ]) ifTrue: [ results add: (self checkPositionsOf: model in: aSentence) ].
	(aCheck isNil or: [ aCheck = #meaning ]) ifTrue: [ results add: (self checkMeaningOf: unit in: aSentence with: anOracle) ].
	(aCheck isNil or: [ aCheck = #comments ]) ifTrue: [ results add: (self checkCommentsOf: aSentence) ].
	aCheck ifNil: [ aSentence coverageMap: (self classesSpanningTargetOf: aSentence in: model) ].
	^ results
]

{ #category : 'checking' }
GCovFASTJavaTarget >> checkCommentsOf: aSentence [
	"With a comment before every token and one after the last, every comment is imported once and belongs to code"

	| commented model comments |
	commentImporter ifNil: [ ^ GCovCheckResult skip: #comments reason: 'no importer of comments given' ].
	commented := self commentedTextOf: aSentence.
	model := [ commentImporter parse: commented key into: nil ]
		         on: Error
		         do: [ :error |
				         ^ GCovCheckResult
					           fail: #comments
					           message: 'the importer raised ' , error class name , ' on the commented sentence'
					           details: error messageText asString , String lf , commented key ].
	comments := model allWithType: self commentClass.
	commented value doWithIndex: [ :text :index |
			| found |
			found := comments select: [ :comment | comment content trimRight = text ].
			found isEmpty ifTrue: [
					^ GCovCheckResult
						  fail: #comments
						  message: 'a comment ' , (self placeOfComment: index in: aSentence) , ' is lost'
						  details: commented key ].
			found size > 1 ifTrue: [
					^ GCovCheckResult
						  fail: #comments
						  message: 'a comment ' , (self placeOfComment: index in: aSentence) , ' is imported several times'
						  details: commented key ].
			found first container ifNil: [
					^ GCovCheckResult
						  fail: #comments
						  message: 'a comment ' , (self placeOfComment: index in: aSentence) , ' belongs to nothing'
						  details: commented key ].
			(found first container isKindOf: self commentClass) ifTrue: [
					^ GCovCheckResult
						  fail: #comments
						  message: 'a comment ' , (self placeOfComment: index in: aSentence) , ' belongs to another comment'
						  details: commented key ] ].
	^ GCovCheckResult pass: #comments
]

{ #category : 'checking' }
GCovFASTJavaTarget >> checkMeaningOf: aCompilationUnit in: aSentence with: anOracle [
	"The export means what the sentence means"

	| exported verdict |
	exported := [ self exportOf: aCompilationUnit ]
		            on: Error
		            do: [ :error |
			            ^ GCovCheckResult
				              fail: #meaning
				              message: 'the exporter raised ' , error class name
				              details: error messageText asString ].
	verdict := anOracle verdictFor: exported.
	verdict isAccepted ifFalse: [
			^ GCovCheckResult
				  fail: #meaning
				  message: 'the oracle refuses the export'
				  details: 'Export: ' , exported , String lf , verdict diagnostics ].
	verdict tree = aSentence verdict tree ifTrue: [ ^ GCovCheckResult pass: #meaning ].
	^ GCovCheckResult
		  fail: #meaning
		  message: 'the export means something else: ' , (self differenceBetween: aSentence verdict tree and: verdict tree)
		  details: 'Export: ' , exported
]

{ #category : 'checking' }
GCovFASTJavaTarget >> checkPositionsOf: aModel in: aSentence [
	"Every entity spans whole tokens of the sentence"

	| starts stops size |
	starts := aSentence tokens collect: [ :token | token first ] as: Set.
	stops := aSentence tokens collect: [ :token | token last ] as: Set.
	size := aSentence text size.
	aModel entities do: [ :entity |
			(entity respondsTo: #startPos) ifTrue: [
					| first last |
					first := entity startPos.
					last := entity endPos.
					(first isNil or: [ last isNil ]) ifTrue: [
						^ GCovCheckResult
							  fail: #positions
							  message: entity class name , ' has no position'
							  details: (self describe: entity in: aSentence) ].
					((first between: 1 and: size + 1) and: [ (last between: 0 and: size) and: [ first <= (last + 1) ] ]) ifFalse: [
							^ GCovCheckResult
								  fail: #positions
								  message: entity class name , ' spans outside the sentence'
								  details: (self describe: entity in: aSentence) ].
					first <= last ifTrue: [
							(starts includes: first) ifFalse: [
									^ GCovCheckResult
										  fail: #positions
										  message: entity class name , ' starts inside a token'
										  details: (self describe: entity in: aSentence) ].
							(stops includes: last) ifFalse: [
									^ GCovCheckResult
										  fail: #positions
										  message: entity class name , ' ends inside a token'
										  details: (self describe: entity in: aSentence) ] ] ] ].
	^ GCovCheckResult pass: #positions
]

{ #category : 'checking' }
GCovFASTJavaTarget >> classesSpanningTargetOf: aSentence in: aModel [
	"The classes of the entities that span exactly the text that covers the goal of aSentence"

	| start stop |
	start := aSentence targetStart.
	stop := aSentence targetStop.
	start ifNil: [ ^ #(  ) ].
	^ ((aModel entities select: [ :entity |
		    (entity respondsTo: #startPos) and: [ entity startPos = start and: [ entity endPos = stop ] ] ])
		   collect: [ :entity | entity class name ]
		   as: Set) asArray sort
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> commentClass [

	^ Smalltalk at: #FASTJavaComment
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> commentImporter: anImporter [
	"An importer like my importer that also imports comments"

	commentImporter := anImporter
]

{ #category : 'checking' }
GCovFASTJavaTarget >> commentedTextOf: aSentence [
	"The sentence with a block comment before each token and a line comment at the end, and the texts of the comments in order"

	| comments text |
	comments := OrderedCollection new.
	text := String streamContents: [ :stream |
			        aSentence tokens doWithIndex: [ :token :index |
					        comments add: '/*c' , index printString , '*/'.
					        stream
						        nextPutAll: comments last;
						        space;
						        nextPutAll: (aSentence text copyFrom: token first to: token last);
						        space ].
			        comments add: '//c' , (aSentence tokens size + 1) printString.
			        stream
				        nextPutAll: comments last;
				        lf ].
	^ text -> comments asArray
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> compilationUnitClass [

	^ Smalltalk at: #FASTJavaCompilationUnit
]

{ #category : 'checking' }
GCovFASTJavaTarget >> compilationUnitOf: aModel [

	| units |
	units := aModel allWithType: self compilationUnitClass.
	^ units size = 1
		  ifTrue: [ units anyOne ]
		  ifFalse: [ nil ]
]

{ #category : 'checking' }
GCovFASTJavaTarget >> describe: anEntity in: aSentence [

	| first last |
	first := anEntity startPos.
	last := anEntity endPos.
	^ anEntity class name , ' at ' , first printString , '-' , last printString
	  , ((first isNotNil and: [ last isNotNil and: [ first >= 1 and: [ first <= last and: [ last <= aSentence text size ] ] ] ])
			   ifTrue: [ ': ' , (aSentence text copyFrom: first to: last) printString ]
			   ifFalse: [ '' ]) , ' in: ' , aSentence text
]

{ #category : 'checking' }
GCovFASTJavaTarget >> differenceBetween: aTree and: anotherTree [
	"Where two tree dumps first differ: the path of node kinds down to the line, and the line on each side"

	| lines others index path |
	lines := aTree lines.
	others := anotherTree lines.
	index := (1 to: (lines size min: others size))
		         detect: [ :each | (lines at: each) ~= (others at: each) ]
		         ifNone: [ (lines size min: others size) + 1 ].
	path := OrderedCollection new.
	index > 1 ifTrue: [
			| indent |
			indent := self indentOf: (index <= lines size
					           ifTrue: [ lines at: index ]
					           ifFalse: [ others at: index ]).
			index - 1 to: 1 by: -1 do: [ :each |
					(self indentOf: (lines at: each)) < indent ifTrue: [
							indent := self indentOf: (lines at: each).
							path addFirst: ((lines at: each) trimBoth copyUpTo: Character space) ] ] ].
	^ (' > ' join: (path last: (path size min: 3))) , ': ' , (index <= lines size
		   ifTrue: [ (lines at: index) trimBoth ]
		   ifFalse: [ 'nothing' ]) , ' became ' , (index <= others size
		   ifTrue: [ (others at: index) trimBoth ]
		   ifFalse: [ 'nothing' ])
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> exportOf: aCompilationUnit [

	^ exporter
		  ifNil: [ (Smalltalk at: #FASTJavaExportVisitor) new export: aCompilationUnit ]
		  ifNotNil: [ exporter value: aCompilationUnit ]
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> exporter: aBlock [
	"A block answering the Java source of a compilation unit"

	exporter := aBlock
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> importer: anImporter [
	"Any object that imports a Java source into a FAST-Java model with `parse:into:`"

	importer := anImporter
]

{ #category : 'checking' }
GCovFASTJavaTarget >> indentOf: aLine [

	^ (aLine findFirst: [ :character | character ~= Character space ]) max: 1
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> name [

	^ String streamContents: [ :stream |
			  stream nextPutAll: (self nameOf: importer).
			  commentImporter ifNotNil: [
					  stream
						  nextPutAll: ', comments through ';
						  nextPutAll: (self nameOf: commentImporter) ] ]
]

{ #category : 'accessing' }
GCovFASTJavaTarget >> nameOf: anImporter [

	anImporter isClass ifTrue: [ ^ anImporter name ].
	^ (anImporter isKindOf: GCovBlockImporter)
		  ifTrue: [ anImporter name ]
		  ifFalse: [ anImporter class name ]
]

{ #category : 'checking' }
GCovFASTJavaTarget >> placeOfComment: anIndex in: aSentence [

	| token |
	anIndex > aSentence tokens size ifTrue: [ ^ 'at the end' ].
	token := aSentence tokens at: anIndex.
	^ 'before ' , (aSentence text copyFrom: token first to: token last) printString
]
