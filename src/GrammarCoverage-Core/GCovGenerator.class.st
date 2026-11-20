"
I list the coverage goals of a grammar and the candidate sentences for each.

The kinds say which goals to list: alternatives, contexts, repetitions, options, descriptions and samples. Contexts are listed in syntactic productions only unless lexicalContexts is true. A focus, a set of production names, keeps the goals of those productions alone, such as the productions a new version of the grammar changed.

The first candidate for a goal embeds it in the smallest sentence. The next ones go through a waypoint: the smallest sentence of the start symbol that reaches the waypoint, then the smallest route from the waypoint down to the goal. A construct the reference implementation accepts in some places only, such as a statement allowed inside a switch expression alone, is reached through a waypoint that encloses it.
"
Class {
	#name : 'GCovGenerator',
	#superclass : 'Object',
	#instVars : [
		'grammar',
		'language',
		'builder',
		'kinds',
		'focus',
		'lexicalContexts',
		'maxCandidates',
		'renderer'
	],
	#category : 'GrammarCoverage-Core-Generation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Generation'
}

{ #category : 'instance creation' }
GCovGenerator class >> grammar: aGrammar language: aLanguage [

	^ self new
		  setGrammar: aGrammar language: aLanguage;
		  yourself
]

{ #category : 'goals' }
GCovGenerator >> addGoalsOf: anExpression in: aProduction to: byKind [

	anExpression isRepetition ifTrue: [
		0 to: 2 do: [ :count | (byKind at: #repetition) add: (GCovRepetitionGoal repetition: anExpression count: count) ] ].
	anExpression isOption ifTrue: [
		#( false true ) do: [ :present | (byKind at: #option) add: (GCovOptionGoal option: anExpression present: present) ] ].
	anExpression isDescription ifTrue: [
			(language samplesFor: anExpression) do: [ :sample |
				(byKind at: #description) add: (GCovDescriptionGoal description: anExpression sample: sample) ] ].
	(anExpression isReference and: [
			 (aProduction isLexical not or: [ lexicalContexts ]) and: [
				 anExpression target isNotNil and: [ grammar analysis isProductive: anExpression target ] ] ]) ifTrue: [
			(self productiveAlternativesOf: anExpression target) do: [ :alternative |
				(byKind at: #context) add: (GCovContextGoal occurrence: anExpression alternative: alternative) ] ]
]

{ #category : 'candidates' }
GCovGenerator >> buildFailureOf: aGoal [
	"Why no derivation of aGoal can be built, or nil when one can"

	[ aGoal buildWith: builder ]
		on: GCovImpossible
		do: [ :error | ^ error messageText ].
	^ nil
]

{ #category : 'accessing' }
GCovGenerator >> builder [

	^ builder
]

{ #category : 'candidates' }
GCovGenerator >> candidateFor: aGoal route: aRoute [
	"The sentence that embeds a fresh derivation for aGoal through aRoute, or nil when it cannot be built"

	^ [
		  | built sentence |
		  built := builder within: aRoute do: [ aGoal buildWith: builder ].
		  sentence := renderer sentenceOf: (builder embed: built first route: aRoute).
		  sentence
			  goal: aGoal;
			  target: built second;
			  yourself ]
		  on: GCovImpossible
		  do: [ :error | error return: nil ]
]

{ #category : 'candidates' }
GCovGenerator >> candidatesFor: aGoal do: aBlock [
	"Evaluate aBlock with each distinct candidate sentence for aGoal until it answers true or my candidates run out, and answer the number of candidates. Candidates come in this order: the smallest sentence; the smallest through each occurrence of the host production; the sentences that differ from the first by one choice; the smallest through each waypoint"

	| analysis host seen count try first |
	(self buildFailureOf: aGoal) ifNotNil: [ ^ 0 ].
	analysis := grammar analysis.
	host := aGoal hostProduction.
	seen := Set new.
	count := 0.
	first := nil.
	try := [ :sentence |
		       count >= maxCandidates ifTrue: [ ^ count ].
		       (seen includes: sentence text) ifFalse: [
				       seen add: sentence text.
				       count := count + 1.
				       (aBlock value: sentence) ifTrue: [ ^ count ] ] ].
	(analysis routeFrom: grammar startProduction to: host) ifNotNil: [ :route |
			(self candidateFor: aGoal route: route) ifNotNil: [ :sentence |
					first := sentence.
					try value: sentence ] ].
	(analysis occurrenceRoutesTo: host) do: [ :route |
			(self candidateFor: aGoal route: route) ifNotNil: [ :sentence |
					first ifNil: [ first := sentence ].
					try value: sentence ] ].
	first ifNotNil: [ self neighborsOf: first do: try ].
	(analysis waypointRoutesTo: host) do: [ :route |
		(self candidateFor: aGoal route: route) ifNotNil: [ :sentence | try value: sentence ] ].
	^ count
]

{ #category : 'accessing' }
GCovGenerator >> focus [

	^ focus
]

{ #category : 'accessing' }
GCovGenerator >> focus: aCollectionOfNames [
	"Keep the goals of these productions alone, or every goal when nil"

	focus := aCollectionOfNames ifNotNil: [ aCollectionOfNames collect: [ :each | each asSymbol ] as: Set ]
]

{ #category : 'goals' }
GCovGenerator >> goals [
	"The goals of my kinds and focus, in the order of kindsInOrder, then of the grammar"

	| analysis byKind all |
	analysis := grammar analysis.
	byKind := Dictionary new.
	self kindsInOrder do: [ :kind | byKind at: kind put: OrderedCollection new ].
	(analysis reachableProductions select: [ :production | analysis isProductive: production ]) do: [ :production |
			(self productiveAlternativesOf: production) do: [ :alternative |
					(byKind at: #alternative) add: (GCovAlternativeGoal alternative: alternative).
					alternative expression generatedExpressionsDo: [ :expression | self addGoalsOf: expression in: production to: byKind ] ] ].
	(byKind at: #sample) addAll: (language sampleGoalsIn: grammar).
	all := OrderedCollection new.
	self kindsInOrder do: [ :kind | (kinds includes: kind) ifTrue: [ all addAll: (byKind at: kind) ] ].
	focus ifNotNil: [ all := all select: [ :goal | goal productions anySatisfy: [ :production | focus includes: production name ] ] ].
	^ self withoutDuplicates: all
]

{ #category : 'accessing' }
GCovGenerator >> grammar [

	^ grammar
]

{ #category : 'candidates' }
GCovGenerator >> instancesOf: aSequence [
	"Blocks answering instances of aSequence: one per alternative when it is a single reference, the smallest one otherwise"

	| element |
	element := aSequence elements size = 1 ifTrue: [ aSequence elements first ].
	(element isNotNil and: [ element isReference and: [ element target isNotNil ] ]) ifFalse: [
		^ { [ builder instantiate: aSequence forcing: GCovForcing none ] } ].
	^ (builder analysis alternativesByCostOf: element target) collect: [ :alternative |
			  [
				  GCovSequenceNode
					  expression: aSequence
					  children: { ((builder derive: element target alternative: alternative forcing: GCovForcing none)
							   expression: element;
							   yourself) } ] ]
]

{ #category : 'accessing' }
GCovGenerator >> kinds [

	^ kinds
]

{ #category : 'accessing' }
GCovGenerator >> kinds: aCollection [
	"The kinds of goals to list, among those of kindsInOrder"

	kinds := aCollection asSet
]

{ #category : 'accessing' }
GCovGenerator >> kindsInOrder [

	^ #( #alternative #sample #description #repetition #option #context )
]

{ #category : 'accessing' }
GCovGenerator >> language [

	^ language
]

{ #category : 'accessing' }
GCovGenerator >> lexicalContexts: aBoolean [

	lexicalContexts := aBoolean
]

{ #category : 'accessing' }
GCovGenerator >> maxCandidates: anInteger [
	"The number of distinct sentences to try for a goal before giving up on it"

	maxCandidates := anInteger
]

{ #category : 'candidates' }
GCovGenerator >> neighborsOf: aSentence do: aBlock [
	"Evaluate aBlock with each sentence that differs from aSentence by one choice outside the path to its target and still covers its goal. A rejected sentence often needs one more choice near what it tests, such as a modifier the construct requires"

	| path |
	path := aSentence root pathTo: aSentence target.
	path ifNil: [ ^ self ].
	aSentence root nodesDo: [ :node |
			(node includesNode: aSentence target) ifFalse: [
					(self replacementsOf: node) do: [ :replacement |
							[
								| root sentence |
								root := aSentence root copyReplacing: node with: replacement value.
								sentence := renderer sentenceOf: root.
								(sentence coverageKeys includes: aSentence goal key) ifTrue: [
										sentence
											goal: aSentence goal;
											target: (root nodeAtPath: path).
										aBlock value: sentence ] ]
								on: GCovImpossible
								do: [ :error | error return: nil ] ] ] ]
]

{ #category : 'goals' }
GCovGenerator >> productiveAlternativesOf: aProduction [

	| analysis |
	analysis := grammar analysis.
	^ aProduction alternatives select: [ :alternative | (analysis costOfAlternative: alternative) < analysis infinity ]
]

{ #category : 'accessing' }
GCovGenerator >> renderer [

	^ renderer
]

{ #category : 'candidates' }
GCovGenerator >> replacementsOf: aNode [
	"Blocks answering what may stand for aNode: an option taken, a repetition with an item more, another alternative of a derivation"

	| replacements |
	replacements := OrderedCollection new.
	(aNode isOption and: [ aNode item isNil ]) ifTrue: [
			(self instancesOf: aNode expression body) do: [ :instance |
				replacements add: [ GCovOptionNode expression: aNode expression item: instance value ] ] ].
	(aNode isRepetition and: [ aNode items size < 2 ]) ifTrue: [
			(self instancesOf: aNode expression body) do: [ :instance |
				replacements add: [ GCovRepetitionNode expression: aNode expression items: aNode items , { instance value } ] ] ].
	(aNode isDerivation and: [ aNode isSample not and: [ aNode expression isNotNil ] ]) ifTrue: [
			((builder analysis alternativesByCostOf: aNode production) reject: [ :alternative | alternative == aNode alternative ]) do: [
					:alternative |
					replacements add: [
							(builder derive: aNode production alternative: alternative forcing: GCovForcing none)
								expression: aNode expression;
								yourself ] ] ].
	^ replacements
]

{ #category : 'accessing' }
GCovGenerator >> setGrammar: aGrammar language: aLanguage [
	"The biases of the language become those of the grammar"

	grammar := aGrammar.
	language := aLanguage.
	grammar biases: aLanguage costBiases.
	builder := GCovBuilder grammar: aGrammar language: aLanguage.
	renderer := GCovRenderer separator: aLanguage tokenSeparator.
	kinds := self kindsInOrder asSet.
	lexicalContexts := false.
	maxCandidates := 300
]

{ #category : 'goals' }
GCovGenerator >> withoutDuplicates: aCollection [

	| keys |
	keys := Set new.
	^ aCollection select: [ :goal |
			  (keys includes: goal key)
				  ifTrue: [ false ]
				  ifFalse: [
						  keys add: goal key.
						  true ] ]
]
