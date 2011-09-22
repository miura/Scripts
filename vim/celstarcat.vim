" Vim syntax file
" Language:         Celestia Star Catalogs
" Maintainer:       n/a
" Latest Revision:  26 April 2008

if exists("b:current_syntax")
  finish
endif


syn keyword celestiaSCTodo containedin=celestiaSCComment contained TODO FIXME XXX NOTE
syn match celestiaSCComment "#.*$" contains=celestiaSCTodo


"----------------------------------------------------------------/
"  Celestia Star Catalog Numbers
"----------------------------------------------------------------/

"  Regular int like number with - + or nothing in front
syn match celestiaSCNumber '\d\+' contained display
syn match celestiaSCNumber '[-+]\d\+' contained display

"  Floating point number with decimal no E or e (+,-)
syn match celestiaSCNumber '\d\+\.\d*' contained display
syn match celestiaSCNumber '[-+]\d\+\.\d*' contained display

"  Floating point like number with E and no decimal point (+,-)
syn match celestiaSCNumber '[-+]\=\d[[:digit:]]*[eE][\-+]\=\d\+' contained display
syn match celestiaSCNumber '\d[[:digit:]]*[eE][\-+]\=\d\+' contained display

"  Floating point like number with E and decimal point (+,-)
syn match celestiaSCNumber '[-+]\=\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+' contained display
syn match celestiaSCNumber '\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+' contained display



"--------------------------------------------------------------------------/
"  Celestia strings and star block descriptions
"--------------------------------------------------------------------------/


syn region celestiaSCString oneline start='"' end='"' contained
syn region celestiaSCDescString oneline start='"' end='"'


syn match celestiaSCHIPNumber '\d\{1,6}' nextgroup=celestiaSCString
syn region celestiaSCDescBlock start="{" end="}" fold transparent contains=ALLBUT,celestiaSCMainKw



"----------------------------------------------------------------------------/
"  Celestia keywords
"----------------------------------------------------------------------------/

syn keyword celestiaSCStarBlockCmd OrbitBarycenter CustomOrbit SpectralType  nextgroup=celestiaSCString skipwhite
syn keyword celestiaSCStarBlockCmd Mesh Texture                              nextgroup=celestiaSCString skipwhite

syn keyword celestiaSCStarBlockCmd RA Dec Distance AbsMag AppMag Radius      nextgroup=celestiaSCNumber skipwhite
syn keyword celestiaSCStarBlockCmd RotationOffset RotationPeriod Obliquity   nextgroup=celestiaSCNumber skipwhite
syn keyword celestiaSCStarBlockCmd EquatorAscendingNode Mass                 nextgroup=celestiaSCNumber skipwhite

syn keyword celestiaSCEllOrbitCmd Period SemiMajorAxis Eccentricity          nextgroup=celestiaSCNumber skipwhite
syn keyword celestiaSCEllOrbitCmd Inclination AscendingNode ArgOfPericenter  nextgroup=celestiaSCNumber skipwhite
syn keyword celestiaSCEllOrbitCmd MeanAnomaly MeanLongitude                  nextgroup=celestiaSCNumber skipwhite

syn keyword celestiaSCMainKw Star                                            nextgroup=celestiaSCHIPNumber
syn keyword celestiaSCMainKw Barycenter                                      nextgroup=celestiaSCString
syn keyword celestiaSCMainInnerKw EllipticalOrbit                            nextgroup=celestiaSCDescBlock


"----------------------------------------------------------------------------/
"  Setup syntax highlighting
"----------------------------------------------------------------------------/

let b:current_syntax = "celstarcat"

hi def link celestiaSCTodo          Todo
hi def link celestiaSCComment       Comment
hi def link celestiaSCStarBlockCmd  Statement
hi def link celestiaSCMainKw        Keyword
hi def link celestiaSCMainInnerKw   Special
hi def link celestiaSCEllOrbitCmd   Statement
hi def link celestiaSCHIPNumber     Type
hi def link celestiaSCString        Constant
hi def link celestiaSCDescString    PreProc
hi def link celestiaSCNumber        Constant