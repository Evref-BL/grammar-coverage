"Load the FAST-Java to test, then Grammar Coverage, into a fresh Moose image.

GCOV_ROOT       this repository, read as it is on disk, committed or not
GCOV_FAST_JAVA  the Metacello repository of FAST-Java, by default its v4 branch on GitHub;
                `tonel:///path/to/FAST-JAVA/src` tests a local checkout as it is on disk,
                `none` loads nothing"

| environment fastJava |
environment := Smalltalk os environment.
fastJava := environment at: 'GCOV_FAST_JAVA' ifAbsent: [ 'github://moosetechnology/FAST-JAVA:v4/src' ].
fastJava = 'none' ifFalse: [
	Metacello new
		baseline: 'FASTJava';
		repository: fastJava;
		onConflictUseIncoming;
		onWarningLog;
		load: #( 'smacc' 'tools' ) ].
Metacello new
	baseline: 'GrammarCoverage';
	repository: 'tonel://' , (environment at: 'GCOV_ROOT') , '/src';
	onWarningLog;
	load: (fastJava = 'none'
			 ifTrue: [ #( 'java' ) ]
			 ifFalse: [ #( 'fastjava' ) ])
