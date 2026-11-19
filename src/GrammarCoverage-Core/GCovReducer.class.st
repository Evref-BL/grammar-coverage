"
I reduce a failing sentence on its derivation tree rather than its text, so every step is a sentence of the grammar. A step replaces a derivation by the smallest derivation of its production, drops an item of a repetition, or leaves out an option. A step is kept when the oracle accepts the sentence and the target still fails it with the same signature. I stop when no step is kept, or after a number of attempts.
"
Class {
	#name : 'GCovReducer',
	#superclass : 'Object',
	#instVars : [
		'builder',
		'renderer',
		'oracle',
		'target',
		'maxAttempts'
	],
	#category : 'GrammarCoverage-Core-Run',
	#package : 'GrammarCoverage-Core',
	#tag : 'Run'
}

{ #category : 'instance creation' }
GCovReducer class >> builder: aBuilder renderer: aRenderer oracle: anOracle target: aTarget [

	^ self new
		  setBuilder: aBuilder
		  renderer: aRenderer
		  oracle: anOracle
		  target: aTarget;
		  yourself
]

{ #category : 'reducing' }
GCovReducer >> isSmaller: aText than: anotherText [
	"Shorter, or as long and first in alphabetical order: reduction moves down this order, so it ends, and failures of one cause end at the same sentence"

	^ aText size < anotherText size or: [ aText size = anotherText size and: [ aText < anotherText ] ]
]

{ #category : 'reducing' }
GCovReducer >> maxAttempts: anInteger [

	maxAttempts := anInteger
]

{ #category : 'reducing' }
GCovReducer >> reduce: aSentence signature: aSignature [
	"The smallest sentence I find that the oracle accepts and the target fails with aSignature, starting from aSentence"

	| current improved attempts |
	current := aSentence.
	attempts := 0.
	[
		improved := false.
		(self stepsOf: current root) do: [ :step |
				improved ifFalse: [
						attempts := attempts + 1.
						attempts > maxAttempts ifTrue: [ ^ current ].
						(self try: step on: current signature: aSignature) ifNotNil: [ :smaller |
								current := smaller.
								improved := true ] ] ].
		improved ] whileTrue.
	^ current
]

{ #category : 'initialization' }
GCovReducer >> setBuilder: aBuilder renderer: aRenderer oracle: anOracle target: aTarget [

	builder := aBuilder.
	renderer := aRenderer.
	oracle := anOracle.
	target := aTarget.
	maxAttempts := 500
]

{ #category : 'reducing' }
GCovReducer >> stepsOf: aRoot [
	"Pairs of a node and a block answering what to put in its place: a derivation found inside it, embedded in the smallest derivation of the node's production that holds it; the smallest derivation through each alternative of its production; a repetition with an item less; an option left out"

	| steps analysis |
	steps := OrderedCollection new.
	analysis := builder analysis.
	aRoot nodesDo: [ :node |
			(node isDerivation and: [ node isSample not ]) ifTrue: [
					node body nodesDo: [ :inner |
							inner isDerivation ifTrue: [
									(analysis routeFrom: node production to: inner production) ifNotNil: [ :route |
											steps add: node -> [
													(builder embed: inner shallowCopy route: route)
														expression: node expression;
														yourself ] ] ] ].
					(analysis alternativesByCostOf: node production) do: [ :alternative |
							steps add: node -> [
									(builder derive: node production alternative: alternative forcing: GCovForcing none)
										expression: node expression;
										yourself ] ] ].
			(node isRepetition and: [ node items isNotEmpty ]) ifTrue: [
				steps add: node -> [ GCovRepetitionNode expression: node expression items: node items allButLast ] ].
			(node isOption and: [ node item isNotNil ]) ifTrue: [
				steps add: node -> [ GCovOptionNode expression: node expression item: nil ] ] ].
	^ steps
]

{ #category : 'reducing' }
GCovReducer >> try: aStep on: aSentence signature: aSignature [
	"The sentence aStep makes of aSentence when it is smaller, accepted by the oracle, and failed by the target with aSignature; nil otherwise"

	| replacement candidate verdict results |
	replacement := [ aStep value value ]
		               on: GCovImpossible
		               do: [ :error | ^ nil ].
	candidate := renderer sentenceOf: (aSentence root copyReplacing: aStep key with: replacement).
	(self isSmaller: candidate text than: aSentence text) ifFalse: [ ^ nil ].
	verdict := oracle verdictFor: candidate text.
	verdict isAccepted ifFalse: [ ^ nil ].
	candidate
		id: aSentence id;
		goal: aSentence goal;
		verdict: verdict.
	results := [ target check: candidate with: oracle only: (aSignature copyUpTo: $:) asSymbol ]
		           on: Error
		           do: [ :error | ^ nil ].
	candidate results: results.
	^ (results anySatisfy: [ :result | result isFailure and: [ result signature = aSignature ] ])
		  ifTrue: [ candidate ]
		  ifFalse: [ nil ]
]
