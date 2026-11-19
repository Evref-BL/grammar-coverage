"
I load Grammar Coverage. The groups:

- `core`: the generic machinery and its tests;
- `java`: the Java adapter, which reads the JLS and asks javac, and its tests (the default);
- `fastjava`: the FAST-Java target and its tests.

I do not load FAST-Java: load the version to test first, then my `fastjava` group.
"
Class {
	#name : 'BaselineOfGrammarCoverage',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGrammarCoverage',
	#package : 'BaselineOfGrammarCoverage'
}

{ #category : 'baselines' }
BaselineOfGrammarCoverage >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'GrammarCoverage-Core';
				package: 'GrammarCoverage-Core-Tests' with: [ spec requires: #( 'GrammarCoverage-Core' ) ];
				package: 'GrammarCoverage-Java' with: [ spec requires: #( 'GrammarCoverage-Core' ) ];
				package: 'GrammarCoverage-Java-Tests' with: [ spec requires: #( 'GrammarCoverage-Java' 'GrammarCoverage-Core-Tests' ) ];
				package: 'GrammarCoverage-FASTJava' with: [ spec requires: #( 'GrammarCoverage-Java' ) ];
				package: 'GrammarCoverage-FASTJava-Tests'
				with: [ spec requires: #( 'GrammarCoverage-FASTJava' 'GrammarCoverage-Core-Tests' ) ].
			spec
				group: 'core' with: #( 'GrammarCoverage-Core' 'GrammarCoverage-Core-Tests' );
				group: 'java' with: #( 'core' 'GrammarCoverage-Java' 'GrammarCoverage-Java-Tests' );
				group: 'fastjava' with: #( 'java' 'GrammarCoverage-FASTJava' 'GrammarCoverage-FASTJava-Tests' );
				group: 'default' with: #( 'java' ) ]
]
