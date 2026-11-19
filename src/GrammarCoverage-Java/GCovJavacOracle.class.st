"
I ask javac about Java sentences, through `javac-oracle/JavacOracle.java`, a small server of this repository that runs javac's parser at a given release.

javac accepts a sentence when its parser reports no error at my release. The tree is javac's, written without parentheses, positions or comments, with adjacent string literals left unfolded. Two sentences mean the same program exactly when their trees are equal.

I cache verdicts by text. Start the server first:

```language=text
JAVA_HOME=/path/to/jdk javac-oracle/run.sh 47811
```

```language=text
oracle := GCovJavacOracle release: '25'.
(oracle verdictFor: 'class A { }') isAccepted.
```
"
Class {
	#name : 'GCovJavacOracle',
	#superclass : 'GCovOracle',
	#instVars : [
		'url',
		'release',
		'cache',
		'version'
	],
	#category : 'GrammarCoverage-Java-Oracle',
	#package : 'GrammarCoverage-Java',
	#tag : 'Oracle'
}

{ #category : 'instance creation' }
GCovJavacOracle class >> defaultUrl [

	^ 'http://127.0.0.1:47811'
]

{ #category : 'instance creation' }
GCovJavacOracle class >> release: aString [

	^ self release: aString url: self defaultUrl
]

{ #category : 'instance creation' }
GCovJavacOracle class >> release: aString url: anUrlString [

	^ self new
		  setRelease: aString asString url: anUrlString;
		  yourself
]

{ #category : 'judging' }
GCovJavacOracle >> ask: aString [
	"The server answers `ok` or `error` on its first line, then the tree or the diagnostics"

	| answer firstLine rest |
	answer := ZnClient new
		          url: url , '/check?release=' , release;
		          entity: (ZnEntity with: aString type: ZnMimeType textPlain);
		          post;
		          contents.
	answer := answer asString.
	firstLine := answer copyUpTo: Character lf.
	rest := answer copyAfter: Character lf.
	^ firstLine = 'ok'
		  ifTrue: [ GCovVerdict acceptedWithTree: rest ]
		  ifFalse: [ GCovVerdict rejectedWith: rest trimBoth ]
]

{ #category : 'judging' }
GCovJavacOracle >> clearCache [

	cache := Dictionary new
]

{ #category : 'testing' }
GCovJavacOracle >> isRunning [

	^ [
		  ZnClient new
			  timeout: 2;
			  get: url , '/version'.
		  true ]
		  on: Error
		  do: [ :error | false ]
]

{ #category : 'judging' }
GCovJavacOracle >> name [

	^ 'javac ' , self version , ' --release ' , release
]

{ #category : 'judging' }
GCovJavacOracle >> release [

	^ release
]

{ #category : 'initialization' }
GCovJavacOracle >> setRelease: aString url: anUrlString [

	release := aString.
	url := anUrlString.
	cache := Dictionary new
]

{ #category : 'judging' }
GCovJavacOracle >> stop [
	"Stop the server"

	[ ZnClient new get: url , '/quit' ]
		on: Error
		do: [ :error | nil ]
]

{ #category : 'judging' }
GCovJavacOracle >> url [

	^ url
]

{ #category : 'judging' }
GCovJavacOracle >> verdictFor: aString [

	^ cache at: aString ifAbsentPut: [ self ask: aString ]
]

{ #category : 'judging' }
GCovJavacOracle >> version [
	"The version of the JDK the server runs"

	^ version ifNil: [ version := (ZnClient new get: url , '/version') trimBoth ]
]
