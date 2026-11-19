"
I write a derivation tree as text. Tokens are separated by the separator of the language; the derivation of a lexical production is one token, its characters written with nothing between them. I record the span of every node and the interval of every token.
"
Class {
	#name : 'GCovRenderer',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'tokens',
		'separator'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovRenderer class >> separator: aString [

	^ self new
		  setSeparator: aString;
		  yourself
]

{ #category : 'rendering' }
GCovRenderer >> render: aRoot [
	"The text of the tree of aRoot. Afterwards every node knows its span, and my tokens are the intervals of the tokens"

	stream := WriteStream on: (String new: 256).
	tokens := OrderedCollection new.
	self write: aRoot lexical: false.
	^ stream contents
]

{ #category : 'rendering' }
GCovRenderer >> sentenceOf: aRoot [

	| text |
	text := self render: aRoot.
	^ GCovSentence root: aRoot text: text tokens: self tokens
]

{ #category : 'rendering' }
GCovRenderer >> separate [

	stream position > 0 ifTrue: [ stream nextPutAll: separator ]
]

{ #category : 'initialization' }
GCovRenderer >> setSeparator: aString [

	separator := aString
]

{ #category : 'rendering' }
GCovRenderer >> spanOf: aNode [
	"A node spans from the first character of its first child that wrote something to the last character of its last one"

	| spanned |
	spanned := aNode children select: [ :child | child start isNotNil ].
	spanned isEmpty
		ifTrue: [ aNode start: nil stop: nil ]
		ifFalse: [ aNode start: spanned first start stop: spanned last stop ]
]

{ #category : 'rendering' }
GCovRenderer >> tokens [
	"The intervals of the tokens of the last text I rendered"

	^ tokens asArray
]

{ #category : 'rendering' }
GCovRenderer >> write: aNode lexical: isLexical [

	(isLexical not and: [ aNode isDerivation and: [ aNode production isLexical ] ]) ifTrue: [
			| first |
			self separate.
			first := stream position + 1.
			aNode children do: [ :child | self write: child lexical: true ].
			stream position >= first ifTrue: [ tokens add: (first to: stream position) ].
			^ self spanOf: aNode ].
	aNode isLeaf ifTrue: [ ^ self writeLeaf: aNode lexical: isLexical ].
	aNode children do: [ :child | self write: child lexical: isLexical ].
	self spanOf: aNode
]

{ #category : 'rendering' }
GCovRenderer >> writeLeaf: aLeaf lexical: isLexical [

	| first |
	aLeaf text isEmpty ifTrue: [ ^ aLeaf start: nil stop: nil ].
	isLexical ifFalse: [ self separate ].
	first := stream position + 1.
	stream nextPutAll: aLeaf text.
	aLeaf start: first stop: stream position.
	isLexical ifFalse: [ tokens add: (first to: stream position) ]
]
