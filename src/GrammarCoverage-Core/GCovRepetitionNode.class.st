"
I am a repetition instantiated: its body written as many times as I have items.
"
Class {
	#name : 'GCovRepetitionNode',
	#superclass : 'GCovNode',
	#instVars : [
		'items'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovRepetitionNode class >> expression: aRepetition items: aCollection [

	^ self new
		  expression: aRepetition;
		  setItems: aCollection;
		  yourself
]

{ #category : 'accessing' }
GCovRepetitionNode >> children [

	^ items
]

{ #category : 'testing' }
GCovRepetitionNode >> isRepetition [

	^ true
]

{ #category : 'accessing' }
GCovRepetitionNode >> items [

	^ items
]

{ #category : 'accessing' }
GCovRepetitionNode >> ownCoverageKeysDo: aBlock [
	"Two items stand for any number above one"

	aBlock value: expression occurrenceKey , '*' , (items size min: 2) printString
]

{ #category : 'accessing' }
GCovRepetitionNode >> replaceChild: aNode with: anotherNode [

	items := items collect: [ :item | item copyReplacing: aNode with: anotherNode ]
]

{ #category : 'initialization' }
GCovRepetitionNode >> setItems: aCollection [

	items := aCollection asArray
]
