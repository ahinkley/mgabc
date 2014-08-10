" Vim syntax file
" Language:	Gabc gregorian chant notation
" Maintainer:	Elie Roux <elie.roux@telecom-bretagne.eu>
" Last Change:	2008 Nov 29

" Quit when a (custom) syntax file was already loaded
"if exists("b:current_syntax")
"  finish
"endif

syn match versenumber "[0-9]\+"
"syn match gabcAttributeName /^[^:]*:/
"syn match gabcAttributeNameb ";"
syn match gabcTextMarkup "</\?\w\+>" contained
"syn match gabcTranslation "\[[^\[\(]*\]\?" contained
"syn match gabcBasicNote "[a-mA-M]" contained
syn match gabcBasicNote "[a-zA-Z]" contained
"syn match gabcAlteration "[\<\>~xXyYvVoOwWqQ\-Ss\._'1234]" contained
"syn match gabcSpace "[`,;!: /zZ]" contained
syn match toneIndicator "\\[a-z0-9]\+" contained
syn region gabcNotes matchgroup=gabcNote start="(" end=")" contains=toneIndicator,gabcNotes, gabcBasicNote 
syn region gabcNotes matchgroup=gabcTextMarkup start="<" end=">" contains=toneIndicator,gabcNotes, gabcBasicNote 
"syn region text matchgroup=gabcNote start="<..\?>" end="<\/..\?>" contains=toneIndicator,gabcNotes, gabcBasicNote
"syn region gabcText start="%%" end="%%zz" contains=gabcNotes,gabcTextMarkup,gabcTranslation
syn region texHeading start="{" end="}" contains=gabcNotes,gabcTextMarkup,gabcTranslation

" Define the default highlighting.
"hi def link gabcAttributeName   Comment
"hi def link gabcAttributeNameb  Comment
"hi def link gabcText            Comment
hi def link gabcTextMarkup      SpecialKey
hi def link gabcBasicNote       Statement
hi def link gabcNote            Type
"hi def link gabcAlteration      Type
"hi def link gabcSpace           Special
hi def link toneIndicator	PreProc
hi def link versenumber		Type
hi def link texHeading		SpecialKey

"let b:current_syntax = "gabc"
