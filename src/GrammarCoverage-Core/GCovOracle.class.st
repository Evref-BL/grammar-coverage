"
I judge sentences for a language: whether a reference implementation accepts one, and when it does, its tree as text, so that two sentences mean the same program exactly when their trees are equal. My subclasses answer a GCovVerdict.
"
Class {
	#name : 'GCovOracle',
	#superclass : 'Object',
	#category : 'GrammarCoverage-Core-Adapters',
	#package : 'GrammarCoverage-Core',
	#tag : 'Adapters'
}

{ #category : 'judging' }
GCovOracle >> name [

	^ self class name
]

{ #category : 'judging' }
GCovOracle >> verdictFor: aString [
	"The GCovVerdict of the reference implementation on aString"

	^ self subclassResponsibility
]
