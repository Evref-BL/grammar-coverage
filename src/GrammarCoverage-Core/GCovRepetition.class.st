"
I am `{x}`: my body written zero or more times.
"
Class {
	#name : 'GCovRepetition',
	#superclass : 'GCovExpression',
	#instVars : [
		'body'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovRepetition class >> body: aSequence [

	^ self new
		  setBody: aSequence;
		  yourself
]

{ #category : 'accessing' }
GCovRepetition >> body [

	^ body
]

{ #category : 'accessing' }
GCovRepetition >> children [

	^ { body }
]

{ #category : 'generating' }
GCovRepetition >> costIn: anAnalysis [
	"My smallest derivation writes my body no time"

	^ 0
]

{ #category : 'generating' }
GCovRepetition >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateRepetition: self forcing: aForcing
]

{ #category : 'testing' }
GCovRepetition >> isRepetition [

	^ true
]

{ #category : 'printing' }
GCovRepetition >> printOn: aStream [

	aStream
		nextPut: ${;
		print: body;
		nextPut: $}
]

{ #category : 'initialization' }
GCovRepetition >> setBody: aSequence [

	body := aSequence
]
