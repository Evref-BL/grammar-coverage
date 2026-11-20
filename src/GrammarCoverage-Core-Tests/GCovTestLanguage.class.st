"
I am a language whose biases a test sets.
"
Class {
	#name : 'GCovTestLanguage',
	#superclass : 'GCovLanguage',
	#instVars : [
		'biases',
		'biasesWithin'
	],
	#category : 'GrammarCoverage-Core-Tests-Support',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Support'
}

{ #category : 'accessing' }
GCovTestLanguage >> biases: aDictionary [

	biases := aDictionary
]

{ #category : 'accessing' }
GCovTestLanguage >> biasesWithin: aDictionary [

	biasesWithin := aDictionary
]

{ #category : 'sampling' }
GCovTestLanguage >> costBiases [

	^ biases ifNil: [ Dictionary new ]
]

{ #category : 'sampling' }
GCovTestLanguage >> costBiasesWithin [

	^ biasesWithin ifNil: [ Dictionary new ]
]
