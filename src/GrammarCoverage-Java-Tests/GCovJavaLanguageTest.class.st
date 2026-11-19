Class {
	#name : 'GCovJavaLanguageTest',
	#superclass : 'TestCase',
	#category : 'GrammarCoverage-Java-Tests-Tests',
	#package : 'GrammarCoverage-Java-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
GCovJavaLanguageTest >> testContextualKeywordsAreSampleGoals [

	| grammar keywords |
	grammar := GCovGrammar named: 'Test' start: #Identifier.
	(grammar addProduction: (GCovProduction named: #Identifier)) addAlternative: (GCovTerminal text: 'a').
	keywords := grammar addProduction: (GCovProduction named: #ContextualKeyword).
	#( 'record' 'var' ) do: [ :each | keywords addAlternative: (GCovTerminal text: each) ].
	self
		assert: ((GCovJavaLanguage new sampleGoalsIn: grammar) collect: [ :goal | goal key ]) asArray
		equals: #( 'Identifier=record' 'Identifier=var' )
]

{ #category : 'tests' }
GCovJavaLanguageTest >> testLineTerminatorIsNotAnInputCharacter [

	| language description |
	language := GCovJavaLanguage new.
	description := GCovDescription text: 'CR or LF'.
	self assert: (language isText: String lf excludedBy: description).
	self deny: (language isText: 'a' excludedBy: description)
]

{ #category : 'tests' }
GCovJavaLanguageTest >> testSamples [

	| language |
	language := GCovJavaLanguage new.
	self assert: (language sampleFor: (GCovDescription text: 'any Unicode character that is a "Java letter"')) equals: 'a'.
	self assert: (language sampleFor: (GCovDescription text: 'any Unicode character that is a "Java letter-or-digit"')) equals: 'a'.
	self assert: (language sampleFor: (GCovDescription text: 'the ASCII LF character, also known as "newline"')) equals: String lf.
	self
		assert: (language sampleFor: (GCovDescription text: 'the ASCII CR character followed by the ASCII LF character'))
		equals: String crlf.
	self assert: (language sampleFor: (GCovDescription text: 'unknown prose')) isNil
]
