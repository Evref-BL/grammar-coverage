"
I am text written as is: a keyword or an operator in a syntactic production, characters in a lexical one.
"
Class {
	#name : 'GCovTerminal',
	#superclass : 'GCovExpression',
	#instVars : [
		'text'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovTerminal class >> text: aString [

	^ self new
		  setText: aString;
		  yourself
]

{ #category : 'generating' }
GCovTerminal >> costIn: anAnalysis [

	^ 1
]

{ #category : 'generating' }
GCovTerminal >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateTerminal: self forcing: aForcing
]

{ #category : 'testing' }
GCovTerminal >> isTerminal [

	^ true
]

{ #category : 'printing' }
GCovTerminal >> printOn: aStream [

	aStream print: text
]

{ #category : 'initialization' }
GCovTerminal >> setText: aString [

	text := aString
]

{ #category : 'accessing' }
GCovTerminal >> text [

	^ text
]
