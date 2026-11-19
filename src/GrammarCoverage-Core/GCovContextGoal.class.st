"
I ask for an alternative of a production to be chosen at one given occurrence of a reference to it. Covering every one of me is the context-dependent branch coverage of Laemmel.
"
Class {
	#name : 'GCovContextGoal',
	#superclass : 'GCovGoal',
	#instVars : [
		'occurrence',
		'alternative'
	],
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'instance creation' }
GCovContextGoal class >> occurrence: aReference alternative: anAlternative [

	^ self new
		  setOccurrence: aReference alternative: anAlternative;
		  yourself
]

{ #category : 'accessing' }
GCovContextGoal >> alternative [

	^ alternative
]

{ #category : 'accessing' }
GCovContextGoal >> buildWith: aBuilder [

	| inner outer |
	inner := aBuilder derive: alternative production alternative: alternative forcing: GCovForcing none.
	outer := aBuilder
		         derive: occurrence production
		         alternative: occurrence alternative
		         forcing: (GCovForcing plug: occurrence with: inner).
	^ {
		  outer.
		  inner }
]

{ #category : 'accessing' }
GCovContextGoal >> description [

	^ alternative production name , ': ' , alternative text , ', where ' , occurrence production name , ': '
	  , occurrence alternative text , ' writes it at ' , occurrence path
]

{ #category : 'accessing' }
GCovContextGoal >> hostProduction [

	^ occurrence production
]

{ #category : 'accessing' }
GCovContextGoal >> key [

	^ occurrence occurrenceKey , '>' , alternative index printString
]

{ #category : 'accessing' }
GCovContextGoal >> kind [

	^ #context
]

{ #category : 'accessing' }
GCovContextGoal >> occurrence [

	^ occurrence
]

{ #category : 'accessing' }
GCovContextGoal >> productions [

	^ {
		  self hostProduction.
		  alternative production }
]

{ #category : 'initialization' }
GCovContextGoal >> setOccurrence: aReference alternative: anAlternative [

	occurrence := aReference.
	alternative := anAlternative
]
