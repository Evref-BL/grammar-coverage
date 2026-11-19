"
I am a production of a grammar: a name and its alternatives, in the order the grammar writes them.

My source says where the grammar defines me, such as the address of a section of a specification, so that a finding can cite it.
"
Class {
	#name : 'GCovProduction',
	#superclass : 'Object',
	#instVars : [
		'name',
		'alternatives',
		'isLexical',
		'source',
		'grammar'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovProduction class >> named: aName [

	^ self new
		  name: aName;
		  yourself
]

{ #category : 'adding' }
GCovProduction >> addAlternative: anExpression [
	"Answer the new alternative, whose expression is a sequence even when given a single element"

	| sequence alternative |
	sequence := anExpression isSequence
		            ifTrue: [ anExpression ]
		            ifFalse: [ GCovSequence elements: { anExpression } ].
	alternative := GCovAlternative production: self index: alternatives size + 1 expression: sequence.
	alternatives add: alternative.
	^ alternative
]

{ #category : 'accessing' }
GCovProduction >> alternativeAt: anInteger [

	^ alternatives at: anInteger
]

{ #category : 'accessing' }
GCovProduction >> alternatives [

	^ alternatives
]

{ #category : 'accessing' }
GCovProduction >> beLexical [

	isLexical := true
]

{ #category : 'accessing' }
GCovProduction >> grammar [

	^ grammar
]

{ #category : 'accessing' }
GCovProduction >> grammar: aGrammar [

	grammar := aGrammar
]

{ #category : 'initialization' }
GCovProduction >> initialize [

	super initialize.
	alternatives := OrderedCollection new.
	isLexical := false
]

{ #category : 'testing' }
GCovProduction >> isLexical [
	"Whether a sentence writes my derivations as single tokens"

	^ isLexical
]

{ #category : 'accessing' }
GCovProduction >> name [

	^ name
]

{ #category : 'accessing' }
GCovProduction >> name: aName [

	name := aName asSymbol
]

{ #category : 'printing' }
GCovProduction >> printDefinitionOn: aStream [

	aStream nextPutAll: name.
	isLexical ifTrue: [ aStream nextPutAll: ' (lexical)' ].
	aStream nextPut: $:.
	alternatives do: [ :alternative |
			aStream
				cr;
				tab;
				print: alternative expression ].
	aStream cr
]

{ #category : 'printing' }
GCovProduction >> printOn: aStream [

	aStream nextPutAll: name
]

{ #category : 'accessing' }
GCovProduction >> source [
	"Where the grammar defines me, such as the address of a section of a specification"

	^ source
]

{ #category : 'accessing' }
GCovProduction >> source: aString [

	source := aString
]
