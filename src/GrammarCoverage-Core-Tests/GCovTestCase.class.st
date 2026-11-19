"
I give tests a small grammar of sums:

```language=text
Expr: Term | Expr '+' Term
Term: Num | '(' Expr ')' | '-' [Term]
Num (lexical): Digit {Digit} but not '0'
Digit (lexical): '0' | '1'
```
"
Class {
	#name : 'GCovTestCase',
	#superclass : 'TestCase',
	#category : 'GrammarCoverage-Core-Tests-Support',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Support'
}

{ #category : 'testing' }
GCovTestCase class >> isAbstract [

	^ self == GCovTestCase
]

{ #category : 'fixtures' }
GCovTestCase >> generator [

	^ GCovGenerator grammar: self grammar language: GCovLanguage new
]

{ #category : 'fixtures' }
GCovTestCase >> grammar [

	| grammar |
	grammar := GCovGrammar named: 'Sums' start: #Expr.
	(grammar addProduction: (GCovProduction named: #Expr))
		addAlternative: (self ref: #Term);
		addAlternative: (self seq: {
						 (self ref: #Expr).
						 (self t: '+').
						 (self ref: #Term) }).
	(grammar addProduction: (GCovProduction named: #Term))
		addAlternative: (self ref: #Num);
		addAlternative: (self seq: {
						 (self t: '(').
						 (self ref: #Expr).
						 (self t: ')') });
		addAlternative: (self seq: {
						 (self t: '-').
						 (GCovOption body: (self seq: { (self ref: #Term) })) }).
	(grammar addProduction: (GCovProduction named: #Num))
		beLexical;
		addAlternative: (GCovExclusion
				 base: (self seq: {
								  (self ref: #Digit).
								  (GCovRepetition body: (self seq: { (self ref: #Digit) })) })
				 excluded: { (self t: '0') }).
	(grammar addProduction: (GCovProduction named: #Digit))
		beLexical;
		addAlternative: (self t: '0');
		addAlternative: (self t: '1').
	^ grammar
]

{ #category : 'fixtures' }
GCovTestCase >> ref: aName [

	^ GCovReference name: aName
]

{ #category : 'fixtures' }
GCovTestCase >> sentenceFor: aKey with: aGenerator [
	"The first candidate the generator makes for the goal of key aKey"

	| goal |
	goal := aGenerator goals detect: [ :each | each key = aKey ].
	aGenerator candidatesFor: goal do: [ :sentence | ^ sentence ].
	^ nil
]

{ #category : 'fixtures' }
GCovTestCase >> seq: aCollection [

	^ GCovSequence elements: aCollection
]

{ #category : 'fixtures' }
GCovTestCase >> t: aString [

	^ GCovTerminal text: aString
]
