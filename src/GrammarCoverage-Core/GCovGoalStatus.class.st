"
I am where a goal stands after a run: covered by a sentence, rejected by the oracle in every candidate tried, impossible to build, or not tried. The detail is the oracle's diagnostics for the first candidate, or why nothing could be built.

Once the target has checked the sentences, my passing sentence is one that holds my goal and passes every check, if the run found one; a goal covered only by failing sentences fails everywhere it was tried.
"
Class {
	#name : 'GCovGoalStatus',
	#superclass : 'Object',
	#instVars : [
		'goal',
		'state',
		'sentence',
		'candidates',
		'detail',
		'passing'
	],
	#category : 'GrammarCoverage-Core-Run',
	#package : 'GrammarCoverage-Core',
	#tag : 'Run'
}

{ #category : 'instance creation' }
GCovGoalStatus class >> goal: aGoal [

	^ self new
		  setGoal: aGoal;
		  yourself
]

{ #category : 'accessing' }
GCovGoalStatus >> candidates [
	"The number of candidates tried"

	^ candidates
]

{ #category : 'accessing' }
GCovGoalStatus >> candidates: anInteger [

	candidates := anInteger
]

{ #category : 'accessing' }
GCovGoalStatus >> coverBy: aSentence [

	state := #covered.
	sentence := aSentence
]

{ #category : 'accessing' }
GCovGoalStatus >> detail [

	^ detail
]

{ #category : 'accessing' }
GCovGoalStatus >> goal [

	^ goal
]

{ #category : 'accessing' }
GCovGoalStatus >> impossible: aString [

	state := #impossible.
	detail := aString
]

{ #category : 'testing' }
GCovGoalStatus >> isCovered [

	^ state = #covered
]

{ #category : 'accessing' }
GCovGoalStatus >> outcome [
	"How the target fared on my goal: #passed when some sentence holding it passes every check, #failed when every one tried fails, nil when no sentence holds it"

	self isCovered ifFalse: [ ^ nil ].
	^ passing ifNil: [ #failed ] ifNotNil: [ #passed ]
]

{ #category : 'accessing' }
GCovGoalStatus >> passing [
	"A sentence that holds my goal and passes every check, or nil"

	^ passing
]

{ #category : 'accessing' }
GCovGoalStatus >> passing: aSentence [

	passing := aSentence
]

{ #category : 'accessing' }
GCovGoalStatus >> rejectedAfter: anInteger first: aTextAndDiagnostics [
	"The oracle refused every one of anInteger candidates; aTextAndDiagnostics is the first of them and what the oracle said of it"

	state := #rejected.
	candidates := anInteger.
	detail := aTextAndDiagnostics value , ' in: ' , aTextAndDiagnostics key
]

{ #category : 'accessing' }
GCovGoalStatus >> sentence [

	^ sentence
]

{ #category : 'initialization' }
GCovGoalStatus >> setGoal: aGoal [

	goal := aGoal.
	state := #untried.
	candidates := 0.
	detail := ''
]

{ #category : 'accessing' }
GCovGoalStatus >> state [
	"One of #untried, #covered, #rejected and #impossible"

	^ state
]
