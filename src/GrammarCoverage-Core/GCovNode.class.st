"
I am a node of a derivation tree: what one expression of the grammar became in a sentence. Once the sentence is rendered, my start and stop are the first and last character I wrote in it, or nil when I wrote nothing.

My coverage keys name the goals I cover: an alternative chosen, an alternative chosen at a given occurrence, a number of repetitions, an option taken or not, a sample.
"
Class {
	#name : 'GCovNode',
	#superclass : 'Object',
	#instVars : [
		'expression',
		'start',
		'stop'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'keys' }
GCovNode class >> keyText: aString [
	"aString as it can stand in a coverage key: a character that is not printable ASCII becomes its code, such as `\u000a`"

	^ String streamContents: [ :stream |
		  aString do: [ :character |
			  (character asInteger between: 33 and: 126)
				  ifTrue: [ stream nextPut: character ]
				  ifFalse: [
					  stream nextPutAll: '\u'.
					  stream nextPutAll: (character asInteger printPaddedWith: $0 to: 4 base: 16) asLowercase ] ] ]
]

{ #category : 'accessing' }
GCovNode >> children [

	^ #(  )
]

{ #category : 'copying' }
GCovNode >> copyReplacing: aNode with: anotherNode [
	"A copy of my tree where anotherNode stands for aNode; the nodes outside the path to aNode are shared"

	aNode == self ifTrue: [ ^ anotherNode ].
	(self includesNode: aNode) ifFalse: [ ^ self ].
	^ self shallowCopy replaceChild: aNode with: anotherNode
]

{ #category : 'enumerating' }
GCovNode >> coverageKeysDo: aBlock [

	self ownCoverageKeysDo: aBlock.
	self children do: [ :child | child coverageKeysDo: aBlock ]
]

{ #category : 'accessing' }
GCovNode >> expression [
	"The grammar expression I instantiate"

	^ expression
]

{ #category : 'accessing' }
GCovNode >> expression: anExpression [

	expression := anExpression
]

{ #category : 'copying' }
GCovNode >> includesNode: aNode [

	self nodesDo: [ :each | each == aNode ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
GCovNode >> isDerivation [

	^ false
]

{ #category : 'testing' }
GCovNode >> isLeaf [

	^ false
]

{ #category : 'testing' }
GCovNode >> isOption [

	^ false
]

{ #category : 'testing' }
GCovNode >> isRepetition [

	^ false
]

{ #category : 'enumerating' }
GCovNode >> leavesDo: aBlock [

	self children do: [ :child | child leavesDo: aBlock ]
]

{ #category : 'enumerating' }
GCovNode >> nodeAtPath: anArray [

	^ anArray inject: self into: [ :node :index | node children at: index ]
]

{ #category : 'enumerating' }
GCovNode >> nodesDo: aBlock [
	"Me, then my descendants, in the order the sentence writes them"

	aBlock value: self.
	self children do: [ :child | child nodesDo: aBlock ]
]

{ #category : 'enumerating' }
GCovNode >> ownCoverageKeysDo: aBlock [
	"The keys of the goals I cover myself, not through my children"

	
]

{ #category : 'enumerating' }
GCovNode >> pathTo: aNode [
	"The indices of the children that lead from me to aNode, or nil when aNode is not in my tree"

	aNode == self ifTrue: [ ^ #(  ) ].
	self children doWithIndex: [ :child :index | (child pathTo: aNode) ifNotNil: [ :path | ^ { index } , path ] ].
	^ nil
]

{ #category : 'copying' }
GCovNode >> replaceChild: aNode with: anotherNode [
	"Called on a fresh copy of me: replace aNode in my subtree"

	^ self
]

{ #category : 'accessing' }
GCovNode >> start [

	^ start
]

{ #category : 'accessing' }
GCovNode >> start: aStart stop: aStop [

	start := aStart.
	stop := aStop
]

{ #category : 'accessing' }
GCovNode >> stop [

	^ stop
]

{ #category : 'accessing' }
GCovNode >> text [
	"The text of my leaves, with nothing between them"

	^ String streamContents: [ :stream | self leavesDo: [ :leaf | stream nextPutAll: leaf text ] ]
]
