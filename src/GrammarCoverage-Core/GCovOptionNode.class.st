"
I am an option instantiated: its body written once when I have an item, not at all otherwise.
"
Class {
	#name : 'GCovOptionNode',
	#superclass : 'GCovNode',
	#instVars : [
		'item'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovOptionNode class >> expression: anOption item: aSequenceNodeOrNil [

	^ self new
		  expression: anOption;
		  setItem: aSequenceNodeOrNil;
		  yourself
]

{ #category : 'accessing' }
GCovOptionNode >> children [

	^ item ifNil: [ #(  ) ] ifNotNil: [ { item } ]
]

{ #category : 'testing' }
GCovOptionNode >> isOption [

	^ true
]

{ #category : 'accessing' }
GCovOptionNode >> item [

	^ item
]

{ #category : 'accessing' }
GCovOptionNode >> ownCoverageKeysDo: aBlock [

	aBlock value: expression occurrenceKey , '?' , (item ifNil: [ '0' ] ifNotNil: [ '1' ])
]

{ #category : 'accessing' }
GCovOptionNode >> replaceChild: aNode with: anotherNode [

	item := item ifNotNil: [ item copyReplacing: aNode with: anotherNode ]
]

{ #category : 'initialization' }
GCovOptionNode >> setItem: aSequenceNodeOrNil [

	item := aSequenceNodeOrNil
]
