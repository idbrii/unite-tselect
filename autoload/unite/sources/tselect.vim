"=============================================================================
" FILE: tselect.vim
" AUTHOR: Eiichi Sato <sato.eiichi@gmail.com>,
"		  Andrew Pyatkov <mrbiggfoot@gmail.com>
" Last Modified: 03 May 2015
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:source = {
	\ 'name': 'tselect',
	\ 'description': 'candidates from :tselect',
	\ 'syntax': 'uniteSource__tselect',
	\ 'hooks': {
		\ 'on_syntax': function("unite#sources#tselect#on_syntax"),
	\ },
\ }

function! s:read_line_fmt(tag)
	let l:line = system("sed '" . a:tag.cmd . "q;d' " . a:tag.filename)
	let l:line = substitute(l:line, '^\s\+', '', '')
	let l:line = substitute(l:line, "\n", "", "")
	return '['. a:tag.kind . '] ' . a:tag.filename . ":\t" . l:line
endfunction

function! s:format_tag(tag)
	let l:str = substitute(a:tag.cmd, '/^', '', '')
	let l:str = substitute(l:str, '^\s\+', '', '')
	let l:str = substitute(l:str, '$/', '', '')
	return '['. a:tag.kind . '] ' . a:tag.filename . ":\t" . l:str
endfunction

function! s:convert_cmd(cmd)
	let l:cmd = substitute(a:cmd, '/^', '^', '')
	let l:cmd = substitute(l:cmd, '$/', '$', '')
	let l:cmd = escape(l:cmd, '*[]')
	return l:cmd
endfunction

function! s:source.gather_candidates(args, context)
	let l:result = []
	if empty(a:args)
		let l:expr = '\<' . expand("<cword>") . '\>'
	else
		let l:expr = get(a:args, 0, '')
	endif

	let l:taglist = taglist(l:expr)
	for l:tag in l:taglist
		if l:tag.cmd =~ '^\d\+$'
			let l:item = {
				\ 'word': s:read_line_fmt(l:tag),
				\ 'kind': 'jump_list',
				\ 'action__path': l:tag.filename,
				\ 'action__line': l:tag.cmd,
				\ }
		else
			let l:item = {
				\ 'word': s:format_tag(l:tag),
				\ 'kind': 'jump_list',
				\ 'action__path': l:tag.filename,
				\ 'action__pattern': s:convert_cmd(l:tag.cmd)
				\ }
		endif
		call add(l:result, l:item)
	endfor

	return l:result
endfunction

function! unite#sources#tselect#define()
	return s:source
endfunction

function! unite#sources#tselect#on_syntax(args, context)
	syntax match uniteSource__tselect_TagType /\[.\{-}\]/ contained containedin=uniteSource__tselect
	syntax match uniteSource__tselect_Path / [^:]*/ contained containedin=uniteSource__tselect
	syntax match uniteSource__tselect_Item /:.*/ contained containedin=uniteSource__tselect
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
