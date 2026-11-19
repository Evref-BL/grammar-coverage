"
I am the name of a production, standing for any of its sentences.
"
Class {
	#name : 'GCovReference',
	#superclass : 'GCovExpression',
	#instVars : [
		'name'
	],
	#category : 'GrammarCoverage-Core-Grammar',
	#package : 'GrammarCoverage-Core',
	#tag : 'Grammar'
}

{ #category : 'instance creation' }
GCovReference class >> name: aName [

	^ self new
		  setName: aName;
		  yourself
]

{ #category : 'generating' }
GCovReference >> costIn: anAnalysis [

	^ anAnalysis costOfReference: self
]

{ #category : 'generating' }
GCovReference >> instantiateWith: aBuilder forcing: aForcing [

	^ aBuilder instantiateReference: self forcing: aForcing
]

{ #category : 'testing' }
GCovReference >> isReference [

	^ true
]

{ #category : 'accessing' }
GCovReference >> name [

	^ name
]

{ #category : 'printing' }
GCovReference >> printOn: aStream [

	aStream nextPutAll: name
]

{ #category : 'initialization' }
GCovReference >> setName: aName [

	name := aName asSymbol
]

{ #category : 'accessing' }
GCovReference >> target [
	"The production I name, or nil when the grammar defines none"

	^ alternative production grammar productionNamed: name ifAbsent: [ nil ]
]
