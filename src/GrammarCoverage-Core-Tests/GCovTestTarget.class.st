"
I am a system under test for tests. My one check, `test`, fails the sentences my fails block answers true for, with the message `fails`.
"
Class {
	#name : 'GCovTestTarget',
	#superclass : 'GCovTarget',
	#instVars : [
		'fails'
	],
	#category : 'GrammarCoverage-Core-Tests-Support',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Support'
}

{ #category : 'checking' }
GCovTestTarget >> check: aSentence with: anOracle [

	^ { ((fails value: aSentence text)
		   ifTrue: [ GCovCheckResult fail: #test message: 'fails' details: aSentence text ]
		   ifFalse: [ GCovCheckResult pass: #test ]) }
]

{ #category : 'checking' }
GCovTestTarget >> fails: aBlock [

	fails := aBlock
]

{ #category : 'checking' }
GCovTestTarget >> name [

	^ 'Test target'
]
