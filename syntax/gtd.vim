" Vim syntax file
" Language: Getting Things Done
" Maintainer: Julian Straub
" Latest Revision: 

if exists("b:current_syntax")
  finish
endif
syn keyword gtdTodo TODO
syn keyword gtdDone DONE 
syn keyword gtdAct ACT
syn keyword gtdWait WAIT
syn keyword gtdSometime SOMETIME

syn match gtdSectionHead   '^# \u\+'
syn match gtdContext       '^ \+## [0-9a-zA-Z :]\+'

syn match gtdAddInfo       '^[ ]\+[-]\+'

hi gtdTodo term=bold cterm=bold ctermfg=red guifg=red gui=bold
hi gtdDone term=bold cterm=bold ctermfg=green guifg=green gui=bold
hi gtdAct  term=bold cterm=bold ctermfg=red guifg=red gui=bold
hi gtdWait term=bold cterm=bold ctermfg=yellow guifg=yellow gui=bold
hi gtdSometime term=bold cterm=bold ctermfg=white guifg=yellow gui=bold



hi gtdSectionHead ctermbg=236 guibg=#3a3a3a
hi gtdContext cterm=bold ctermfg=68 gui=bold guifg=#5f87d7 ctermbg=236 guibg=#3a3a3a
hi gtdAddInfo cterm=bold ctermfg=green gui=bold guifg=green
