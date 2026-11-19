"
I build derivation trees. Everything not forced takes the smallest derivation, so that a sentence holds what its goal asks for and as little else as possible. I embed a derivation in a sentence of the start symbol by following a route of reference occurrences up to the root.

The language adapter provides the samples of descriptions and judges the exclusions written in prose. An exclusion that refuses the smallest derivation of its base makes me try the other alternatives of the base; a derivation deeper than my maximum depth is impossible.
"
Class {
	#name : 'GCovBuilder',
	#superclass : 'Object',
	#instVars : [
		'grammar',
		'analysis',
		'language',
		'depth'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovBuilder class >> grammar: aGrammar language: aLanguage [

	^ self new
		  setGrammar: aGrammar language: aLanguage;
		  yourself
]

{ #category : 'accessing' }
GCovBuilder >> analysis [

	^ analysis
]

{ #category : 'instantiating' }
GCovBuilder >> anotherInstanceOf: aSequence [
	"An instance of aSequence for an item after the first. When the sequence is a single reference, it derives another alternative where one can be derived, so that the items differ"

	| element |
	element := aSequence elements size = 1 ifTrue: [ aSequence elements first ].
	(element isNotNil and: [ element isReference and: [ element target isNotNil ] ]) ifTrue: [
			| alternatives |
			alternatives := analysis alternativesByCostOf: element target.
			alternatives size > 1 ifTrue: [
					[
						| node |
						node := self derive: element target alternativesInOrder: alternatives allButFirst.
						node expression: element.
						^ GCovSequenceNode expression: aSequence children: { node } ]
						on: GCovImpossible
						do: [ :error | error return: nil ] ] ].
	^ self instantiate: aSequence forcing: GCovForcing none
]

{ #category : 'deriving' }
GCovBuilder >> derive: aProduction alternative: anAlternative forcing: aForcing [

	| body |
	depth := depth + 1.
	[
		depth > self maxDepth ifTrue: [ GCovImpossible signal: 'A derivation deeper than ' , self maxDepth printString ].
		body := self instantiate: anAlternative expression forcing: aForcing ] ensure: [ depth := depth - 1 ].
	^ GCovDerivationNode production: aProduction alternative: anAlternative body: body
]

{ #category : 'deriving' }
GCovBuilder >> derive: aProduction alternativesInOrder: aCollection [
	"The derivation through the first of the alternatives that can be derived"

	aCollection do: [ :alternative |
			[ ^ self derive: aProduction alternative: alternative forcing: GCovForcing none ]
				on: GCovImpossible
				do: [ :error | error return: nil ] ].
	^ GCovImpossible signal: 'No alternative of ' , aProduction name , ' can be derived'
]

{ #category : 'deriving' }
GCovBuilder >> embed: aNode route: aRoute [
	"A derivation of the root of aRoute that writes aNode where the route ends"

	| node |
	node := aNode.
	aRoute reverseDo: [ :occurrence |
		node := self
			        derive: occurrence production
			        alternative: occurrence alternative
			        forcing: (GCovForcing plug: occurrence with: node) ].
	node expression: nil.
	^ node
]

{ #category : 'instantiating' }
GCovBuilder >> excludes: anExclusion text: aString [
	"Whether an excluded expression of anExclusion writes aString"

	^ anExclusion excluded anySatisfy: [ :each |
			  each isTerminal
				  ifTrue: [ each text = aString ]
				  ifFalse: [
						  each isReference
							  ifTrue: [
								  each target isNotNil and: [
									  (analysis languageOf: each target) ifNil: [ false ] ifNotNil: [ :texts | texts includes: aString ] ] ]
							  ifFalse: [ each isDescription and: [ language isText: aString excludedBy: each ] ] ] ]
]

{ #category : 'accessing' }
GCovBuilder >> grammar [

	^ grammar
]

{ #category : 'instantiating' }
GCovBuilder >> instantiate: anExpression forcing: aForcing [

	^ anExpression instantiateWith: self forcing: aForcing
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateDescription: aDescription forcing: aForcing [

	| sample |
	sample := (aForcing sampleFor: aDescription) ifNil: [ language sampleFor: aDescription ].
	sample ifNil: [ GCovImpossible signal: 'No sample of ' , aDescription printString ].
	^ GCovLeafNode expression: aDescription text: sample
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateExclusion: anExclusion forcing: aForcing [
	"The first variant of the base that no excluded expression writes"

	(self variantsOf: anExclusion base forcing: aForcing) do: [ :variant |
			[
				| node |
				node := variant value.
				(self excludes: anExclusion text: node text) ifFalse: [ ^ GCovExclusionNode expression: anExclusion base: node ] ]
				on: GCovImpossible
				do: [ :error | error return: nil ] ].
	^ GCovImpossible signal: 'Every derivation tried for ' , anExclusion base printString , ' is excluded'
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateOption: anOption forcing: aForcing [

	^ GCovOptionNode
		  expression: anOption
		  item: ((aForcing presenceFor: anOption) ifTrue: [ self instantiate: anOption body forcing: aForcing ])
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateReference: aReference forcing: aForcing [

	| node |
	node := (aForcing plugFor: aReference) ifNil: [
			        aReference target ifNil: [ GCovImpossible signal: 'No production defines ' , aReference name ].
			        self shortest: aReference target ].
	node expression: aReference.
	^ node
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateRepetition: aRepetition forcing: aForcing [

	| count items |
	count := aForcing countFor: aRepetition.
	items := OrderedCollection new.
	count >= 1 ifTrue: [ items add: (self instantiate: aRepetition body forcing: aForcing) ].
	2 to: count do: [ :index | items add: (self anotherInstanceOf: aRepetition body) ].
	^ GCovRepetitionNode expression: aRepetition items: items
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateSequence: aSequence forcing: aForcing [

	^ GCovSequenceNode
		  expression: aSequence
		  children: (aSequence elements collect: [ :element | self instantiate: element forcing: aForcing ])
]

{ #category : 'instantiating' }
GCovBuilder >> instantiateTerminal: aTerminal forcing: aForcing [

	^ GCovLeafNode expression: aTerminal text: aTerminal text
]

{ #category : 'accessing' }
GCovBuilder >> language [

	^ language
]

{ #category : 'accessing' }
GCovBuilder >> maxDepth [

	^ 150
]

{ #category : 'deriving' }
GCovBuilder >> sample: aString of: aProduction [

	^ GCovDerivationNode production: aProduction sample: aString
]

{ #category : 'initialization' }
GCovBuilder >> setGrammar: aGrammar language: aLanguage [

	grammar := aGrammar.
	analysis := aGrammar analysis.
	language := aLanguage.
	depth := 0
]

{ #category : 'deriving' }
GCovBuilder >> shortest: aProduction [
	"The smallest derivation of aProduction that its exclusions allow"

	^ self derive: aProduction alternativesInOrder: (analysis alternativesByCostOf: aProduction)
]

{ #category : 'instantiating' }
GCovBuilder >> variantsOf: anExpression forcing: aForcing [
	"Blocks that each instantiate anExpression differently: the smallest way first, then with one choice changed where nothing forces it"

	| variants |
	variants := OrderedCollection with: [ self instantiate: anExpression forcing: aForcing ].
	(anExpression isReference and: [ (aForcing isPlugged: anExpression) not and: [ anExpression target isNotNil ] ]) ifTrue: [
			(analysis alternativesByCostOf: anExpression target) allButFirstDo: [ :alternative |
					variants add: [
							(self derive: anExpression target alternative: alternative forcing: GCovForcing none)
								expression: anExpression;
								yourself ] ] ].
	(anExpression isDescription and: [ (aForcing sampleFor: anExpression) isNil ]) ifTrue: [
			(language samplesFor: anExpression) allButFirstDo: [ :sample |
				variants add: [ GCovLeafNode expression: anExpression text: sample ] ] ].
	anExpression isSequence ifTrue: [
			anExpression generatedExpressionsDo: [ :inner |
					(inner isReference and: [ (aForcing isPlugged: inner) not and: [ inner target isNotNil ] ]) ifTrue: [
							(analysis alternativesByCostOf: inner target) allButFirstDo: [ :alternative |
									variants add: [
											self instantiate: anExpression forcing: (aForcing copy
													 plug: inner with: (self derive: inner target alternative: alternative forcing: GCovForcing none);
													 yourself) ] ] ].
					(inner isRepetition and: [ (aForcing isCounted: inner) not ]) ifTrue: [
							#( 1 2 ) do: [ :count |
									variants add: [
											self instantiate: anExpression forcing: (aForcing copy
													 count: count of: inner;
													 yourself) ] ] ] ] ].
	^ variants
]
