Class {
	#name : 'GCovJLSReaderTest',
	#superclass : 'TestCase',
	#category : 'GrammarCoverage-Java-Tests-Tests',
	#package : 'GrammarCoverage-Java-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
GCovJLSReaderTest >> alternativesOf: aName in: aGrammar [

	^ ((aGrammar productionNamed: aName) alternatives collect: [ :alternative | alternative text ]) asArray
]

{ #category : 'helpers' }
GCovJLSReaderTest >> grammarOf: aCollection chapter: anInteger [

	| grammar |
	grammar := GCovGrammar named: 'Test' start: #A.
	(GCovJLSReader edition: 'test') readHtml: (self page: aCollection) chapter: anInteger into: grammar.
	^ grammar
]

{ #category : 'helpers' }
GCovJLSReaderTest >> page: aCollection [
	"A chapter page with a production for each pair of a left-hand side and a right-hand side"

	^ String streamContents: [ :stream |
			  aCollection do: [ :pair |
					  stream
						  nextPutAll: '<div class="production"><div class="lhs">';
						  nextPutAll: pair key;
						  nextPutAll: ':</div><div class="rhs">';
						  nextPutAll: pair value;
						  nextPutAll: '</div></div>' ] ]
]

{ #category : 'tests' }
GCovJLSReaderTest >> testDescription [

	| grammar |
	grammar := self
		           grammarOf: { ('A' -> '<span class="lineannotation">any Unicode character that is a "Java letter"</span>') }
		           chapter: 3.
	self assert: (grammar productionNamed: #A) alternatives first expression elements first isDescription
]

{ #category : 'tests' }
GCovJLSReaderTest >> testExclusion [

	| grammar alternative |
	grammar := self
		           grammarOf: { ('A'
			            ->
			            '<a title="B">B</a> <span class="lineannotation">but not</span> <code class="literal">permits</code>, <span class="lineannotation">or</span> <a title="C">C</a>') }
		           chapter: 3.
	alternative := (grammar productionNamed: #A) alternatives first.
	self assert: alternative expression elements first isExclusion.
	self
		assert: (alternative expression elements first excluded collect: [ :each | each printString ]) asArray
		equals: #( '''permits''' 'C' )
]

{ #category : 'tests' }
GCovJLSReaderTest >> testExclusionInProse [

	| grammar exclusion |
	grammar := self grammarOf: { ('A' -> '<a title="B">B</a> <span class="lineannotation">but not CR or LF</span>') } chapter: 3.
	exclusion := (grammar productionNamed: #A) alternatives first expression elements first.
	self assert: exclusion excluded first isDescription.
	self assert: exclusion excluded first text equals: 'CR or LF'
]

{ #category : 'tests' }
GCovJLSReaderTest >> testFirstDefinitionWins [

	| grammar reader |
	grammar := GCovGrammar named: 'Test' start: #A.
	reader := GCovJLSReader edition: 'test'.
	reader readHtml: (self page: { ('A' -> '<code class="literal">x</code>') }) chapter: 8 into: grammar.
	reader readHtml: (self page: { ('A' -> '<code class="literal">y</code>') }) chapter: 19 into: grammar.
	self assert: (self alternativesOf: #A in: grammar) equals: #( '''x''' )
]

{ #category : 'tests' }
GCovJLSReaderTest >> testLexicalLiteralIsCharacters [
	"Chapter 3 spaces out the characters of a literal, as in `\ b`"

	| grammar |
	grammar := self
		           grammarOf: { ('A'
			            ->
			            '<code class="literal">\ b </code> <span class="lineannotation"> (backspace BS, Unicode <code class="literal">\u0008</code>)</span>') }
		           chapter: 3.
	self assert: (grammar productionNamed: #A) isLexical.
	self assert: (self alternativesOf: #A in: grammar) equals: #( '''\b''' )
]

{ #category : 'tests' }
GCovJLSReaderTest >> testNotation [

	| grammar |
	grammar := self
		           grammarOf: { ('A'
			            ->
			            '<a href="x" title="B">B</a> {<code class="literal">,</code> <a title="B">B</a>} [<a title="C">C</a>] <br> <code class="literal">;</code>') }
		           chapter: 8.
	self assert: (self alternativesOf: #A in: grammar) equals: #( 'B {'','' B} [C]' ''';''' ).
	self deny: (grammar productionNamed: #A) isLexical
]

{ #category : 'tests' }
GCovJLSReaderTest >> testOneOf [

	| grammar |
	grammar := self
		           grammarOf:
		           { ('A'
		            ->
		            '(one of) <br> <pre class="screen"><code class="literal">= *=</code> <code class="literal">&lt;&lt;=</code></pre>') }
		           chapter: 15.
	self assert: (self alternativesOf: #A in: grammar) equals: #( '''=''' '''*=''' '''<<=''' )
]

{ #category : 'tests' }
GCovJLSReaderTest >> testSource [

	| grammar |
	grammar := self grammarOf: { ('A' -> '<code class="literal">x</code>') } chapter: 8.
	self assert: (grammar productionNamed: #A) source equals: 'https://docs.oracle.com/javase/specs/jls/setest/html/jls-8.html#jls-A'
]

{ #category : 'tests' }
GCovJLSReaderTest >> testUnlinkedNonterminal [
	"SE 25 writes ConditionalAndExpression as plain text once"

	| grammar |
	grammar := self grammarOf: { ('A' -> '<a title="A">A</a> <code class="literal">||</code> ConditionalAndExpression') } chapter: 15.
	self assert: (grammar productionNamed: #A) alternatives first expression elements last isReference
]
