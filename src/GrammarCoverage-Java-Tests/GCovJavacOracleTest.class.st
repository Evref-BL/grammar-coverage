Class {
	#name : 'GCovJavacOracleTest',
	#superclass : 'TestCase',
	#category : 'GrammarCoverage-Java-Tests-Tests',
	#package : 'GrammarCoverage-Java-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
GCovJavacOracleTest >> oracle [
	"The oracle at the default address, or a skip when its server is not running"

	| oracle |
	oracle := GCovJavacOracle release: '25'.
	oracle isRunning ifFalse: [ self skip: 'The javac oracle is not running; start javac-oracle/run.sh' ].
	^ oracle
]

{ #category : 'tests' }
GCovJavacOracleTest >> testAccepts [

	self assert: (self oracle verdictFor: 'class A { }') isAccepted
]

{ #category : 'tests' }
GCovJavacOracleTest >> testGroupingChangesTheTree [

	| oracle |
	oracle := self oracle.
	self
		deny: (oracle verdictFor: 'class A { int f = a - (b + c); }') tree
		equals: (oracle verdictFor: 'class A { int f = a - b + c; }') tree
]

{ #category : 'tests' }
GCovJavacOracleTest >> testParenthesesDoNotChangeTheTree [

	| oracle |
	oracle := self oracle.
	self
		assert: (oracle verdictFor: 'class A { int f = (a) - (b); }') tree
		equals: (oracle verdictFor: 'class A { int f = a - b; }') tree
]

{ #category : 'tests' }
GCovJavacOracleTest >> testRejects [

	| verdict |
	verdict := self oracle verdictFor: 'class A {'.
	self deny: verdict isAccepted.
	self assert: (verdict diagnostics includesSubstring: 'compiler.err')
]

{ #category : 'tests' }
GCovJavacOracleTest >> testReleaseMatters [

	self deny: ((GCovJavacOracle release: '8' url: self oracle url) verdictFor: 'record R() { }') isAccepted
]
