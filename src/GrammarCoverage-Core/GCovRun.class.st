"
I run a coverage campaign:

1. **Generate**: for each goal not yet covered, try its candidates until the oracle accepts one. A sentence covers every goal its tree holds, not only its own. A goal with no accepted candidate is rejected, with the oracle's diagnostics, or impossible when no candidate could be built.
2. **Check**: the target checks every accepted sentence.
3. **Group**: failures with the same signature form a group.
4. **Reduce**: the smallest sentence of each group is reduced to the smallest one that still fails the same way.
5. **Report**: everything is written to the output directory.

```language=text
(GCovRun new
	label: 'JLS SE 25';
	grammar: aGrammar;
	language: GCovJavaLanguage new;
	oracle: (GCovJavacOracle release: '25');
	target: aTarget;
	outputDirectory: 'coverage/se25' asFileReference;
	yourself) run
```
"
Class {
	#name : 'GCovRun',
	#superclass : 'Object',
	#instVars : [
		'label',
		'grammar',
		'language',
		'oracle',
		'target',
		'generator',
		'goals',
		'statuses',
		'sentences',
		'failureGroups',
		'outputDirectory',
		'log',
		'maxReductions',
		'reducer',
		'maxRetries',
		'reductions'
	],
	#category : 'GrammarCoverage-Core-Run',
	#package : 'GrammarCoverage-Core',
	#tag : 'Run'
}

{ #category : 'running' }
GCovRun >> accept: aSentence [
	"aSentence covers every goal its tree holds, not only its own"

	sentences add: aSentence.
	aSentence id: sentences size.
	aSentence coverageKeys do: [ :key |
		(statuses at: key ifAbsent: [ nil ]) ifNotNil: [ :status | status isCovered ifFalse: [ status coverBy: aSentence ] ] ]
]

{ #category : 'running' }
GCovRun >> check [

	self log: 'Checking ' , sentences size printString , ' sentences with ' , target name.
	sentences doWithIndex: [ :sentence :index |
			self checkSentence: sentence.
			index \\ 500 = 0 ifTrue: [ self log: index printString , ' sentences checked' ] ].
	self log: (sentences count: [ :sentence | sentence failures isNotEmpty ]) printString , ' sentences fail a check'
]

{ #category : 'running' }
GCovRun >> checkSentence: aSentence [
	"Check aSentence, and record it as the passing sentence of every goal it holds when it passes"

	aSentence results: ([ target check: aSentence with: oracle ]
			 on: Error
			 do: [ :error |
				 { (GCovCheckResult fail: #target message: 'the target raised ' , error class name details: error messageText asString) } ]).
	aSentence failures isEmpty ifTrue: [
			aSentence coverageKeys do: [ :key |
				(statuses at: key ifAbsent: [ nil ]) ifNotNil: [ :status | status passing ifNil: [ status passing: aSentence ] ] ] ]
]

{ #category : 'running' }
GCovRun >> countOf: aState [

	^ statuses count: [ :status | status state = aState ]
]

{ #category : 'accessing' }
GCovRun >> failureGroups [

	^ failureGroups
]

{ #category : 'running' }
GCovRun >> generate [

	goals := self generator goals.
	statuses := OrderedDictionary new.
	goals do: [ :goal | statuses at: goal key put: (GCovGoalStatus goal: goal) ].
	sentences := OrderedCollection new.
	self log: goals size printString , ' goals'.
	goals doWithIndex: [ :goal :index |
			| status |
			status := statuses at: goal key.
			status isCovered ifFalse: [ self generateFor: status ].
			index \\ 500 = 0 ifTrue: [ self log: index printString , ' goals done, ' , sentences size printString , ' sentences' ] ].
	self log: (self countOf: #covered) printString , ' goals covered by ' , sentences size printString , ' sentences, '
		, (self countOf: #rejected) printString , ' rejected, ' , (self countOf: #impossible) printString , ' impossible'
]

{ #category : 'running' }
GCovRun >> generateFor: aStatus [

	| accepted firstRejection count |
	accepted := nil.
	firstRejection := nil.
	count := self generator candidatesFor: aStatus goal do: [ :sentence |
			         | verdict |
			         verdict := oracle verdictFor: sentence text.
			         verdict isAccepted
				         ifTrue: [
						         sentence verdict: verdict.
						         accepted := sentence.
						         true ]
				         ifFalse: [
						         firstRejection ifNil: [ firstRejection := sentence text -> verdict diagnostics ].
						         false ] ].
	aStatus candidates: count.
	accepted ifNotNil: [
			self accept: accepted.
			aStatus isCovered ifFalse: [ aStatus coverBy: accepted ].
			^ self ].
	count = 0
		ifTrue: [
				aStatus impossible:
					((self generator buildFailureOf: aStatus goal) ifNil: [ 'every route from the start symbol is refused by an exclusion' ]) ]
		ifFalse: [ aStatus rejectedAfter: count first: firstRejection ]
]

{ #category : 'accessing' }
GCovRun >> generator [

	^ generator ifNil: [ generator := GCovGenerator grammar: grammar language: language ]
]

{ #category : 'accessing' }
GCovRun >> generator: aGenerator [

	generator := aGenerator
]

{ #category : 'accessing' }
GCovRun >> goals [

	^ goals
]

{ #category : 'accessing' }
GCovRun >> grammar [

	^ grammar
]

{ #category : 'accessing' }
GCovRun >> grammar: aGrammar [

	grammar := aGrammar
]

{ #category : 'running' }
GCovRun >> group [
	"Reduce a failure of each goal and signature, up to maxReductions, and group the failures by signature and reduced sentence, the largest groups first"

	| groups |
	groups := OrderedDictionary new.
	reductions := Dictionary new.
	self log: 'Reducing the failures'.
	sentences do: [ :sentence |
			sentence failures do: [ :result |
					| reduced |
					reduced := self reduce: sentence signature: result signature.
					(groups at: result signature -> reduced text ifAbsentPut: [ GCovFailureGroup signature: result signature reduced: reduced ])
						add: sentence ] ].
	failureGroups := groups values sort: [ :a :b | a size > b size or: [ a size = b size and: [ a signature <= b signature ] ] ].
	self log: failureGroups size printString , ' failure groups from ' , reductions size printString , ' reductions'
]

{ #category : 'initialization' }
GCovRun >> initialize [

	super initialize.
	label := 'Coverage'.
	maxReductions := 1000.
	log := OrderedCollection new.
	sentences := OrderedCollection new.
	failureGroups := #(  )
]

{ #category : 'accessing' }
GCovRun >> label [

	^ label
]

{ #category : 'accessing' }
GCovRun >> label: aString [

	label := aString
]

{ #category : 'accessing' }
GCovRun >> language [

	^ language
]

{ #category : 'accessing' }
GCovRun >> language: aLanguage [

	language := aLanguage
]

{ #category : 'accessing' }
GCovRun >> log [

	^ log
]

{ #category : 'running' }
GCovRun >> log: aString [

	| line |
	line := Time now print24 , ' ' , aString.
	log add: line.
	Smalltalk isHeadless
		ifTrue: [
				Stdio stdout
					nextPutAll: line;
					lf;
					flush ]
		ifFalse: [ Transcript crShow: line ]
]

{ #category : 'accessing' }
GCovRun >> maxReductions: anInteger [
	"The number of failures to reduce; the others are grouped as they are"

	maxReductions := anInteger
]

{ #category : 'running' }
GCovRun >> maxRetries [
	"The number of other sentences the oracle accepts to check for a goal before deciding it fails everywhere"

	^ maxRetries ifNil: [ 10 ]
]

{ #category : 'running' }
GCovRun >> maxRetries: anInteger [

	maxRetries := anInteger
]

{ #category : 'accessing' }
GCovRun >> oracle [

	^ oracle
]

{ #category : 'accessing' }
GCovRun >> oracle: anOracle [

	oracle := anOracle
]

{ #category : 'running' }
GCovRun >> outcomeCountOf: anOutcome [

	^ statuses count: [ :status | status outcome = anOutcome ]
]

{ #category : 'accessing' }
GCovRun >> outputDirectory [

	^ outputDirectory
]

{ #category : 'accessing' }
GCovRun >> outputDirectory: aFileReference [

	outputDirectory := aFileReference asFileReference
]

{ #category : 'running' }
GCovRun >> reduce: aSentence signature: aSignature [
	"The reduced sentence of the first failure with aSignature of the goal of aSentence: the failures of one goal with one signature are taken for one cause"

	^ reductions at: aSignature -> aSentence goal key ifAbsentPut: [
			  reductions size < maxReductions
				  ifTrue: [ self reducer reduce: aSentence signature: aSignature ]
				  ifFalse: [ aSentence ] ]
]

{ #category : 'accessing' }
GCovRun >> reducer [

	^ reducer ifNil: [
			  reducer := GCovReducer
				             builder: self generator builder
				             renderer: self generator renderer
				             oracle: oracle
				             target: target ]
]

{ #category : 'running' }
GCovRun >> retry [
	"For every covered goal no checked sentence passes, look for one among its other candidates, so that a failure in one context does not hide the goal"

	| failing |
	failing := statuses values select: [ :status | status isCovered and: [ status passing isNil ] ].
	self log: 'Retrying ' , failing size printString , ' goals that only failing sentences hold'.
	failing do: [ :status | status passing ifNil: [ self retry: status ] ].
	self log: (self outcomeCountOf: #failed) printString , ' goals fail in every sentence tried'
]

{ #category : 'running' }
GCovRun >> retry: aStatus [

	| tried |
	tried := 0.
	self generator candidatesFor: aStatus goal do: [ :candidate |
			| verdict |
			verdict := oracle verdictFor: candidate text.
			(verdict isAccepted and: [ (sentences anySatisfy: [ :each | each text = candidate text ]) not ])
				ifTrue: [
						candidate verdict: verdict.
						sentences add: candidate.
						candidate id: sentences size.
						self checkSentence: candidate.
						tried := tried + 1.
						aStatus passing isNotNil or: [ tried >= self maxRetries ] ]
				ifFalse: [ false ] ]
]

{ #category : 'running' }
GCovRun >> run [

	self log: 'Run ' , label.
	self generate.
	target ifNotNil: [
			self check.
			self retry.
			self group ].
	outputDirectory ifNotNil: [ self writeReport ].
	self log: 'Done'
]

{ #category : 'accessing' }
GCovRun >> sentences [

	^ sentences
]

{ #category : 'accessing' }
GCovRun >> statuses [

	^ statuses
]

{ #category : 'accessing' }
GCovRun >> target [

	^ target
]

{ #category : 'accessing' }
GCovRun >> target: aTarget [

	target := aTarget
]

{ #category : 'running' }
GCovRun >> writeReport [

	(GCovReport run: self) write.
	self log: 'Report written to ' , outputDirectory fullName
]
