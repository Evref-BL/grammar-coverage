"
I ask for an alternative to be chosen somewhere. Covering every one of me is the alternative coverage of Purdom.
"
Class {
	#name : 'GCovAlternativeGoal',
	#superclass : 'GCovGoal',
	#instVars : [
		'alternative'
	],
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'instance creation' }
GCovAlternativeGoal class >> alternative: anAlternative [

	^ self new
		  setAlternative: anAlternative;
		  yourself
]

{ #category : 'accessing' }
GCovAlternativeGoal >> alternative [

	^ alternative
]

{ #category : 'accessing' }
GCovAlternativeGoal >> buildWith: aBuilder [

	| node |
	node := aBuilder derive: alternative production alternative: alternative forcing: GCovForcing none.
	^ {
		  node.
		  node }
]

{ #category : 'accessing' }
GCovAlternativeGoal >> description [

	^ alternative production name , ': ' , alternative text
]

{ #category : 'accessing' }
GCovAlternativeGoal >> hostProduction [

	^ alternative production
]

{ #category : 'accessing' }
GCovAlternativeGoal >> key [

	^ alternative key
]

{ #category : 'accessing' }
GCovAlternativeGoal >> kind [

	^ #alternative
]

{ #category : 'initialization' }
GCovAlternativeGoal >> setAlternative: anAlternative [

	alternative := anAlternative
]
