"
I am the outcome of one check on one sentence: passed, failed or skipped. A failure's message is what it shares with other failures of the same cause, without the names and numbers of its sentence; the details hold those. My signature groups failures.
"
Class {
	#name : 'GCovCheckResult',
	#superclass : 'Object',
	#instVars : [
		'check',
		'state',
		'message',
		'details'
	],
	#category : 'GrammarCoverage-Core-Adapters',
	#package : 'GrammarCoverage-Core',
	#tag : 'Adapters'
}

{ #category : 'instance creation' }
GCovCheckResult class >> fail: aCheck message: aMessage details: aString [

	^ self new
		  setCheck: aCheck
		  state: #failed
		  message: aMessage
		  details: aString;
		  yourself
]

{ #category : 'instance creation' }
GCovCheckResult class >> pass: aCheck [

	^ self new
		  setCheck: aCheck
		  state: #passed
		  message: ''
		  details: '';
		  yourself
]

{ #category : 'instance creation' }
GCovCheckResult class >> skip: aCheck reason: aString [

	^ self new
		  setCheck: aCheck
		  state: #skipped
		  message: aString
		  details: '';
		  yourself
]

{ #category : 'accessing' }
GCovCheckResult >> check [

	^ check
]

{ #category : 'accessing' }
GCovCheckResult >> details [

	^ details
]

{ #category : 'testing' }
GCovCheckResult >> isFailure [

	^ state = #failed
]

{ #category : 'testing' }
GCovCheckResult >> isPass [

	^ state = #passed
]

{ #category : 'testing' }
GCovCheckResult >> isSkipped [

	^ state = #skipped
]

{ #category : 'accessing' }
GCovCheckResult >> message [

	^ message
]

{ #category : 'printing' }
GCovCheckResult >> printOn: aStream [

	aStream
		nextPutAll: check;
		space;
		nextPutAll: state.
	message isEmpty ifFalse: [
			aStream
				nextPutAll: ': ';
				nextPutAll: message ]
]

{ #category : 'initialization' }
GCovCheckResult >> setCheck: aCheck state: aState message: aMessage details: aString [

	check := aCheck.
	state := aState.
	message := aMessage.
	details := aString
]

{ #category : 'accessing' }
GCovCheckResult >> signature [
	"The check and its message, numbers left out, which failures of the same cause share"

	^ check , ': ' , (message copyWithRegex: '[0-9]+' matchesReplacedWith: '#')
]

{ #category : 'accessing' }
GCovCheckResult >> state [

	^ state
]
