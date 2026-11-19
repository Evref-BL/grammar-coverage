"
I am an element of the right-hand side of an alternative. My path locates me in my alternative, as the indices of the elements that lead to me, so an alternative and a path name one occurrence of an expression in the grammar.

My subclasses are the notation of extended BNF: a sequence, a repetition `{x}`, an option `[x]`, a reference to a production, a terminal, a description in prose of what a sampler must provide, and an exclusion `x but not y`.
"
Class {
	#name : 'GCovExpression',
	#superclass : 'Object',
	#instVars : [
		'alternative',
		'path'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'enumerating' }
GCovExpression >> allExpressionsDo: aBlock [

	aBlock value: self.
	self children do: [ :child | child allExpressionsDo: aBlock ]
]

{ #category : 'accessing' }
GCovExpression >> alternative [
	"The alternative I am an element of"

	^ alternative
]

{ #category : 'initialization' }
GCovExpression >> attachTo: anAlternative path: aString [

	alternative := anAlternative.
	path := aString.
	self children doWithIndex: [ :child :index |
			child attachTo: anAlternative path: (aString isEmpty
					 ifTrue: [ index printString ]
					 ifFalse: [ aString , '.' , index printString ]) ]
]

{ #category : 'accessing' }
GCovExpression >> children [
	"The expressions I am made of, those an exclusion refuses included"

	^ #(  )
]

{ #category : 'testing' }
GCovExpression >> contains: anExpression [
	"Whether anExpression is me or one of my descendants"

	^ anExpression alternative == alternative and: [
		  path isEmpty or: [ anExpression path = path or: [ anExpression path beginsWith: path , '.' ] ] ]
]

{ #category : 'generating' }
GCovExpression >> costIn: anAnalysis [
	"The number of leaves of my smallest derivation"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GCovExpression >> generatedChildren [
	"The expressions a derivation of mine instantiates"

	^ self children
]

{ #category : 'enumerating' }
GCovExpression >> generatedExpressionsDo: aBlock [

	aBlock value: self.
	self generatedChildren do: [ :child | child generatedExpressionsDo: aBlock ]
]

{ #category : 'generating' }
GCovExpression >> instantiateWith: aBuilder forcing: aForcing [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GCovExpression >> isDescription [

	^ false
]

{ #category : 'testing' }
GCovExpression >> isExclusion [

	^ false
]

{ #category : 'testing' }
GCovExpression >> isOption [

	^ false
]

{ #category : 'testing' }
GCovExpression >> isReference [

	^ false
]

{ #category : 'testing' }
GCovExpression >> isRepetition [

	^ false
]

{ #category : 'testing' }
GCovExpression >> isSequence [

	^ false
]

{ #category : 'testing' }
GCovExpression >> isTerminal [

	^ false
]

{ #category : 'accessing' }
GCovExpression >> occurrenceKey [
	"My alternative and my path, which name this occurrence of me in the grammar"

	^ alternative key , '@' , path
]

{ #category : 'accessing' }
GCovExpression >> path [
	"The indices of the elements that lead from my alternative to me, such as `2.1`; empty for the alternative's own sequence"

	^ path
]

{ #category : 'accessing' }
GCovExpression >> production [

	^ alternative production
]
