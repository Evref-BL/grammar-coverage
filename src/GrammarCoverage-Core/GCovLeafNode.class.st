"
I am text a sentence writes: a terminal, or a sample of a description.
"
Class {
	#name : 'GCovLeafNode',
	#superclass : 'GCovNode',
	#instVars : [
		'text'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovLeafNode class >> expression: anExpression text: aString [

	^ self new
		  expression: anExpression;
		  setText: aString;
		  yourself
]

{ #category : 'testing' }
GCovLeafNode >> isLeaf [

	^ true
]

{ #category : 'accessing' }
GCovLeafNode >> leavesDo: aBlock [

	aBlock value: self
]

{ #category : 'accessing' }
GCovLeafNode >> ownCoverageKeysDo: aBlock [
	"A sample of a description covers that sample"

	(expression isNotNil and: [ expression isDescription ]) ifTrue: [
		aBlock value: expression occurrenceKey , '=' , (GCovNode keyText: text) ]
]

{ #category : 'printing' }
GCovLeafNode >> printOn: aStream [

	aStream print: text
]

{ #category : 'initialization' }
GCovLeafNode >> setText: aString [

	text := aString
]

{ #category : 'accessing' }
GCovLeafNode >> text [

	^ text
]
