"Print what changed in the JLS grammar between two editions, after load.st.

GCOV_OLD, GCOV_NEW  the two editions, such as `21` and `25`
GCOV_JLS_CACHE      where the JLS pages are kept between runs"

| environment old new diff |
environment := Smalltalk os environment.
old := GCovJLSReader edition: (environment at: 'GCOV_OLD').
new := GCovJLSReader edition: (environment at: 'GCOV_NEW').
(environment at: 'GCOV_JLS_CACHE' ifAbsent: [ nil ]) ifNotNil: [ :cache |
	old cacheDirectory: cache.
	new cacheDirectory: cache ].
diff := GCovGrammarDiff old: old grammar new: new grammar.
(ZnCharacterWriteStream on: Stdio stdout encoding: 'utf8')
	nextPutAll: (diff isEmpty
			 ifTrue: [ 'No production changed.' , String lf ]
			 ifFalse: [ diff printString ]);
	flush
