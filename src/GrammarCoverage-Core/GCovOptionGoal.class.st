"
I ask for an option to be taken, or left out.
"
Class {
	#name : 'GCovOptionGoal',
	#superclass : 'GCovGoal',
	#instVars : [
		'option',
		'present'
	],
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'instance creation' }
GCovOptionGoal class >> option: anOption present: aBoolean [

	^ self new
		  setOption: anOption present: aBoolean;
		  yourself
]

{ #category : 'accessing' }
GCovOptionGoal >> buildWith: aBuilder [

	| node |
	node := aBuilder derive: option production alternative: option alternative forcing: (GCovForcing presence: present of: option).
	^ {
		  node.
		  (self nodeOf: option in: node) }
]

{ #category : 'accessing' }
GCovOptionGoal >> description [

	^ option printString , (present
		   ifTrue: [ ' taken' ]
		   ifFalse: [ ' left out' ]) , ' in ' , option production name , ': ' , option alternative text
]

{ #category : 'accessing' }
GCovOptionGoal >> hostProduction [

	^ option production
]

{ #category : 'accessing' }
GCovOptionGoal >> key [

	^ option occurrenceKey , '?' , (present
		   ifTrue: [ '1' ]
		   ifFalse: [ '0' ])
]

{ #category : 'accessing' }
GCovOptionGoal >> kind [

	^ #option
]

{ #category : 'accessing' }
GCovOptionGoal >> option [

	^ option
]

{ #category : 'accessing' }
GCovOptionGoal >> present [

	^ present
]

{ #category : 'initialization' }
GCovOptionGoal >> setOption: anOption present: aBoolean [

	option := anOption.
	present := aBoolean
]
