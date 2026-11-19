"
I am a sentence of the grammar: a derivation tree, its text and its tokens. The goal I was generated for is the reason I exist, and my target is the node that covers it. The verdict is the oracle's, the results are those of the checks the target ran on me, and the coverage map names what the system under test made of my target.
"
Class {
	#name : 'GCovSentence',
	#superclass : 'Object',
	#instVars : [
		'id',
		'root',
		'text',
		'tokens',
		'goal',
		'target',
		'verdict',
		'results',
		'coverageMap',
		'targetStart',
		'targetStop'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovSentence class >> root: aNode text: aString tokens: anArray [

	^ self new
		  setRoot: aNode text: aString tokens: anArray;
		  yourself
]

{ #category : 'accessing' }
GCovSentence >> coverageKeys [

	| keys |
	keys := Set new.
	root coverageKeysDo: [ :key | keys add: key ].
	^ keys
]

{ #category : 'accessing' }
GCovSentence >> coverageMap [
	"What the system under test made of my target, such as the names of the classes of the entities that span it"

	^ coverageMap ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
GCovSentence >> coverageMap: aCollection [

	coverageMap := aCollection
]

{ #category : 'accessing' }
GCovSentence >> failures [

	^ self results select: [ :result | result isFailure ]
]

{ #category : 'accessing' }
GCovSentence >> goal [

	^ goal
]

{ #category : 'accessing' }
GCovSentence >> goal: aGoal [

	goal := aGoal
]

{ #category : 'accessing' }
GCovSentence >> id [

	^ id
]

{ #category : 'accessing' }
GCovSentence >> id: anInteger [

	id := anInteger
]

{ #category : 'accessing' }
GCovSentence >> name [
	"My id, padded so that file names sort in order"

	^ id printPaddedWith: $0 to: 5
]

{ #category : 'printing' }
GCovSentence >> printOn: aStream [

	aStream
		nextPutAll: 'Sentence ';
		print: id;
		nextPutAll: ': ';
		nextPutAll: text
]

{ #category : 'accessing' }
GCovSentence >> results [

	^ results ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
GCovSentence >> results: aCollection [

	results := aCollection
]

{ #category : 'accessing' }
GCovSentence >> root [

	^ root
]

{ #category : 'initialization' }
GCovSentence >> setRoot: aNode text: aString tokens: anArray [

	root := aNode.
	text := aString.
	tokens := anArray
]

{ #category : 'accessing' }
GCovSentence >> target [
	"The node of my tree that covers my goal"

	^ target
]

{ #category : 'accessing' }
GCovSentence >> target: aNode [
	"Set when my text is rendered: the span of aNode is then the span of my target, which a later rendering of a tree sharing aNode would change"

	target := aNode.
	targetStart := aNode ifNotNil: [ aNode start ].
	targetStop := aNode ifNotNil: [ aNode stop ]
]

{ #category : 'accessing' }
GCovSentence >> targetStart [
	"The first character of the text that covers my goal, nil when it is empty or unknown"

	^ targetStart
]

{ #category : 'accessing' }
GCovSentence >> targetStop [

	^ targetStop
]

{ #category : 'accessing' }
GCovSentence >> targetText [

	^ targetStart ifNil: [ '' ] ifNotNil: [ text copyFrom: targetStart to: targetStop ]
]

{ #category : 'accessing' }
GCovSentence >> text [

	^ text
]

{ #category : 'accessing' }
GCovSentence >> tokens [
	"The intervals of my tokens in my text"

	^ tokens
]

{ #category : 'accessing' }
GCovSentence >> verdict [

	^ verdict
]

{ #category : 'accessing' }
GCovSentence >> verdict: aVerdict [

	verdict := aVerdict
]
