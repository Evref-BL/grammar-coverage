"
I am a part of the grammar written in prose, such as ""any Unicode character that is a Java letter"". The language adapter provides samples of what I describe.
"
Class {
	#name : 'GCovDescription',
	#superclass : 'GCovExpression',
	#instVars : [
		'text'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovDescription class >> text: aString [

	^ self new
		  setText: aString;
		  yourself
]

{ #category : 'generating' }
GCovDescription >> costIn: anAnalysis [

	^ 1
]

{ #category : 'generating' }
GCovDescription >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateDescription: self forcing: aForcing
]

{ #category : 'testing' }
GCovDescription >> isDescription [

	^ true
]

{ #category : 'printing' }
GCovDescription >> printOn: aStream [
	"Between guillemets, as the specifications write prose in a grammar"

	aStream
		nextPut: (Character value: 171);
		nextPutAll: text;
		nextPut: (Character value: 187)
]

{ #category : 'initialization' }
GCovDescription >> setText: aString [

	text := aString
]

{ #category : 'accessing' }
GCovDescription >> text [

	^ text
]
