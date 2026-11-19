"
I am `[x]`: my body written once or not at all.
"
Class {
	#name : 'GCovOption',
	#superclass : 'GCovExpression',
	#instVars : [
		'body'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovOption class >> body: aSequence [

	^ self new
		  setBody: aSequence;
		  yourself
]

{ #category : 'accessing' }
GCovOption >> body [

	^ body
]

{ #category : 'accessing' }
GCovOption >> children [

	^ { body }
]

{ #category : 'generating' }
GCovOption >> costIn: anAnalysis [
	"My smallest derivation leaves my body out"

	^ 0
]

{ #category : 'generating' }
GCovOption >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateOption: self forcing: aForcing
]

{ #category : 'testing' }
GCovOption >> isOption [

	^ true
]

{ #category : 'printing' }
GCovOption >> printOn: aStream [

	aStream
		nextPut: $[;
		print: body;
		nextPut: $]
]

{ #category : 'initialization' }
GCovOption >> setBody: aSequence [

	body := aSequence
]
