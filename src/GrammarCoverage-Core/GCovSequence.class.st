"
I am a sequence of expressions, written one after the other. Every alternative is a sequence, and so is the body of a repetition or an option.
"
Class {
	#name : 'GCovSequence',
	#superclass : 'GCovExpression',
	#instVars : [
		'elements'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovSequence class >> elements: aCollection [

	^ self new
		  setElements: aCollection;
		  yourself
]

{ #category : 'accessing' }
GCovSequence >> children [

	^ elements
]

{ #category : 'generating' }
GCovSequence >> costIn: anAnalysis [

	^ anAnalysis costOfSequence: self
]

{ #category : 'accessing' }
GCovSequence >> elements [

	^ elements
]

{ #category : 'generating' }
GCovSequence >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateSequence: self forcing: aForcing
]

{ #category : 'testing' }
GCovSequence >> isSequence [

	^ true
]

{ #category : 'printing' }
GCovSequence >> printOn: aStream [

	elements do: [ :element | aStream print: element ] separatedBy: [ aStream space ]
]

{ #category : 'initialization' }
GCovSequence >> setElements: aCollection [

	elements := aCollection asArray
]
