"
I am `x but not y or z`: any sentence of my base whose text no excluded expression can write. Excluded expressions are terminals, references to productions with finitely many sentences, or descriptions that the language adapter judges.
"
Class {
	#name : 'GCovExclusion',
	#superclass : 'GCovExpression',
	#instVars : [
		'base',
		'excluded'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovExclusion class >> base: anExpression excluded: aCollection [

	^ self new
		  setBase: anExpression excluded: aCollection;
		  yourself
]

{ #category : 'accessing' }
GCovExclusion >> base [

	^ base
]

{ #category : 'accessing' }
GCovExclusion >> children [

	^ { base } , excluded
]

{ #category : 'generating' }
GCovExclusion >> costIn: anAnalysis [

	^ base costIn: anAnalysis
]

{ #category : 'accessing' }
GCovExclusion >> excluded [

	^ excluded
]

{ #category : 'accessing' }
GCovExclusion >> generatedChildren [

	^ { base }
]

{ #category : 'generating' }
GCovExclusion >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateExclusion: self forcing: aForcing
]

{ #category : 'testing' }
GCovExclusion >> isExclusion [

	^ true
]

{ #category : 'printing' }
GCovExclusion >> printOn: aStream [

	aStream
		print: base;
		space;
		print: (GCovDescription text: 'but not').
	excluded
		do: [ :each |
				aStream
					space;
					print: each ]
		separatedBy: [
				aStream
					space;
					print: (GCovDescription text: 'or') ]
]

{ #category : 'initialization' }
GCovExclusion >> setBase: anExpression excluded: aCollection [

	base := anExpression.
	excluded := aCollection asArray
]
