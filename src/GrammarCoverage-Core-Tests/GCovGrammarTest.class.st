Class {
	#name : 'GCovGrammarTest',
	#superclass : 'GCovTestCase',
	#category : 'GrammarCoverage-Core-Tests-Tests',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
GCovGrammarTest >> testCosts [

	| grammar |
	grammar := self grammar.
	self assert: (grammar analysis costOf: (grammar productionNamed: #Expr)) equals: 1.
	self assert: (grammar analysis costOf: (grammar productionNamed: #Num)) equals: 1
]

{ #category : 'tests' }
GCovGrammarTest >> testDiff [

	| old new diff |
	old := self grammar.
	new := self grammar.
	(new productionNamed: #Term) addAlternative: (self t: 'x').
	new addProduction: (GCovProduction named: #Unused).
	diff := GCovGrammarDiff old: old new: new.
	self assert: (diff changed collect: [ :each | each name ]) asArray equals: #( #Term ).
	self assert: (diff added collect: [ :each | each name ]) asArray equals: #( #Unused ).
	self assert: diff removed isEmpty.
	self assert: diff focus equals: #( #Term #Unused ) asSet.
	self assert: (diff printString includesSubstring: '    + ''x''')
]

{ #category : 'tests' }
GCovGrammarTest >> testFiniteLanguage [

	| grammar |
	grammar := self grammar.
	self assert: (grammar analysis languageOf: (grammar productionNamed: #Digit)) equals: #( '0' '1' ) asSet.
	self assert: (grammar analysis languageOf: (grammar productionNamed: #Num)) isNil
]

{ #category : 'tests' }
GCovGrammarTest >> testGrammarText [

	self assert: (self grammar grammarText lines includes: 'Num (lexical):')
]

{ #category : 'tests' }
GCovGrammarTest >> testPathsName [

	| alternative |
	alternative := (self grammar productionNamed: #Num) alternatives first.
	self
		assert: ((alternative references collect: [ :each | each occurrenceKey ]) as: Array)
		equals: #( 'Num#1@1.1.1' 'Num#1@1.1.2.1.1' )
]

{ #category : 'tests' }
GCovGrammarTest >> testRoute [
	"The cheapest way from Expr to Digit goes through Term and Num"

	| grammar route |
	grammar := self grammar.
	route := grammar analysis routeFrom: grammar startProduction to: (grammar productionNamed: #Digit).
	self assert: (route collect: [ :each | each production name ]) equals: #( #Expr #Term #Num )
]

{ #category : 'tests' }
GCovGrammarTest >> testUndefinedReferences [

	| grammar |
	grammar := self grammar.
	self assert: grammar undefinedReferences isEmpty.
	(grammar productionNamed: #Term) addAlternative: (self ref: #Missing).
	self assert: grammar undefinedReferences equals: #( #Missing )
]
