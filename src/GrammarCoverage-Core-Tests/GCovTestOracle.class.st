"
I am an oracle for tests. I accept every sentence my rejects block does not refuse, and my tree of a sentence is its text without spaces.
"
Class {
	#name : 'GCovTestOracle',
	#superclass : 'GCovOracle',
	#instVars : [
		'rejects'
	],
	#category : 'GrammarCoverage-Core-Tests-Support',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Support'
}

{ #category : 'judging' }
GCovTestOracle >> rejects: aBlock [

	rejects := aBlock
]

{ #category : 'judging' }
GCovTestOracle >> verdictFor: aString [

	^ (rejects isNotNil and: [ rejects value: aString ])
		  ifTrue: [ GCovVerdict rejectedWith: 'refused' ]
		  ifFalse: [ GCovVerdict acceptedWithTree: (aString reject: [ :character | character isSeparator ]) ]
]
