"
I am what the generator needs to know about Java beyond the JLS grammar:

- samples for the descriptions in prose of chapter 3, such as a Java letter, a line terminator or a Unicode character;
- the exclusion `but not CR or LF`;
- the smallest expression of an element value, a literal rather than `this`, since JLS 9.7.1 writes a constant there;
- sample goals: each contextual keyword spelled as an identifier, written as an identifier, where the grammar does not spell it out.

Sentences separate tokens with a space; their files end in `.java`.
"
Class {
	#name : 'GCovJavaLanguage',
	#superclass : 'GCovLanguage',
	#category : 'GrammarCoverage-Java-Language',
	#package : 'GrammarCoverage-Java',
	#tag : 'Language'
}

{ #category : 'sampling' }
GCovJavaLanguage >> costBiases [
	"An annotation element value must be a constant expression (JLS 9.7.1), so most expressions are wrong there although the grammar allows them: keep expressions out of annotations unless the goal is there. A literal as the default expression makes receivers like `0.a()`, which no type has: prefer `this`, except in an element value (see costBiasesWithin)"

	^ Dictionary new
		  at: #ElementValue put: 20;
		  at: #Literal put: 1;
		  yourself
]

{ #category : 'sampling' }
GCovJavaLanguage >> costBiasesWithin [
	"An element value is a constant expression (JLS 9.7.1), so inside one a literal is the smallest expression, not `this`"

	^ Dictionary new
		  at: #ElementValue put: (self costBiases
				   removeKey: #Literal;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
GCovJavaLanguage >> fileExtension [

	^ 'java'
]

{ #category : 'sampling' }
GCovJavaLanguage >> isText: aString excludedBy: aDescription [
	"The one exclusion of the JLS written in prose: an input character is not a line terminator"

	^ aDescription text = 'CR or LF' and: [
			  aString includesAny: {
					  Character cr.
					  Character lf } ]
]

{ #category : 'accessing' }
GCovJavaLanguage >> name [

	^ 'Java'
]

{ #category : 'sampling' }
GCovJavaLanguage >> sampleGoalsIn: aGrammar [
	"Each contextual keyword that is spelled as an identifier, written as an identifier; `non-sealed` is not one"

	| identifier keywords |
	identifier := aGrammar productionNamed: #Identifier ifAbsent: [ ^ #(  ) ].
	keywords := aGrammar
		            productionNamed: #ContextualKeyword
		            ifAbsent: [ aGrammar productionNamed: #RestrictedKeyword ifAbsent: [ ^ #(  ) ] ].
	^ (keywords alternatives select: [ :alternative |
			   alternative expression elements size = 1 and: [
					   alternative expression elements first isTerminal and: [
						   alternative expression elements first text allSatisfy: [ :character | character isLetter or: [ character = $_ ] ] ] ] ])
		  collect: [ :alternative | GCovSampleGoal production: identifier text: alternative expression elements first text ]
]

{ #category : 'sampling' }
GCovJavaLanguage >> samplesFor: aDescription [
	"Samples for the prose of JLS chapter 3, the most ordinary first; a non-ASCII letter tests what reads Unicode"

	| text |
	text := aDescription text asLowercase.
	(text includesSubstring: 'letter-or-digit') ifTrue: [
			^ {
				  'a'.
				  '0'.
				  '_'.
				  '$'.
				  (String with: (Character value: 233)) } ].
	(text includesSubstring: 'java letter') ifTrue: [
			^ {
				  'a'.
				  'Z'.
				  '$'.
				  (String with: (Character value: 233)) } ].
	(text includesSubstring: 'followed by the ascii lf') ifTrue: [ ^ { String crlf } ].
	(text includesSubstring: 'ascii lf') ifTrue: [ ^ { String lf } ].
	(text includesSubstring: 'ascii cr') ifTrue: [ ^ { String cr } ].
	(text includesSubstring: 'ascii sp') ifTrue: [ ^ { ' ' } ].
	(text includesSubstring: 'ascii ht') ifTrue: [ ^ { String tab } ].
	(text includesSubstring: 'ascii ff') ifTrue: [ ^ { (String with: Character newPage) } ].
	(text includesSubstring: 'ascii sub') ifTrue: [ ^ { (String with: (Character value: 26)) } ].
	(text includesSubstring: 'unicode character') ifTrue: [
			^ {
				  'a'.
				  (String with: (Character value: 233)).
				  (String with: (Character value: 8364)) } ].
	^ #(  )
]
