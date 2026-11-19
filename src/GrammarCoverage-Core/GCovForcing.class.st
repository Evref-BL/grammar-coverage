"
I am what a derivation must contain beyond the smallest one: a node to plug at a reference occurrence, a number of items for a repetition, an option taken or not, a sample for a description. A repetition or an option that encloses something I force is written once, so that what I force appears.
"
Class {
	#name : 'GCovForcing',
	#superclass : 'Object',
	#instVars : [
		'plugs',
		'counts',
		'presences',
		'samples'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovForcing class >> count: anInteger of: aRepetition [

	^ self new
		  count: anInteger of: aRepetition;
		  yourself
]

{ #category : 'instance creation' }
GCovForcing class >> none [

	^ self new
]

{ #category : 'instance creation' }
GCovForcing class >> plug: anOccurrence with: aNode [

	^ self new
		  plug: anOccurrence with: aNode;
		  yourself
]

{ #category : 'instance creation' }
GCovForcing class >> presence: aBoolean of: anOption [

	^ self new
		  presence: aBoolean of: anOption;
		  yourself
]

{ #category : 'instance creation' }
GCovForcing class >> sample: aString for: aDescription [

	^ self new
		  sample: aString for: aDescription;
		  yourself
]

{ #category : 'accessing' }
GCovForcing >> count: anInteger of: aRepetition [

	counts at: aRepetition put: anInteger
]

{ #category : 'accessing' }
GCovForcing >> countFor: aRepetition [
	"The number of items to write: as forced, else one when I force something inside, else none"

	^ counts at: aRepetition ifAbsent: [
			  (self forcesInside: aRepetition)
				  ifTrue: [ 1 ]
				  ifFalse: [ 0 ] ]
]

{ #category : 'accessing' }
GCovForcing >> forcesInside: anExpression [
	"Whether I force a strict descendant of anExpression"

	^ plugs keys , counts keys , presences keys , samples keys anySatisfy: [ :each |
		  each ~~ anExpression and: [ anExpression contains: each ] ]
]

{ #category : 'initialization' }
GCovForcing >> initialize [

	super initialize.
	plugs := IdentityDictionary new.
	counts := IdentityDictionary new.
	presences := IdentityDictionary new.
	samples := IdentityDictionary new
]

{ #category : 'copying' }
GCovForcing >> isCounted: aRepetition [

	^ counts includesKey: aRepetition
]

{ #category : 'copying' }
GCovForcing >> isPlugged: anOccurrence [

	^ plugs includesKey: anOccurrence
]

{ #category : 'accessing' }
GCovForcing >> plug: anOccurrence with: aNode [

	plugs at: anOccurrence put: aNode
]

{ #category : 'accessing' }
GCovForcing >> plugFor: anOccurrence [

	^ plugs at: anOccurrence ifAbsent: [ nil ]
]

{ #category : 'copying' }
GCovForcing >> postCopy [

	super postCopy.
	plugs := plugs copy.
	counts := counts copy.
	presences := presences copy.
	samples := samples copy
]

{ #category : 'accessing' }
GCovForcing >> presence: aBoolean of: anOption [

	presences at: anOption put: aBoolean
]

{ #category : 'accessing' }
GCovForcing >> presenceFor: anOption [

	^ presences at: anOption ifAbsent: [ self forcesInside: anOption ]
]

{ #category : 'accessing' }
GCovForcing >> sample: aString for: aDescription [

	samples at: aDescription put: aString
]

{ #category : 'accessing' }
GCovForcing >> sampleFor: aDescription [

	^ samples at: aDescription ifAbsent: [ nil ]
]
