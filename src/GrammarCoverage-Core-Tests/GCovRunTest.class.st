Class {
	#name : 'GCovRunTest',
	#superclass : 'GCovTestCase',
	#category : 'GrammarCoverage-Core-Tests-Tests',
	#package : 'GrammarCoverage-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
GCovRunTest >> runWith: anOracle target: aTarget [

	^ GCovRun new
		  label: 'Sums';
		  grammar: self grammar;
		  language: GCovLanguage new;
		  oracle: anOracle;
		  target: aTarget;
		  yourself
]

{ #category : 'tests' }
GCovRunTest >> testEveryGoalIsCovered [

	| run |
	run := self runWith: GCovTestOracle new target: nil.
	run run.
	self assert: (run statuses values allSatisfy: [ :status | status isCovered ]).
	self assert: run sentences size < run goals size
]

{ #category : 'tests' }
GCovRunTest >> testFailuresAreGroupedAndReduced [

	| run group |
	run := self runWith: GCovTestOracle new target: (GCovTestTarget new fails: [ :text | text includes: $( ]).
	run run.
	self assert: run failureGroups size equals: 1.
	group := run failureGroups first.
	self assert: group signature equals: 'test: fails'.
	self assert: group reduced text equals: '( - )'
]

{ #category : 'tests' }
GCovRunTest >> testRejectedGoal [

	| run |
	run := self runWith: (GCovTestOracle new rejects: [ :text | text includes: $( ]) target: nil.
	run run.
	self assert: (run statuses at: 'Term#2') state equals: #rejected.
	self assert: ((run statuses at: 'Term#2') detail includesSubstring: 'refused')
]

{ #category : 'tests' }
GCovRunTest >> testReport [

	| run directory |
	directory := FileSystem memory root / 'report'.
	run := self runWith: GCovTestOracle new target: (GCovTestTarget new fails: [ :text | text includes: $( ]).
	run outputDirectory: directory.
	run run.
	self assert: (directory / 'summary.md') exists.
	self assert: ((directory / 'summary.md') contents includesSubstring: '### 001. test: fails').
	self assert: (directory / 'failures' / '001.txt') contents equals: '( - )'.
	self assert: (directory / 'sentences') children size equals: run sentences size.
	self assert: (directory / 'goals.tsv') contents lines size equals: run goals size + 1
]
