" ============================================================================
" File:        signcolor.vim
" Description: vim plugin to show RGB color values in the sign column
" Maintainer:  Charles Lavery <charles.lavery@gmail.com>
"              https://charleslavery.com
" License:     MIT
" Notes:       This plugin requires both the 'signs' feature and a full color
"              client. ie. It's mostly useful for gVim and macvim.
"
" ============================================================================"


if !has("signs") || !( has('gui_running') || &t_Co==256 )
  echoerr "vim-signcolor requires the 'signs' feature and a GUI/high color client"
  finish
endif

let s:sign_char = "●"
let s:sign_char_name = "SignColorSign"

function! signcolor#set_sign(bufnum, color, linenum)
  call add(b:sign_list, b:next_sign_id)

  let sign_char_name = s:sign_char_name . b:next_sign_id
  let hl_group = s:sign_char_name . b:next_sign_id

  execute "sign define " . sign_char_name . " text=" . s:sign_char . " texthl=" . hl_group
  execute "sign place " . b:next_sign_id . " line=" . a:linenum . " name=" . sign_char_name . " buffer=" . a:bufnum
  execute "highlight " . hl_group . " guifg=" . a:color . " guibg=" . b:sign_column_bg

  let b:next_sign_id = b:next_sign_id + 1
endfunction

function! signcolor#remove_sign(bufnum, signid)
  let sign_char_name = s:sign_char_name . a:signid
  execute "sign unplace " . a:signid . " buffer=" . a:bufnum
  execute "sign undefine " . sign_char_name
endfunction

function! signcolor#remove_all_signs(bufnum)
  for id in b:sign_list
    call signcolor#remove_sign(a:bufnum, id)
  endfor
  
  let b:sign_list = []
  let b:next_sign_id = b:first_sign_id
endfunction

function! signcolor#set_buffer_local_vars()
  let b:is_signs_set = 0
  let b:first_sign_id = 4000
  let b:next_sign_id  = b:first_sign_id
  let b:sign_list = []

  let b:sign_column_bg = synIDattr(hlID("SignColumn"), "bg", "gui")
endfunction

function! signcolor#toggle_signs_for_colors_in_buffer()
  let linenr = 1
  let endline = line("$")
  let curbuf = bufnr("%")

  if !exists("b:first_sign_id")
    call signcolor#set_buffer_local_vars()
  endif

  if b:is_signs_set
    call signcolor#remove_all_signs(curbuf)
    let b:is_signs_set = 0
  else
    while linenr <= endline
      let match = matchstr(getline(linenr), '\v#[a-fA-F0-9]{6}')
      let m2 = matchlist(getline(linenr), '\v#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])')
      if !empty(match)
        call signcolor#set_sign(curbuf, match, linenr)
      elseif !empty(m2)
        let cleaned = "#" . m2[1] . m2[1] . m2[2] . m2[2] . m2[3] . m2[3]
        call signcolor#set_sign(curbuf, cleaned, linenr)
      endif
      let linenr += 1
    endwhile
    let b:is_signs_set = 1
  endif
endfunction
