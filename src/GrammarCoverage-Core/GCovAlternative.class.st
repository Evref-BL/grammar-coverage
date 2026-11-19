"
I am one alternative of a production: a sequence of expressions. My key, the production name and my index, names me in coverage goals and reports.
"
Class {
	#name : 'GCovAlternative',
	#superclass : 'Object',
	#instVars : [
		'production',
		'index',
		'expression'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovAlternative class >> production: aProduction index: anInteger expression: aSequence [

	^ self new
		  setProduction: aProduction index: anInteger expression: aSequence;
		  yourself
]

{ #category : 'accessing' }
GCovAlternative >> expression [

	^ expression
]

{ #category : 'accessing' }
GCovAlternative >> index [

	^ index
]

{ #category : 'accessing' }
GCovAlternative >> key [
	"The production name and my index, which name me in goals and reports"

	^ production name , '#' , index printString
]

{ #category : 'printing' }
GCovAlternative >> printOn: aStream [

	aStream
		nextPutAll: self key;
		nextPutAll: ': ';
		print: expression
]

{ #category : 'accessing' }
GCovAlternative >> production [

	^ production
]

{ #category : 'accessing' }
GCovAlternative >> references [
	"The reference occurrences a derivation of mine instantiates, which excludes the expressions an exclusion refuses"

	| references |
	references := OrderedCollection new.
	expression generatedExpressionsDo: [ :each | each isReference ifTrue: [ references add: each ] ].
	^ references
]

{ #category : 'initialization' }
GCovAlternative >> setProduction: aProduction index: anInteger expression: aSequence [

	production := aProduction.
	index := anInteger.
	expression := aSequence.
	aSequence attachTo: self path: ''
]

{ #category : 'accessing' }
GCovAlternative >> text [

	^ expression printString
]
