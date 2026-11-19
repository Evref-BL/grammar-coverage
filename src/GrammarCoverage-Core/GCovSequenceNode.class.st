"
I am a sequence instantiated: one node for each of its elements.
"
Class {
	#name : 'GCovSequenceNode',
	#superclass : 'GCovNode',
	#instVars : [
		'children'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovSequenceNode class >> expression: aSequence children: aCollection [

	^ self new
		  expression: aSequence;
		  setChildren: aCollection;
		  yourself
]

{ #category : 'accessing' }
GCovSequenceNode >> children [

	^ children
]

{ #category : 'accessing' }
GCovSequenceNode >> replaceChild: aNode with: anotherNode [

	children := children collect: [ :child | child copyReplacing: aNode with: anotherNode ]
]

{ #category : 'initialization' }
GCovSequenceNode >> setChildren: aCollection [

	children := aCollection asArray
]
