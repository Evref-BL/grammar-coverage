"
I ask for one sample of a description, such as a non-ASCII letter for ""any Unicode character that is a Java letter"".
"
Class {
	#name : 'GCovDescriptionGoal',
	#superclass : 'GCovGoal',
	#instVars : [
		'description',
		'sample'
	],
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'instance creation' }
GCovDescriptionGoal class >> description: aDescription sample: aString [

	^ self new
		  setDescription: aDescription sample: aString;
		  yourself
]

{ #category : 'accessing' }
GCovDescriptionGoal >> buildWith: aBuilder [

	| node |
	node := aBuilder
		        derive: description production
		        alternative: description alternative
		        forcing: (GCovForcing sample: sample for: description).
	^ {
		  node.
		  (self nodeOf: description in: node) }
]

{ #category : 'accessing' }
GCovDescriptionGoal >> description [

	^ (GCovNode keyText: sample) , ' for ' , description printString , ' in ' , description production name , ': '
	  , description alternative text
]

{ #category : 'accessing' }
GCovDescriptionGoal >> hostProduction [

	^ description production
]

{ #category : 'accessing' }
GCovDescriptionGoal >> key [

	^ description occurrenceKey , '=' , (GCovNode keyText: sample)
]

{ #category : 'accessing' }
GCovDescriptionGoal >> kind [

	^ #description
]

{ #category : 'accessing' }
GCovDescriptionGoal >> sample [

	^ sample
]

{ #category : 'initialization' }
GCovDescriptionGoal >> setDescription: aDescription sample: aString [

	description := aDescription.
	sample := aString
]
