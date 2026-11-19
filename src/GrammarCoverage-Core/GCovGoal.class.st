"
I am a coverage goal: something of the grammar that some sentence must write. My key is the coverage key of the node that covers me. I build a derivation of my host production that covers me; the generator embeds it in sentences of the start symbol.
"
Class {
	#name : 'GCovGoal',
	#superclass : 'Object',
	#category : 'GrammarCoverage-Core-Goals',
	#package : 'GrammarCoverage-Core',
	#tag : 'Goals'
}

{ #category : 'building' }
GCovGoal >> buildWith: aBuilder [
	"A pair: a derivation of my host production that covers me, and the node in it that covers me"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GCovGoal >> description [
	"What I ask for, for a reader"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GCovGoal >> hostProduction [
	"The production whose derivation I build, and that the generator embeds in a sentence"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GCovGoal >> key [
	"The coverage key of the node that covers me"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GCovGoal >> kind [

	^ self subclassResponsibility
]

{ #category : 'building' }
GCovGoal >> nodeOf: anExpression in: aNode [

	aNode nodesDo: [ :each | each expression == anExpression ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : 'printing' }
GCovGoal >> printOn: aStream [

	aStream nextPutAll: self key
]

{ #category : 'accessing' }
GCovGoal >> productions [
	"The productions I concern, which a focus selects me by"

	^ { self hostProduction }
]

{ #category : 'accessing' }
GCovGoal >> source [
	"Where the grammar defines my host production"

	^ self hostProduction source
]
