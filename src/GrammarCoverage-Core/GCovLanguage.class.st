"
I am the part of a language adapter the generator reads: the samples of the descriptions a grammar writes in prose, the exclusions written in prose, the sample goals beyond the grammar, the separator between tokens and the extension of a source file.

My subclasses know one language. I know none: I have no samples and add no goal.
"
Class {
	#name : 'GCovLanguage',
	#superclass : 'Object',
	#category : 'GrammarCoverage-Core-Adapters',
	#package : 'GrammarCoverage-Core',
	#tag : 'Adapters'
}

{ #category : 'sampling' }
GCovLanguage >> costBiases [
	"Extra costs of entering productions, by name: the generator avoids a biased production as a context unless a goal needs it. None by default"

	^ Dictionary new
]

{ #category : 'accessing' }
GCovLanguage >> fileExtension [

	^ 'txt'
]

{ #category : 'sampling' }
GCovLanguage >> isText: aString excludedBy: aDescription [
	"Whether aString is one of the texts an exclusion written in prose refuses"

	^ false
]

{ #category : 'accessing' }
GCovLanguage >> name [

	^ 'Any language'
]

{ #category : 'sampling' }
GCovLanguage >> sampleFor: aDescription [

	^ (self samplesFor: aDescription) ifEmpty: [ nil ] ifNotEmpty: [ :samples | samples first ]
]

{ #category : 'sampling' }
GCovLanguage >> sampleGoalsIn: aGrammar [
	"Goals beyond the grammar, such as a contextual keyword written as an identifier"

	^ #(  )
]

{ #category : 'sampling' }
GCovLanguage >> samplesFor: aDescription [
	"The texts that can stand for aDescription, the most ordinary first"

	^ #(  )
]

{ #category : 'accessing' }
GCovLanguage >> tokenSeparator [
	"What a sentence writes between two tokens"

	^ ' '
]
