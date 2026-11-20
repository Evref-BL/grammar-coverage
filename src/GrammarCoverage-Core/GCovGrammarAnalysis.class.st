"
I compute what the generator needs to know about a grammar, as in Purdom's sentence generator:

- the cost of each production, the number of leaves of its smallest derivation, and the alternatives in order of cost;
- for a root production, the cheapest way to reach every other production from it, which is the route a derivation takes to embed a production in a sentence;
- the finite languages, the set of every sentence of a production that has finitely many, which decide exclusions.

A production none of whose derivations ends has an infinite cost and is never generated.
"
Class {
	#name : 'GCovGrammarAnalysis',
	#superclass : 'Object',
	#instVars : [
		'grammar',
		'costs',
		'references',
		'reaches',
		'languages',
		'waypointRoutes',
		'biases'
	],
	#category : 'GrammarCoverage-Core-Analysis',
	#package : 'GrammarCoverage-Core',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
GCovGrammarAnalysis class >> on: aGrammar [

	^ self new
		  setGrammar: aGrammar;
		  yourself
]

{ #category : 'instance creation' }
GCovGrammarAnalysis class >> on: aGrammar biases: aDictionary [
	"An analysis that weighs entering a production by aDictionary rather than by the biases of aGrammar"

	^ self new
		  setGrammar: aGrammar biases: aDictionary;
		  yourself
]

{ #category : 'costs' }
GCovGrammarAnalysis >> alternativesByCostOf: aProduction [
	"The alternatives whose derivations can end, cheapest first, in the order of the grammar between equals"

	^ (aProduction alternatives select: [ :alternative | (self costOfAlternative: alternative) < self infinity ]) sort: [ :a :b |
			  | costA costB |
			  costA := self costOfAlternative: a.
			  costB := self costOfAlternative: b.
			  costA < costB or: [ costA = costB and: [ a index <= b index ] ] ]
]

{ #category : 'costs' }
GCovGrammarAnalysis >> biasOf: aName [
	"The extra cost of entering the production named aName: by my own biases when I have some, by those of the grammar otherwise"

	^ biases
		  ifNil: [ grammar biasOf: aName ]
		  ifNotNil: [ biases at: aName asSymbol ifAbsent: [ 0 ] ]
]

{ #category : 'initialization' }
GCovGrammarAnalysis >> computeCosts [
	"A fixpoint: a production costs as much as its cheapest alternative, and a reference as much as its production"

	| changed |
	costs := Dictionary new.
	[
		changed := false.
		grammar productions do: [ :production |
				| cost |
				cost := production alternatives
					        inject: self infinity
					        into: [ :min :alternative | min min: (self costOfAlternative: alternative) ].
				cost < (self costOf: production) ifTrue: [
						costs at: production name put: cost.
						changed := true ] ].
		changed ] whileTrue
]

{ #category : 'languages' }
GCovGrammarAnalysis >> computeLanguageOf: aProduction [

	| texts |
	texts := Set new.
	aProduction alternatives do: [ :alternative |
			texts addAll: ((self languageOfExpression: alternative expression) ifNil: [ ^ nil ]).
			texts size > self maxLanguageSize ifTrue: [ ^ nil ] ].
	^ texts
]

{ #category : 'initialization' }
GCovGrammarAnalysis >> computeReferences [

	references := Dictionary new.
	grammar productions do: [ :production |
			production alternatives do: [ :alternative |
				alternative references do: [ :reference |
					(references at: reference name ifAbsentPut: [ OrderedCollection new ]) add: reference ] ] ]
]

{ #category : 'routes' }
GCovGrammarAnalysis >> computeWaypointRoutesTo: aProduction [

	| start fromStart candidates seen routes |
	start := grammar startProduction.
	fromStart := self reachFrom: start.
	candidates := OrderedCollection new.
	grammar productions do: [ :waypoint |
			(waypoint ~~ start and: [ waypoint ~~ aProduction and: [ (fromStart includes: waypoint) and: [ self isProductive: waypoint ] ] ])
				ifTrue: [
						| down |
						down := self reachFrom: waypoint.
						(down includes: aProduction) ifTrue: [
							candidates add: (fromStart costTo: waypoint) + (down costTo: aProduction) -> waypoint ] ] ].
	candidates sort: [ :a :b | a key <= b key ].
	seen := Set new.
	routes := OrderedCollection new.
	candidates do: [ :each |
			| route |
			route := (fromStart routeTo: each value) , ((self reachFrom: each value) routeTo: aProduction).
			(seen includes: route) ifFalse: [
					seen add: route.
					routes add: route ] ].
	^ routes
]

{ #category : 'costs' }
GCovGrammarAnalysis >> costOf: aProduction [

	^ costs at: aProduction name ifAbsent: [ self infinity ]
]

{ #category : 'costs' }
GCovGrammarAnalysis >> costOfAlternative: anAlternative [

	^ anAlternative expression costIn: self
]

{ #category : 'costs' }
GCovGrammarAnalysis >> costOfReference: aReference [
	"The cost of the production referenced, and the bias of entering it"

	^ aReference target
		  ifNil: [ self infinity ]
		  ifNotNil: [ :production | (self costOf: production) + (self biasOf: production name) min: self infinity ]
]

{ #category : 'costs' }
GCovGrammarAnalysis >> costOfSequence: aSequence [

	^ (aSequence elements inject: 0 into: [ :sum :element | sum + (element costIn: self) ]) min: self infinity
]

{ #category : 'costs' }
GCovGrammarAnalysis >> forcedCostOf: anOccurrence [
	"The cost of the alternative of anOccurrence when its derivation writes anOccurrence, without the cost of anOccurrence itself"

	^ self forcedCostOf: anOccurrence alternative expression toward: anOccurrence
]

{ #category : 'costs' }
GCovGrammarAnalysis >> forcedCostOf: anExpression toward: anOccurrence [

	anExpression == anOccurrence ifTrue: [ ^ 0 ].
	anExpression isSequence ifTrue: [
			^ (anExpression elements inject: 0 into: [ :sum :element |
					   sum + ((element contains: anOccurrence)
						    ifTrue: [ self forcedCostOf: element toward: anOccurrence ]
						    ifFalse: [ element costIn: self ]) ]) min: self infinity ].
	^ self forcedCostOf: (anExpression generatedChildren detect: [ :child | child contains: anOccurrence ]) toward: anOccurrence
]

{ #category : 'accessing' }
GCovGrammarAnalysis >> grammar [

	^ grammar
]

{ #category : 'costs' }
GCovGrammarAnalysis >> infinity [
	"The cost of a production none of whose derivations ends"

	^ SmallInteger maxVal // 4
]

{ #category : 'costs' }
GCovGrammarAnalysis >> isProductive: aProduction [
	"Whether some derivation of aProduction ends"

	^ (self costOf: aProduction) < self infinity
]

{ #category : 'languages' }
GCovGrammarAnalysis >> languageOf: aProduction [
	"Every text of aProduction when it has finitely many, nil otherwise"

	^ languages
		  at: aProduction name
		  ifAbsent: [ "A production that reaches itself is infinite: the guard answers nil while it is computed"
				  languages at: aProduction name put: nil.
				  languages at: aProduction name put: (self computeLanguageOf: aProduction) ]
]

{ #category : 'languages' }
GCovGrammarAnalysis >> languageOfExpression: anExpression [

	anExpression isTerminal ifTrue: [ ^ Set with: anExpression text ].
	anExpression isReference ifTrue: [ ^ anExpression target ifNotNil: [ :production | self languageOf: production ] ].
	anExpression isOption ifTrue: [ ^ (self languageOfExpression: anExpression body) ifNotNil: [ :texts | texts copyWith: '' ] ].
	anExpression isSequence ifFalse: [ ^ nil ].
	^ anExpression elements inject: (Set with: '') into: [ :texts :element |
			  texts ifNotNil: [
					  (self languageOfExpression: element) ifNotNil: [ :more |
							  texts size * more size > self maxLanguageSize ifFalse: [
								  (texts flatCollect: [ :prefix | more collect: [ :suffix | prefix , suffix ] ]) asSet ] ] ] ]
]

{ #category : 'languages' }
GCovGrammarAnalysis >> maxLanguageSize [

	^ 10000
]

{ #category : 'routes' }
GCovGrammarAnalysis >> occurrenceRoutesTo: aProduction [
	"The routes from the start symbol that reach aProduction through each of its reference occurrences, cheapest first"

	| fromStart candidates |
	fromStart := self reachFrom: grammar startProduction.
	candidates := OrderedCollection new.
	(self referencesTo: aProduction) do: [ :occurrence |
			| cost |
			(fromStart includes: occurrence production) ifTrue: [
					cost := (fromStart costTo: occurrence production) + (self forcedCostOf: occurrence).
					cost < self infinity ifTrue: [ candidates add: cost -> occurrence ] ] ].
	candidates sort: [ :a :b | a key <= b key ].
	^ candidates collect: [ :each | (fromStart routeTo: each value production) , { each value } ]
]

{ #category : 'routes' }
GCovGrammarAnalysis >> reachFrom: aProduction [

	^ reaches at: aProduction name ifAbsentPut: [ GCovReach analysis: self root: aProduction ]
]

{ #category : 'routes' }
GCovGrammarAnalysis >> reachableProductions [
	"The productions a sentence of the start symbol can contain, in the order of the grammar"

	| reach |
	reach := self reachFrom: grammar startProduction.
	^ grammar productions select: [ :production | reach includes: production ]
]

{ #category : 'routes' }
GCovGrammarAnalysis >> referencesTo: aProduction [
	"The reference occurrences of aProduction that derivations instantiate"

	^ references at: aProduction name ifAbsent: [ #(  ) ]
]

{ #category : 'routes' }
GCovGrammarAnalysis >> routeFrom: aRoot to: aProduction [

	^ (self reachFrom: aRoot) routeTo: aProduction
]

{ #category : 'initialization' }
GCovGrammarAnalysis >> setGrammar: aGrammar [

	self setGrammar: aGrammar biases: nil
]

{ #category : 'initialization' }
GCovGrammarAnalysis >> setGrammar: aGrammar biases: aDictionary [

	grammar := aGrammar.
	biases := aDictionary.
	reaches := Dictionary new.
	languages := Dictionary new.
	waypointRoutes := Dictionary new.
	self computeCosts.
	self computeReferences
]

{ #category : 'routes' }
GCovGrammarAnalysis >> waypointRoutesTo: aProduction [
	"The routes from the start symbol down to aProduction through each production that can reach it, cheapest first"

	^ waypointRoutes at: aProduction name ifAbsentPut: [ self computeWaypointRoutesTo: aProduction ]
]
