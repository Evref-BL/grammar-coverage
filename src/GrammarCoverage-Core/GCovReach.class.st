"
I am the cheapest route from a root production to every production it can reach. The cost of reaching a production counts the leaves a sentence of the root needs around it; my route to a production lists the reference occurrences a derivation goes through, from the root down.
"
Class {
	#name : 'GCovReach',
	#superclass : 'Object',
	#instVars : [
		'analysis',
		'root',
		'costs',
		'via'
	],
	#category : 'GrammarCoverage-Core-Analysis',
	#package : 'GrammarCoverage-Core',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
GCovReach class >> analysis: anAnalysis root: aProduction [

	^ self new
		  setAnalysis: anAnalysis root: aProduction;
		  yourself
]

{ #category : 'initialization' }
GCovReach >> compute [
	"Dijkstra's algorithm: a reference occurrence costs what its alternative needs around it"

	| settled pending |
	settled := Set new.
	costs at: root name put: 0.
	pending := Set with: root.
	[ pending isEmpty ] whileFalse: [
			| current |
			current := pending detectMin: [ :production | costs at: production name ].
			pending remove: current.
			settled add: current name.
			(analysis isProductive: current) ifTrue: [ self relaxFrom: current settled: settled pending: pending ] ]
]

{ #category : 'accessing' }
GCovReach >> costTo: aProduction [
	"The leaves a sentence of my root needs around aProduction"

	^ costs at: aProduction name
]

{ #category : 'accessing' }
GCovReach >> includes: aProduction [

	^ costs includesKey: aProduction name
]

{ #category : 'initialization' }
GCovReach >> relaxFrom: aProduction settled: settled pending: pending [

	| base |
	base := costs at: aProduction name.
	aProduction alternatives do: [ :alternative |
			(analysis costOfAlternative: alternative) < analysis infinity ifTrue: [
					alternative references do: [ :occurrence |
							occurrence target ifNotNil: [ :target |
									| cost |
									cost := base + (analysis forcedCostOf: occurrence) + (analysis biasOf: target name).
									((settled includes: target name) not and: [ cost < (costs at: target name ifAbsent: [ analysis infinity ]) ]) ifTrue: [
											costs at: target name put: cost.
											via at: target name put: occurrence.
											pending add: target ] ] ] ] ]
]

{ #category : 'accessing' }
GCovReach >> root [

	^ root
]

{ #category : 'accessing' }
GCovReach >> routeTo: aProduction [
	"The reference occurrences from my root down to aProduction, or nil when my root cannot reach it"

	| route current |
	(self includes: aProduction) ifFalse: [ ^ nil ].
	route := OrderedCollection new.
	current := aProduction name.
	[ current = root name ] whileFalse: [
			| occurrence |
			occurrence := via at: current.
			route addFirst: occurrence.
			current := occurrence production name ].
	^ route asArray
]

{ #category : 'initialization' }
GCovReach >> setAnalysis: anAnalysis root: aProduction [

	analysis := anAnalysis.
	root := aProduction.
	costs := Dictionary new.
	via := Dictionary new.
	self compute
]
