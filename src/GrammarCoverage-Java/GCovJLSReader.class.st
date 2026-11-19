"
I read the grammar of an edition of the Java Language Specification from its HTML pages, which Oracle publishes for every edition at `docs.oracle.com/javase/specs/jls/seN/html/`.

Every production is marked up as `div.lhs` and `div.rhs`. In the right-hand side, nonterminals are links, terminals are `code.literal`, alternatives are separated by `br`, and notes in prose are `span.lineannotation`. The notation is that of JLS 2.4: `{x}`, `[x]`, `(one of)` and `but not`.

I read chapters 3 to 19, not chapter 19 alone. Chapter 19 is a recap, and in SE 25 it uses productions it does not define. A production keeps its first definition. The productions of chapter 3 are lexical: identifiers, literals and their parts.

I cache the pages in my cache directory, `jls-cache` beside the image unless told otherwise, and read them from there afterwards.

```language=text
(GCovJLSReader edition: '25') grammar.
GCovJLSReader diffFrom: '21' to: '25'.
```
"
Class {
	#name : 'GCovJLSReader',
	#superclass : 'Object',
	#instVars : [
		'edition',
		'cacheDirectory',
		'grammar'
	],
	#category : 'GrammarCoverage-Java-JLS',
	#package : 'GrammarCoverage-Java',
	#tag : 'JLS'
}

{ #category : 'instance creation' }
GCovJLSReader class >> diffFrom: anOldEdition to: aNewEdition [

	^ GCovGrammarDiff old: (self edition: anOldEdition) grammar new: (self edition: aNewEdition) grammar
]

{ #category : 'instance creation' }
GCovJLSReader class >> edition: aString [
	"aString names the edition as the specification's addresses do: '8', '17', '25'"

	^ self new
		  setEdition: aString asString;
		  yourself
]

{ #category : 'reading' }
GCovJLSReader >> addProduction: aLhs rhs: aRhs chapter: anInteger to: aGrammar [
	"A production keeps its first definition: chapter 19 repeats the others"

	| name production |
	name := (aLhs copyWithout: $:) substrings first.
	(aGrammar includesProduction: name) ifTrue: [ ^ self ].
	production := GCovProduction named: name.
	anInteger = 3 ifTrue: [ production beLexical ].
	production source: (self urlOfChapter: anInteger) , '#jls-' , name.
	(self alternativesOf: (self tokensOf: aRhs) lexical: production isLexical) do: [ :sequence | production addAlternative: sequence ].
	aGrammar addProduction: production
]

{ #category : 'reading' }
GCovJLSReader >> alternativesOf: aCollection lexical: isLexical [
	"One sequence per alternative. Under `(one of)`, every word of the literals is an alternative"

	| chunks current |
	(aCollection isNotEmpty and: [ aCollection first key = #oneOf ]) ifTrue: [
			^ (aCollection select: [ :token | token key = #literal ]) flatCollect: [ :token |
				  token value substrings collect: [ :word | GCovSequence elements: { (GCovTerminal text: word) } ] ] ].
	chunks := OrderedCollection new.
	current := OrderedCollection new.
	aCollection do: [ :token |
			token key = #break
				ifTrue: [
						chunks add: current.
						current := OrderedCollection new ]
				ifFalse: [ current add: token ] ].
	chunks add: current.
	^ (chunks reject: [ :chunk | chunk isEmpty ]) collect: [ :chunk |
		  self sequenceOf: (ReadStream on: chunk asArray) lexical: isLexical ]
]

{ #category : 'reading' }
GCovJLSReader >> annotation: aString from: aStream into: elements lexical: isLexical [
	"A note in prose: `but not` excludes what follows from the element before it, a parenthesized note comments the literal before it, anything else describes what a sampler provides"

	| text excluded |
	text := aString trimBoth.
	(text isEmpty or: [ (text beginsWith: '(') or: [ text = 'or' ] ]) ifTrue: [ ^ self ].
	(text beginsWith: 'but not') ifFalse: [ ^ elements add: (GCovDescription text: text) ].
	excluded := OrderedCollection new.
	text := (text allButFirst: 7) trimBoth.
	(#( '' 'a' 'an' ) includes: text) ifFalse: [ excluded add: (GCovDescription text: text) ].
	[ aStream atEnd not and: [ #( #ref #word #literal #comma #annotation ) includes: aStream peek key ] ] whileTrue: [
			| token |
			token := aStream next.
			(token key = #ref or: [ token key = #word ]) ifTrue: [ excluded add: (GCovReference name: token value) ].
			token key = #literal ifTrue: [ excluded addAll: (self terminalsOf: token value lexical: true) ].
			(token key = #annotation and: [ token value trimBoth ~= 'or' ]) ifTrue: [
				excluded add: (GCovDescription text: token value trimBoth) ] ].
	elements isEmpty ifTrue: [ ^ self ].
	elements add: (GCovExclusion base: elements removeLast excluded: excluded)
]

{ #category : 'tokenizing' }
GCovJLSReader >> attribute: aName of: aTag [

	| start stop |
	start := aTag indexOfSubCollection: aName , '="'.
	start = 0 ifTrue: [ ^ nil ].
	start := start + aName size + 2.
	stop := aTag indexOf: $" startingAt: start.
	^ self decode: (aTag copyFrom: start to: stop - 1)
]

{ #category : 'accessing' }
GCovJLSReader >> cacheDirectory [

	^ cacheDirectory ifNil: [ cacheDirectory := FileLocator imageDirectory / 'jls-cache' ]
]

{ #category : 'accessing' }
GCovJLSReader >> cacheDirectory: aFileReference [

	cacheDirectory := aFileReference asFileReference
]

{ #category : 'accessing' }
GCovJLSReader >> chapters [
	"Chapter 3 holds the lexical grammar, 4 to 18 the syntactic grammar, 19 its recap"

	^ 3 to: 19
]

{ #category : 'tokenizing' }
GCovJLSReader >> characterOfReference: aString [
	"A no-break space reads as a space, which is how the grammar means it"

	(aString beginsWith: '#') ifTrue: [
			| code |
			code := (aString size > 1 and: [ (aString at: 2) asLowercase = $x ])
				        ifTrue: [ Number readFrom: (aString allButFirst: 2) base: 16 ]
				        ifFalse: [ aString allButFirst asNumber ].
			^ code = 160
				  ifTrue: [ Character space ]
				  ifFalse: [ Character value: code ] ].
	^ Character value: ({
			   ('lt' -> 60).
			   ('gt' -> 62).
			   ('amp' -> 38).
			   ('quot' -> 34).
			   ('apos' -> 39).
			   ('nbsp' -> 32) } asDictionary at: aString ifAbsent: [ 63 ])
]

{ #category : 'tokenizing' }
GCovJLSReader >> decode: aString [
	"aString with its character references replaced by the characters"

	(aString includes: $&) ifFalse: [ ^ aString ].
	^ String streamContents: [ :out |
			  | stream |
			  stream := ReadStream on: aString.
			  [ stream atEnd ] whileFalse: [
					  | character |
					  character := stream next.
					  character = $&
						  ifTrue: [ out nextPut: (self characterOfReference: (stream upTo: $;)) ]
						  ifFalse: [ out nextPut: character ] ] ]
]

{ #category : 'accessing' }
GCovJLSReader >> edition [

	^ edition
]

{ #category : 'accessing' }
GCovJLSReader >> grammar [

	^ grammar ifNil: [
			  grammar := GCovGrammar named: 'JLS SE ' , edition start: #CompilationUnit.
			  self chapters do: [ :chapter | self readChapter: chapter into: grammar ].
			  grammar ]
]

{ #category : 'accessing' }
GCovJLSReader >> htmlOfChapter: anInteger [
	"The page of the chapter, from my cache once fetched"

	| file |
	file := self cacheDirectory / ('se' , edition) / ('jls-' , anInteger printString , '.html').
	file exists ifFalse: [
			file parent ensureCreateDirectory.
			file writeStreamDo: [ :stream | stream nextPutAll: (ZnClient new get: (self urlOfChapter: anInteger)) ] ].
	^ file contents
]

{ #category : 'reading' }
GCovJLSReader >> readChapter: anInteger into: aGrammar [

	self readHtml: (self htmlOfChapter: anInteger) chapter: anInteger into: aGrammar
]

{ #category : 'reading' }
GCovJLSReader >> readHtml: aString chapter: anInteger into: aGrammar [
	"Add to aGrammar the productions of the page of a chapter"

	| position |
	position := 1.
	[ (position := aString indexOfSubCollection: '<div class="lhs">' startingAt: position) > 0 ] whileTrue: [
			| lhsEnd rhsStart rhsEnd |
			lhsEnd := aString indexOfSubCollection: '</div>' startingAt: position.
			rhsStart := aString indexOfSubCollection: '<div class="rhs">' startingAt: lhsEnd.
			rhsEnd := aString indexOfSubCollection: '</div>' startingAt: rhsStart.
			self
				addProduction: (self textOf: (aString copyFrom: position + 17 to: lhsEnd - 1))
				rhs: (aString copyFrom: rhsStart + 17 to: rhsEnd - 1)
				chapter: anInteger
				to: aGrammar.
			position := rhsEnd ]
]

{ #category : 'tokenizing' }
GCovJLSReader >> readTagFrom: aStream into: tokens [

	| tag name |
	tag := aStream upTo: $>.
	name := ((tag allButFirst copyUpTo: Character space) copyWithout: $/) asLowercase.
	(tag beginsWith: '</') ifTrue: [ ^ self ].
	name = 'br' ifTrue: [ ^ tokens add: #break -> nil ].
	name = 'a' ifTrue: [
			| inner |
			inner := self textOf: (aStream upToAll: '</a>').
			^ tokens add: #ref -> ((self attribute: 'title' of: tag) ifNil: [ inner ]) ].
	(name = 'code' and: [ tag includesSubstring: 'literal' ]) ifTrue: [
		^ tokens add: #literal -> (self decode: (self stripTags: (aStream upToAll: '</code>'))) ].
	(name = 'span' and: [ tag includesSubstring: 'lineannotation' ]) ifTrue: [
		^ tokens add: #annotation -> (self textOf: (aStream upToAll: '</span>')) ]
]

{ #category : 'tokenizing' }
GCovJLSReader >> readTextFrom: aStream into: tokens [

	| text stream |
	text := String streamContents: [ :out | [ aStream atEnd or: [ aStream peek = $< ] ] whileFalse: [ out nextPut: aStream next ] ].
	stream := ReadStream on: (self decode: text).
	[ stream atEnd ] whileFalse: [
			| character |
			character := stream next.
			('{[' includes: character) ifTrue: [ tokens add: #open -> character ].
			('}]' includes: character) ifTrue: [ tokens add: #close -> character ].
			character = $, ifTrue: [ tokens add: #comma -> nil ].
			character = $( ifTrue: [ (stream upTo: $)) trimBoth = 'one of' ifTrue: [ tokens add: #oneOf -> nil ] ].
			character isLetter ifTrue: [
					tokens add: #word -> (String streamContents: [ :word |
								 word nextPut: character.
								 [ stream atEnd not and: [ stream peek isAlphaNumeric ] ] whileTrue: [ word nextPut: stream next ] ]) ] ]
]

{ #category : 'reading' }
GCovJLSReader >> sequenceOf: aStream lexical: isLexical [
	"The elements up to the end of the alternative or the bracket that closes the current one"

	| elements |
	elements := OrderedCollection new.
	[ aStream atEnd or: [ aStream peek key = #close ] ] whileFalse: [
			| token |
			token := aStream next.
			token key = #open ifTrue: [
					| body |
					body := self sequenceOf: aStream lexical: isLexical.
					aStream atEnd ifFalse: [ aStream next ].
					elements add: (token value = ${
							 ifTrue: [ GCovRepetition body: body ]
							 ifFalse: [ GCovOption body: body ]) ].
			(token key = #ref or: [ token key = #word ]) ifTrue: [ elements add: (GCovReference name: token value) ].
			token key = #literal ifTrue: [ elements addAll: (self terminalsOf: token value lexical: isLexical) ].
			token key = #annotation ifTrue: [
					self
						annotation: token value
						from: aStream
						into: elements
						lexical: isLexical ] ].
	^ GCovSequence elements: elements
]

{ #category : 'initialization' }
GCovJLSReader >> setEdition: aString [

	edition := aString
]

{ #category : 'tokenizing' }
GCovJLSReader >> stripTags: aString [

	^ String streamContents: [ :out |
			  | stream |
			  stream := ReadStream on: aString.
			  [ stream atEnd ] whileFalse: [
					  stream peek = $<
						  ifTrue: [ stream upTo: $> ]
						  ifFalse: [ out nextPut: stream next ] ] ]
]

{ #category : 'reading' }
GCovJLSReader >> terminalsOf: aString lexical: isLexical [
	"A lexical literal is characters, spaced out for reading as in `\ b`; a syntactic one is tokens"

	isLexical ifTrue: [
			| text |
			text := aString reject: [ :character | character isSeparator ].
			^ text isEmpty
				  ifTrue: [ #(  ) ]
				  ifFalse: [ { (GCovTerminal text: text) } ] ].
	^ aString substrings collect: [ :word | GCovTerminal text: word ]
]

{ #category : 'tokenizing' }
GCovJLSReader >> textOf: aString [
	"The text of an HTML fragment, its spaces collapsed"

	^ ' ' join: (self decode: (self stripTags: aString)) substrings
]

{ #category : 'tokenizing' }
GCovJLSReader >> tokensOf: aString [
	"The right-hand side as tokens, pairs of a kind and a value: #ref, #word, #literal, #annotation, #break, #open, #close, #comma, #oneOf"

	| tokens stream |
	tokens := OrderedCollection new.
	stream := ReadStream on: aString.
	[ stream atEnd ] whileFalse: [
			stream peek = $<
				ifTrue: [ self readTagFrom: stream into: tokens ]
				ifFalse: [ self readTextFrom: stream into: tokens ] ].
	^ tokens
]

{ #category : 'accessing' }
GCovJLSReader >> urlOfChapter: anInteger [

	^ 'https://docs.oracle.com/javase/specs/jls/se' , edition , '/html/jls-' , anInteger printString , '.html'
]
