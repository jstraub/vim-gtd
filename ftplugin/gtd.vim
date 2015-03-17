" Copyright (c) 2015, Julian Straub <jstraub@csail.mit.edu>
" Licensed under the MIT license. See the license file LICENSE.

if exists("g:loaded_gtd") || &cp
  finish
endif
let g:loaded_gtd = 000 " your version number
let s:keepcpo    = &cpo
set cpo&vim
set foldcolumn=5
set nospell

"autocmd BufWritePre *.gtd :call GtdSortProjects()

" ============================= folding =================================
setlocal foldmethod=expr
setlocal foldexpr=GetGtdFold(v:lnum)

function! GetGtdFold(lnum)
  if getline(a:lnum) =~? '\v^\s*$'
    return '-1'
  endif 
  let this_indent = IndentLevel(a:lnum)
  let next_indent = IndentLevel(NextNonBlankLine(a:lnum))
"  echo this_indent.' '.next_indent
  "echo getline(a:lnum).' '.match(getline(a:lnum),'DONE')
"  if match(getline(a:lnum),'^ *-* DONE') >= 0
"    let this_indent = this_indent + 1
"    if match(getline(NextNonBlankLine(a:lnum)),'^ *-* DONE') >= 0
"      let next_indent = next_indent + 1
"    endif
"  endif
"  echo this_indent.' '.next_indent
  if next_indent == this_indent
    return this_indent
  elseif next_indent < this_indent
    return this_indent
  elseif next_indent > this_indent
    return '>' . next_indent
  endif
  
  return '0'
endfunction

function! IndentLevel(lnum)
  return indent(a:lnum) / &shiftwidth
endfunction

function! NextNonBlankLine(lnum)
  let numlines = line('$')
  let current = a:lnum + 1

  while current <= numlines
    if getline(current) =~? '\v\S'
      return current
    endif
    let current += 1
  endwhile
  return -2
endfunction

" ==============================================================
function! GtdToggleActWait()
  let line=getline('.')
  let pos = getpos('.')
"  echo line
  if match(line,"ACT") >= 0
    silent :.s/ACT/WAIT/
    let pos[2] = match(line,"ACT") + 5
  elseif match(line,"WAIT") >= 0
    silent :.s/WAIT/DONE/
    let pos[2] = match(line,"WAIT") + 4
  elseif match(line,"DONE") >= 0
    silent :.s/DONE/ACT/
    let pos[2] = match(line,"DONE") + 5
"  elseif match(line,"TODO") >= 0
"    silent :.s/TODO/DONE/
"    let pos[2] = match(line,"TODO") + 5
  endif
  call setpos('.',pos)
endfunction

" ==============================================================
function! GtdEmailActWait()
  let line = getline('.')
  let lnum = line('.') + 1
  let msg = []
  if match(line,"ACT") >= 0 || match(line,"WAIT") >= 0
    let msg = [substitute(line,'^ \+','','')]
  elseif match(line,'^ \+##') >=0
    let msg = [substitute(line,'^ \+##','','')] 
  endif
  if len(msg) > 0
    " parse in all lines below with larger indent level
    let subject = copy(msg[0])
    let indLvl = IndentLevel(lnum-1)
    while IndentLevel(lnum) > indLvl
      call add(msg, getline(lnum))
      let lnum = lnum + 1
    endwhile
    " write out to file and send as email
    call writefile(msg,'./tmp.txt')
    silent !clear
    execute "! cat ./tmp.txt | mutt jstraub@mit.edu -s \"".subject."\"" 
  endif
endfunction

" =============================================================
function! GtdParseContexts()
  let contexts = []
  let lnum = search("# CONTEXTS",'wn') + 1
  if lnum > 1
    while IndentLevel(lnum) > 0
      let contexts = contexts + [substitute(getline(lnum),'^ *','','g')]
      let lnum = lnum + 1
    endwhile
  endif
  return contexts
endfunction

" =============================================================
function! GtdParseSection(section)
  let contexts = sort(GtdParseContexts())
  let lnum = search ("# ".a:section,'wn') + 1
  let curCont = contexts[0]
  let acts = {'_lstart':lnum} 
  for context in contexts
    let acts[context] = []
  endfor
  if lnum > 1
    while IndentLevel(lnum) > 0
      if IndentLevel(lnum) == 1
        let knownCont = 0
        for context in contexts
          if match(getline(lnum),'^ *'.context) >= 0
            let curCont = context
            let knownCont = 1
          endif
        endfor
        if knownCont == 0
          echom "Warning: unkown context: ".getline(lnum)
        endif
      elseif IndentLevel(lnum) > 1
        if has_key(acts, curCont) > 0
          let acts[curCont] = acts[curCont] + [[getline(lnum)]]
        else 
          let acts[curCont] = [[getline(lnum)]]
        endif
        let curLevel = IndentLevel(lnum) 
        while IndentLevel(lnum + 1) > curLevel
          let acts[curCont][-1] = acts[curCont][-1] + [getline(lnum + 1)]
          let lnum = lnum + 1
        endwhile
      endif
      let lnum = lnum + 1
    endwhile
  endif
  let acts['_lend'] = lnum - 1
  return acts
endfunction

function! GtdWriteSection(acts,contexts,section)
  silent mkview
  execute "set foldlevel=99"
  " re-find the boundaries of that section to make sure we are deleting the
  " right thing
  let lnum = search ("# ".a:section,'wn') + 1
  let lstart = lnum
  if lnum > 1
    while IndentLevel(lnum) > 0
      let lnum = lnum + 1
    endwhile
  endif
  let lend = lnum - 1

  execute lstart.",".lend."delete"
  let lnum = lstart - 1
  for context in a:contexts
    call append(lnum,"  ".context)
    let lnum  = lnum + 1
    " TODO: sort acts 
    for act in a:acts[context]
      for line in act
        call append(lnum,line)
        let lnum  = lnum + 1
      endfor
    endfor
  endfor
  silent loadview
endfunction

function! GtdSortSection(section)
  let acts = GtdParseSection(a:section)
  let contexts = sort(GtdParseContexts())
  call GtdWriteSection(acts,contexts,a:section)
endfunction

function! GtdRefreshSections()
  let acts = GtdParseSection("ACTIONS")
  let waits = GtdParseSection("WAITING")
  let dones = GtdParseSection("DONE")
  let contexts = sort(GtdParseContexts())

  " move stuff from ACTIONS to other WAITING and DONE
  for context in contexts
    let contActs = deepcopy(acts[context])
    let acts[context] = [[]]
    for act in contActs
      if match(act[0],"^ *DONE") >= 0
        echom "DONE: ".act[0]
        call add(dones[context], act)
      elseif match(act[0],"^ *WAIT") >= 0
        echom "WAIT:".act[0]
        call add(waits[context], act)
      else
        call add(acts[context], act)
      endif
    endfor
  endfor

  " move stuff from WAITING to done DONE and ACTIONS
  for context in contexts
    let contWaits = deepcopy(waits[context])
    let waits[context] = [[]]
    for wait in contWaits
      if match(wait[0],"^ *DONE") >= 0
        echom "DONE: ".wait[0]
        call add(dones[context], wait)
      elseif match(wait[0],"^ *ACT") >= 0
        echom "ACT:".wait[0]
        call add(acts[context], wait)
      else
        call add(waits[context], wait)
      endif
    endfor
  endfor

  " move stuff from DONE to WAITING and ACTIONS
  for context in contexts
    let contDones = deepcopy(dones[context])
    let dones[context] = [[]]
    for done in contDones
      if match(done[0],"^ *WAIT") >= 0
        echom "WAIT: ".done[0]
        call add(waits[context], done)
      elseif match(done[0],"^ *ACT") >= 0
        echom "ACT:".done[0]
        call add(acts[context], done)
      else
        call add(dones[context], done)
      endif
    endfor
  endfor

  call GtdWriteSection(acts,contexts,"ACTIONS")
  call GtdWriteSection(waits,contexts,"WAITING")
  call GtdWriteSection(dones,contexts,"DONE")

endfunction

function! NonEmptyString(str)
   return a:str != "" && a:str != " "
endfunction

function! Filtered(fn, l)
    let new_list = deepcopy(a:l)
    call filter(new_list, string(a:fn) . '(v:val)')
    return new_list
endfunction

" ==============================================================
nmap <silent>  st  :.s/DONE/ACT/<CR>
nmap <silent>  ''  :call GtdToggleActWait()<CR>
nmap <silent>  'e  :call GtdEmailActWait()<CR>
nmap <silent>  's  :call GtdSortProjects()<CR>
nmap <silent>  'c  :call GtdParseContexts()<CR>
nmap <silent>  'a  :call GtdSortSection("ACTIONS")<CR>
nmap <silent>  'w  :call GtdSortSection("WAITING")<CR>
nmap <silent>  'd  :call GtdSortSection("DONE")<CR>
nmap <silent>  'r  :call GtdRefreshSections()<CR>
" tab key for folding
nmap <silent>  <tab> za

