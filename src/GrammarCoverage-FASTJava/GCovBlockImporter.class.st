"
I am an importer made of a block, for a way of importing that FAST's importer API does not offer, such as importing comments. I import with `parse:into:` like a `FASTTImporter`: my block takes the source and the model, which may be nil, and answers the model.

```language=text
GCovBlockImporter
	named: 'SmaCC with comments'
	block: [ :source :model | JavaSmaCCProgramNodeImporterVisitor new withComments; parseCodeString: source ]
```
"
Class {
	#name : 'GCovBlockImporter',
	#superclass : 'Object',
	#instVars : [
		'name',
		'block'
	],
	#category : 'GrammarCoverage-FASTJava-Target',
	#package : 'GrammarCoverage-FASTJava',
	#tag : 'Target'
}

{ #category : 'instance creation' }
GCovBlockImporter class >> named: aString block: aBlock [

	^ self new
		  setName: aString block: aBlock;
		  yourself
]

{ #category : 'importing' }
GCovBlockImporter >> name [

	^ name
]

{ #category : 'importing' }
GCovBlockImporter >> parse: aString into: aModel [

	^ block value: aString value: aModel
]

{ #category : 'printing' }
GCovBlockImporter >> printOn: aStream [

	aStream nextPutAll: name
]

{ #category : 'initialization' }
GCovBlockImporter >> setName: aString block: aBlock [

	name := aString.
	block := aBlock
]
