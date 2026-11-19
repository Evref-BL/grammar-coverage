"
I am a context-free grammar in extended BNF: named productions, each a list of alternatives, and the name of the start symbol.

A production is lexical when its sentences are tokens, such as identifiers and literals. A sentence writes the derivation of a lexical production as a single token, with nothing between its characters.

```language=text
grammar := GCovGrammar named: 'Expressions' start: #Expression.
```
"
Class {
	#name : 'GCovGrammar',
	#superclass : 'Object',
	#instVars : [
		'name',
		'start',
		'productions',
		'analysis',
		'biases'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovGrammar class >> named: aString start: aSymbol [

	^ self new
		  name: aString;
		  start: aSymbol;
		  yourself
]

{ #category : 'adding' }
GCovGrammar >> addProduction: aProduction [

	productions at: aProduction name put: aProduction.
	aProduction grammar: self.
	analysis := nil.
	^ aProduction
]

{ #category : 'accessing' }
GCovGrammar >> alternatives [

	^ self productions flatCollect: [ :production | production alternatives ]
]

{ #category : 'accessing' }
GCovGrammar >> analysis [
	"The costs and routes the generator reads, computed once the grammar is complete"

	^ analysis ifNil: [ analysis := GCovGrammarAnalysis on: self ]
]

{ #category : 'accessing' }
GCovGrammar >> biasOf: aName [

	^ biases ifNil: [ 0 ] ifNotNil: [ biases at: aName asSymbol ifAbsent: [ 0 ] ]
]

{ #category : 'accessing' }
GCovGrammar >> biases: aDictionary [
	"Extra costs of entering productions, by name, which steer the smallest derivations and routes away from them: a language adapter sets them, for a context that accepts less than the grammar says"

	biases := aDictionary.
	analysis := nil
]

{ #category : 'printing' }
GCovGrammar >> grammarText [
	"One production per paragraph and one alternative per line, a form that diffs well between two versions of the grammar"

	^ String streamContents: [ :stream |
		  self productions do: [ :production | production printDefinitionOn: stream ] separatedBy: [ stream cr ] ]
]

{ #category : 'testing' }
GCovGrammar >> includesProduction: aName [

	^ productions includesKey: aName asSymbol
]

{ #category : 'initialization' }
GCovGrammar >> initialize [

	super initialize.
	productions := OrderedDictionary new
]

{ #category : 'accessing' }
GCovGrammar >> name [

	^ name
]

{ #category : 'accessing' }
GCovGrammar >> name: aString [

	name := aString
]

{ #category : 'printing' }
GCovGrammar >> printOn: aStream [

	aStream nextPutAll: (name ifNil: [ 'a grammar' ])
]

{ #category : 'accessing' }
GCovGrammar >> productionNamed: aName [

	^ productions at: aName asSymbol
]

{ #category : 'accessing' }
GCovGrammar >> productionNamed: aName ifAbsent: aBlock [

	^ productions at: aName asSymbol ifAbsent: aBlock
]

{ #category : 'accessing' }
GCovGrammar >> productions [

	^ productions values
]

{ #category : 'accessing' }
GCovGrammar >> start [

	^ start
]

{ #category : 'accessing' }
GCovGrammar >> start: aSymbol [

	start := aSymbol asSymbol.
	analysis := nil
]

{ #category : 'accessing' }
GCovGrammar >> startProduction [

	^ self productionNamed: start
]

{ #category : 'validating' }
GCovGrammar >> undefinedReferences [
	"The names that alternatives reference and no production defines"

	| names |
	names := Set new.
	self alternatives do: [ :alternative |
			alternative expression allExpressionsDo: [ :expression |
				(expression isReference and: [ (self includesProduction: expression name) not ]) ifTrue: [ names add: expression name ] ] ].
	^ names asArray sort
]
