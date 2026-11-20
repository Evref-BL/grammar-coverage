Class {
	#name : 'GCovGeneratorTest',
	#superclass : 'GCovTestCase',
	#category : 'GrammarCoverage-Core-Tests-Tests',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
GCovGeneratorTest >> testBiasesOfTheLanguage [
	"Num costs more than `-` alone, so a term in parentheses holds the smaller one"

	| language |
	language := GCovTestLanguage new biases: (Dictionary new at: #Num put: 5; yourself).
	self
		assert: (self sentenceFor: 'Term#2' with: (GCovGenerator grammar: self grammar language: language)) text
		equals: '( - )'
]

{ #category : 'tests' }
GCovGeneratorTest >> testBiasesWithinAProduction [
	"Inside a term, the language weighs nothing, so a term in parentheses holds a number"

	| language |
	language := GCovTestLanguage new
		            biases: (Dictionary new at: #Num put: 5; yourself);
		            biasesWithin: (Dictionary new at: #Term put: Dictionary new; yourself).
	self
		assert: (self sentenceFor: 'Term#2' with: (GCovGenerator grammar: self grammar language: language)) text
		equals: '( 1 )'
]

{ #category : 'tests' }
GCovGeneratorTest >> testContextGoalTarget [

	| sentence |
	sentence := self sentenceFor: 'Expr#2@3>2' with: self generator.
	self assert: sentence text equals: '1 + ( 1 )'.
	self assert: (sentence text copyFrom: sentence target start to: sentence target stop) equals: '( 1 )'
]

{ #category : 'tests' }
GCovGeneratorTest >> testEveryGoalHasACandidate [

	| generator |
	generator := self generator.
	generator goals do: [ :goal | self assert: (generator candidatesFor: goal do: [ :sentence | true ]) equals: 1 ]
]

{ #category : 'tests' }
GCovGeneratorTest >> testExclusionTriesAnotherDerivation [
	"The smallest number is 0, which the exclusion refuses"

	| sentence |
	sentence := self sentenceFor: 'Term#1' with: self generator.
	self assert: sentence text equals: '1'
]

{ #category : 'tests' }
GCovGeneratorTest >> testFocus [

	| generator |
	generator := self generator.
	generator focus: #( #Digit ).
	self assert: (generator goals allSatisfy: [ :goal | goal productions anySatisfy: [ :production | production name = #Digit ] ])
]

{ #category : 'tests' }
GCovGeneratorTest >> testLexicalDerivationIsOneToken [

	| sentence |
	sentence := self sentenceFor: 'Num#1@1.1.2*1' with: self generator.
	self assert: sentence text equals: '00'.
	self assert: sentence tokens equals: { (1 to: 2) }
]

{ #category : 'tests' }
GCovGeneratorTest >> testOccurrenceRoute [
	"Digit 0 alone is refused as a number: the generator reaches it through the second occurrence of Digit"

	| sentence |
	sentence := self sentenceFor: 'Digit#1' with: self generator.
	self assert: (sentence text includes: $0).
	self assert: (sentence coverageKeys includes: 'Digit#1')
]

{ #category : 'tests' }
GCovGeneratorTest >> testOracleRejectionLeadsToTheNextCandidate [

	| generator texts |
	generator := self generator.
	texts := OrderedCollection new.
	generator candidatesFor: (generator goals detect: [ :goal | goal key = 'Term#2' ]) do: [ :sentence |
			texts add: sentence text.
			false ].
	self assert: texts first equals: '( 1 )'.
	self assert: texts size > 1.
	self assert: texts asSet size equals: texts size
]

{ #category : 'tests' }
GCovGeneratorTest >> testRepetitionTwiceTakesAnotherAlternative [

	| sentence |
	sentence := self sentenceFor: 'Num#1@1.1.2*2' with: self generator.
	self assert: sentence text equals: '001'
]

{ #category : 'tests' }
GCovGeneratorTest >> testSmallestSentence [

	| sentence |
	sentence := self sentenceFor: 'Expr#2' with: self generator.
	self assert: sentence text equals: '1 + 1'.
	self assert: sentence tokens equals: {
			(1 to: 1).
			(3 to: 3).
			(5 to: 5) }
]
