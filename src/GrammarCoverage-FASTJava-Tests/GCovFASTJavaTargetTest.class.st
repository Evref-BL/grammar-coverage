"
I test the checks of GCovFASTJavaTarget with the first Java importer FAST lists, and an oracle whose tree of a source is its text without spaces or parentheses, which is enough for the small sources I check.
"
Class {
	#name : 'GCovFASTJavaTargetTest',
	#superclass : 'TestCase',
	#category : 'GrammarCoverage-FASTJava-Tests-Tests',
	#package : 'GrammarCoverage-FASTJava-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
GCovFASTJavaTargetTest >> importer [

	| importers |
	importers := GCovFASTJavaTarget importers.
	importers isEmpty ifTrue: [ self skip: 'No Java importer of FAST is loaded' ].
	^ importers first new
]

{ #category : 'helpers' }
GCovFASTJavaTargetTest >> resultsOf: aSentence with: aTarget [

	^ (aTarget check: aSentence with: GCovTestOracle new) collect: [ :result | result check -> result state ]
]

{ #category : 'helpers' }
GCovFASTJavaTargetTest >> sentence: aString [
	"A sentence whose tokens are the words of aString, which separates them by single spaces"

	| tokens start sentence |
	tokens := OrderedCollection new.
	start := 1.
	(aString substrings: ' ') do: [ :word |
			tokens add: (start to: start + word size - 1).
			start := start + word size + 1 ].
	sentence := GCovSentence root: nil text: aString tokens: tokens asArray.
	sentence verdict: (GCovTestOracle new verdictFor: aString).
	^ sentence
]

{ #category : 'tests' }
GCovFASTJavaTargetTest >> testChecksPass [

	self
		assert: (self resultsOf: (self sentence: 'class A { int f ; }') with: (GCovFASTJavaTarget importer: self importer))
		equals: {
				(#import -> #passed).
				(#positions -> #passed).
				(#meaning -> #passed).
				(#comments -> #skipped) } asOrderedCollection
]

{ #category : 'tests' }
GCovFASTJavaTargetTest >> testCommentedText [

	| commented |
	commented := GCovFASTJavaTarget new commentedTextOf: (self sentence: 'class A { }').
	self assert: commented key equals: '/*c1*/ class /*c2*/ A /*c3*/ { /*c4*/ } //c5' , String lf.
	self assert: commented value equals: #( '/*c1*/' '/*c2*/' '/*c3*/' '/*c4*/' '//c5' )
]

{ #category : 'tests' }
GCovFASTJavaTargetTest >> testDifference [

	| difference |
	difference := GCovFASTJavaTarget new
		              differenceBetween: (String lf join: #( '(CLASS' '  getMembers=[' '    (METHOD' '      getName="f")])' ))
		              and: (String lf join: #( '(CLASS' '  getMembers=[' '    (METHOD' '      getName="g")])' )).
	self assert: difference equals: '(CLASS > getMembers=[ > (METHOD: getName="f")]) became getName="g")])'
]

{ #category : 'tests' }
GCovFASTJavaTargetTest >> testImportFailure [

	| results |
	results := (GCovFASTJavaTarget importer: (GCovBlockImporter named: 'failing' block: [ :source :model | self error: 'no' ]))
		           check: (self sentence: 'class A { }')
		           with: GCovTestOracle new.
	self assert: results size equals: 1.
	self assert: results first isFailure.
	self assert: results first message equals: 'the importer raised Error'
]

{ #category : 'tests' }
GCovFASTJavaTargetTest >> testMeaningChanged [

	| sentence result |
	sentence := self sentence: 'class A { }'.
	sentence verdict: (GCovVerdict acceptedWithTree: 'classB{}').
	result := (GCovFASTJavaTarget importer: self importer) check: sentence with: GCovTestOracle new.
	self assert: (result detect: [ :each | each check = #meaning ]) isFailure
]

{ #category : 'tests' }
GCovFASTJavaTargetTest >> testPositionInsideAToken [
	"Told that `int f` is one token, the check sees the type end inside it"

	| sentence result |
	sentence := self sentence: 'class A { int f ; }'.
	sentence setRoot: nil text: sentence text tokens: {
			(1 to: 5).
			(7 to: 7).
			(9 to: 9).
			(11 to: 15).
			(17 to: 17).
			(19 to: 19) }.
	result := (GCovFASTJavaTarget importer: self importer)
		          checkPositionsOf: (self importer parse: sentence text into: nil)
		          in: sentence.
	self assert: result isFailure.
	self assert: (result message includesSubstring: 'inside a token')
]
