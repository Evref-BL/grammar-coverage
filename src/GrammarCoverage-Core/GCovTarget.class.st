"
I am the system under test for a language, such as an importer of its sources into a model. I check a sentence the oracle accepted and answer the GCovCheckResult of each check, and I map the target of a sentence to what the system made of it.
"
Class {
	#name : 'GCovTarget',
	#superclass : 'Object',
	#category : 'GrammarCoverage-Core-Adapters',
	#package : 'GrammarCoverage-Core',
	#tag : 'Adapters'
}

{ #category : 'checking' }
GCovTarget >> check: aSentence with: anOracle [
	"The GCovCheckResult of each of my checks on aSentence, which anOracle accepted. I may also set the coverage map of aSentence"

	^ self subclassResponsibility
]

{ #category : 'checking' }
GCovTarget >> check: aSentence with: anOracle only: aCheck [
	"The results of the checks aCheck needs, which reduction asks for over and over. By default, all my checks"

	^ self check: aSentence with: anOracle
]

{ #category : 'checking' }
GCovTarget >> name [

	^ self subclassResponsibility
]
