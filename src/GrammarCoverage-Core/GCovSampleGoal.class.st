"
I ask for a lexical production to write a given text, a case the grammar does not spell out as an alternative. The language adapter adds me, for instance for a contextual keyword written as an identifier.
"
Class {
	#name : 'GCovSampleGoal',
	#superclass : 'GCovGoal',
	#instVars : [
		'production',
		'text'
	],
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'instance creation' }
GCovSampleGoal class >> production: aProduction text: aString [

	^ self new
		  setProduction: aProduction text: aString;
		  yourself
]

{ #category : 'accessing' }
GCovSampleGoal >> buildWith: aBuilder [

	| node |
	node := aBuilder sample: text of: production.
	^ {
		  node.
		  node }
]

{ #category : 'accessing' }
GCovSampleGoal >> description [

	^ production name , ' written ' , (GCovNode keyText: text)
]

{ #category : 'accessing' }
GCovSampleGoal >> hostProduction [

	^ production
]

{ #category : 'accessing' }
GCovSampleGoal >> key [

	^ production name , '=' , (GCovNode keyText: text)
]

{ #category : 'accessing' }
GCovSampleGoal >> kind [

	^ #sample
]

{ #category : 'initialization' }
GCovSampleGoal >> setProduction: aProduction text: aString [

	production := aProduction.
	text := aString
]

{ #category : 'accessing' }
GCovSampleGoal >> text [

	^ text
]
