"
I ask for a repetition to be written zero, one or two times. Two stands for many: the second item takes another alternative where it can.
"
Class {
	#name : 'GCovRepetitionGoal',
	#superclass : 'GCovGoal',
	#instVars : [
		'repetition',
		'count'
	],
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'instance creation' }
GCovRepetitionGoal class >> repetition: aRepetition count: anInteger [

	^ self new
		  setRepetition: aRepetition count: anInteger;
		  yourself
]

{ #category : 'accessing' }
GCovRepetitionGoal >> buildWith: aBuilder [

	| node |
	node := aBuilder
		        derive: repetition production
		        alternative: repetition alternative
		        forcing: (GCovForcing count: count of: repetition).
	^ {
		  node.
		  (self nodeOf: repetition in: node) }
]

{ #category : 'accessing' }
GCovRepetitionGoal >> count [

	^ count
]

{ #category : 'accessing' }
GCovRepetitionGoal >> description [

	^ repetition printString , ' written ' , (count = 2
		   ifTrue: [ 'twice or more' ]
		   ifFalse: [ count printString , ' times' ]) , ' in ' , repetition production name , ': ' , repetition alternative text
]

{ #category : 'accessing' }
GCovRepetitionGoal >> hostProduction [

	^ repetition production
]

{ #category : 'accessing' }
GCovRepetitionGoal >> key [

	^ repetition occurrenceKey , '*' , count printString
]

{ #category : 'accessing' }
GCovRepetitionGoal >> kind [

	^ #repetition
]

{ #category : 'accessing' }
GCovRepetitionGoal >> repetition [

	^ repetition
]

{ #category : 'initialization' }
GCovRepetitionGoal >> setRepetition: aRepetition count: anInteger [

	repetition := aRepetition.
	count := anInteger
]
