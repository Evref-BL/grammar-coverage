"
I am an exclusion instantiated: a derivation of its base whose text no excluded expression writes.
"
Class {
	#name : 'GCovExclusionNode',
	#superclass : 'GCovNode',
	#instVars : [
		'base'
	],
	#category : 'GrammarCoverage-Core-Derivation',
	#package : 'GrammarCoverage-Core',
	#tag : 'Derivation'
}

{ #category : 'instance creation' }
GCovExclusionNode class >> expression: anExclusion base: aNode [

	^ self new
		  expression: anExclusion;
		  setBase: aNode;
		  yourself
]

{ #category : 'accessing' }
GCovExclusionNode >> base [

	^ base
]

{ #category : 'accessing' }
GCovExclusionNode >> children [

	^ { base }
]

{ #category : 'accessing' }
GCovExclusionNode >> replaceChild: aNode with: anotherNode [

	base := base copyReplacing: aNode with: anotherNode
]

{ #category : 'initialization' }
GCovExclusionNode >> setBase: aNode [

	base := aNode
]
