"
I am a production derived through one of its alternatives, whose expression my body instantiates. A sample derivation has no alternative: its body is the text a sample goal asks the production to write.
"
Class {
	#name : 'GCovDerivationNode',
	#superclass : 'GCovNode',
	#instVars : [
		'production',
		'alternative',
		'body',
		'isSample'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovDerivationNode class >> production: aProduction alternative: anAlternative body: aSequenceNode [

	^ self new
		  setProduction: aProduction alternative: anAlternative body: aSequenceNode;
		  yourself
]

{ #category : 'instance creation' }
GCovDerivationNode class >> production: aProduction sample: aString [
	"A derivation of aProduction that writes aString, whichever alternatives would write it"

	^ self new
		  setProduction: aProduction
		  alternative: nil
		  body: (GCovSequenceNode expression: nil children: { (GCovLeafNode expression: nil text: aString) });
		  beSample;
		  yourself
]

{ #category : 'accessing' }
GCovDerivationNode >> alternative [
	"The alternative I derive through, nil for a sample"

	^ alternative
]

{ #category : 'accessing' }
GCovDerivationNode >> beSample [

	isSample := true
]

{ #category : 'accessing' }
GCovDerivationNode >> body [

	^ body
]

{ #category : 'accessing' }
GCovDerivationNode >> children [

	^ { body }
]

{ #category : 'testing' }
GCovDerivationNode >> isDerivation [

	^ true
]

{ #category : 'testing' }
GCovDerivationNode >> isSample [

	^ isSample
]

{ #category : 'accessing' }
GCovDerivationNode >> ownCoverageKeysDo: aBlock [

	isSample ifTrue: [ ^ aBlock value: production name , '=' , (GCovNode keyText: self text) ].
	aBlock value: alternative key.
	(expression isNotNil and: [ expression isReference ]) ifTrue: [
		aBlock value: expression occurrenceKey , '>' , alternative index printString ]
]

{ #category : 'printing' }
GCovDerivationNode >> printOn: aStream [

	aStream
		nextPutAll: production name;
		nextPutAll: ' -> ';
		print: self text
]

{ #category : 'accessing' }
GCovDerivationNode >> production [

	^ production
]

{ #category : 'accessing' }
GCovDerivationNode >> replaceChild: aNode with: anotherNode [

	body := body copyReplacing: aNode with: anotherNode
]

{ #category : 'initialization' }
GCovDerivationNode >> setProduction: aProduction alternative: anAlternative body: aSequenceNode [

	production := aProduction.
	alternative := anAlternative.
	body := aSequenceNode.
	isSample := false
]
