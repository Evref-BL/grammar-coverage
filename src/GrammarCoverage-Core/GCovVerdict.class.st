"
I am what an oracle says of a sentence: accepted or not, its tree as text when accepted, and the diagnostics when not.
"
Class {
	#name : 'GCovVerdict',
	#superclass : 'Object',
	#instVars : [
		'accepted',
		'tree',
		'diagnostics'
	],
	#category : 'GrammarCoverage-Core-Adapters',
	#package : 'GrammarCoverage-Core',
	#tag : 'Adapters'
}

{ #category : 'instance creation' }
GCovVerdict class >> acceptedWithTree: aString [

	^ self new
		  setAccepted: true tree: aString diagnostics: '';
		  yourself
]

{ #category : 'instance creation' }
GCovVerdict class >> rejectedWith: aString [

	^ self new
		  setAccepted: false tree: nil diagnostics: aString;
		  yourself
]

{ #category : 'accessing' }
GCovVerdict >> diagnostics [

	^ diagnostics
]

{ #category : 'testing' }
GCovVerdict >> isAccepted [

	^ accepted
]

{ #category : 'printing' }
GCovVerdict >> printOn: aStream [

	aStream nextPutAll: (accepted
			 ifTrue: [ 'accepted' ]
			 ifFalse: [ 'rejected: ' , diagnostics ])
]

{ #category : 'initialization' }
GCovVerdict >> setAccepted: aBoolean tree: aTree diagnostics: aString [

	accepted := aBoolean.
	tree := aTree.
	diagnostics := aString
]

{ #category : 'accessing' }
GCovVerdict >> tree [
	"The tree of the sentence as text, equal for two sentences exactly when they mean the same"

	^ tree
]
