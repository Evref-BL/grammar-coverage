"
I am the sentences that failed a check with the same signature and reduce to the same smallest sentence: one cause of failure, as far as reduction tells.
"
Class {
	#name : 'GCovFailureGroup',
	#superclass : 'Object',
	#instVars : [
		'signature',
		'sentences',
		'reduced'
	],
	#category : 'GrammarCoverage-Core-Run',
	#package : 'GrammarCoverage-Core',
	#tag : 'Run'
}

{ #category : 'instance creation' }
GCovFailureGroup class >> signature: aString [

	^ self new
		  setSignature: aString;
		  yourself
]

{ #category : 'instance creation' }
GCovFailureGroup class >> signature: aString reduced: aSentence [

	^ self new
		  setSignature: aString;
		  reduced: aSentence;
		  yourself
]

{ #category : 'accessing' }
GCovFailureGroup >> add: aSentence [

	sentences add: aSentence
]

{ #category : 'accessing' }
GCovFailureGroup >> check [

	^ signature copyUpTo: $:
]

{ #category : 'accessing' }
GCovFailureGroup >> failureIn: aSentence [
	"The result of aSentence that fails with my signature"

	^ aSentence failures detect: [ :result | result signature = signature ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GCovFailureGroup >> reduced [
	"The smallest sentence found that fails with my signature"

	^ reduced ifNil: [ self smallest ]
]

{ #category : 'accessing' }
GCovFailureGroup >> reduced: aSentence [

	reduced := aSentence
]

{ #category : 'accessing' }
GCovFailureGroup >> sentences [

	^ sentences
]

{ #category : 'initialization' }
GCovFailureGroup >> setSignature: aString [

	signature := aString.
	sentences := OrderedCollection new
]

{ #category : 'accessing' }
GCovFailureGroup >> signature [

	^ signature
]

{ #category : 'accessing' }
GCovFailureGroup >> size [

	^ sentences size
]

{ #category : 'accessing' }
GCovFailureGroup >> smallest [

	^ sentences detectMin: [ :sentence | sentence text size ]
]
