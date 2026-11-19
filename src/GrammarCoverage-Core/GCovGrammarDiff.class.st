"
I compare two versions of a grammar: the productions added, removed, and changed, with the alternatives each change adds and removes. The names of the productions added or changed are a focus for a generator, so that a new version is tested where it differs.
"
Class {
	#name : 'GCovGrammarDiff',
	#superclass : 'Object',
	#instVars : [
		'old',
		'new'
	],
	#category : 'GrammarCoverage-Core-Analysis',
	#package : 'GrammarCoverage-Core',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
GCovGrammarDiff class >> old: anOldGrammar new: aNewGrammar [

	^ self new
		  setOld: anOldGrammar new: aNewGrammar;
		  yourself
]

{ #category : 'comparing' }
GCovGrammarDiff >> added [
	"The productions only the new grammar defines"

	^ new productions reject: [ :production | old includesProduction: production name ]
]

{ #category : 'comparing' }
GCovGrammarDiff >> changed [
	"The productions of the new grammar whose alternatives differ from the old ones"

	^ new productions select: [ :production |
			  (old includesProduction: production name) and: [
				  (self textsOf: production) ~= (self textsOf: (old productionNamed: production name)) ] ]
]

{ #category : 'comparing' }
GCovGrammarDiff >> focus [
	"The names of the productions added or changed, where the new grammar needs testing"

	^ self added , self changed collect: [ :production | production name ] as: Set
]

{ #category : 'testing' }
GCovGrammarDiff >> isEmpty [

	^ self added isEmpty and: [ self removed isEmpty and: [ self changed isEmpty ] ]
]

{ #category : 'printing' }
GCovGrammarDiff >> printOn: aStream [
	"`+` a production added, `-` one removed, `~` one changed with the alternatives it lost and gained"

	self added do: [ :production |
			aStream
				nextPutAll: '+ ';
				nextPutAll: production name;
				nextPutAll: ': ';
				nextPutAll: (' | ' join: (self textsOf: production));
				lf ].
	self removed do: [ :production |
			aStream
				nextPutAll: '- ';
				nextPutAll: production name;
				lf ].
	self changed do: [ :production |
			| before after |
			before := self textsOf: (old productionNamed: production name).
			after := self textsOf: production.
			aStream
				nextPutAll: '~ ';
				nextPutAll: production name;
				lf.
			before do: [ :text |
					(after includes: text) ifFalse: [
							aStream
								nextPutAll: '    - ';
								nextPutAll: text;
								lf ] ].
			after do: [ :text |
					(before includes: text) ifFalse: [
							aStream
								nextPutAll: '    + ';
								nextPutAll: text;
								lf ] ] ]
]

{ #category : 'comparing' }
GCovGrammarDiff >> removed [

	^ old productions reject: [ :production | new includesProduction: production name ]
]

{ #category : 'initialization' }
GCovGrammarDiff >> setOld: anOldGrammar new: aNewGrammar [

	old := anOldGrammar.
	new := aNewGrammar
]

{ #category : 'comparing' }
GCovGrammarDiff >> textsOf: aProduction [

	^ aProduction alternatives collect: [ :alternative | alternative text ] as: Array
]
