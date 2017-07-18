if globpath(&rtp, 'plugin/unite.vim') == ''
    echohl WarningMsg | echomsg 'unite.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_unite_settings_vim', 0)
    finish
endif

let g:unite_enable_auto_select         = 0
let g:unite_source_rec_min_cache_files = 1000

if executable('rg')
    let g:unite_source_file_rec_async_command = ['rg', '--color=never', '--follow', '--files', '-g', '']
elseif executable('ag')
    let g:unite_source_file_rec_async_command = ['ag', '--nocolor', '--nogroup', '--follow', '--hidden', '-l', '-g', '']
elseif executable('pt')
    let g:unite_source_file_rec_async_command = ['pt', '--nocolor', '--nogroup', '--follow', '-l', '-g=']
endif

let g:unite_ignore_source_files = [
            \ 'file_list.vim',
            \ 'file_point.vim',
            \ 'find.vim',
            \ 'function.vim',
            \ 'history_input.vim',
            \ 'history_unite.vim',
            \ 'interactive.vim',
            \ 'jump_point.vim',
            \ 'launcher.vim',
            \ 'menu.vim',
            \ 'output.vim',
            \ 'output_shellcmd.vim',
            \ 'process.vim',
            \ 'runtimepath.vim',
            \ 'script.vim',
            \ ]

call unite#custom#profile('default', 'context', {
            \ 'auto_resize': 1,
            \ 'start_insert': 1,
            \ 'prompt': '> ',
            \ 'direction': 'botright',
            \ 'hide_source_names': 1,
            \ })

call unite#custom#profile('source/source', 'context', {
            \ 'buffer_name': 'sources',
            \ })

" call unite#custom#profile('source/file_rec/async,source/file_rec/neovim,source/file_rec/git', 'context', {
"             \ 'buffer_name': 'files',
"             \ 'input': '',
"             \ 'resume': 1,
"             \ 'restore': 0,
"             \ })

call unite#custom#profile('source/directory_rec/async', 'context', {
            \ 'buffer_name': 'dirs',
            \ 'default_action': 'cd',
            \ 'resume': 1,
            \ })

call unite#custom#profile('source/buffer', 'context', {
            \ 'buffer_name': 'buffers',
            \ })

call unite#custom#profile('source/tab', 'context', {
            \ 'buffer_name': 'tabs',
            \ })

call unite#custom#profile('source/bookmark', 'context', {
            \ 'buffer_name': 'bookmarks',
            \ })

call unite#custom#profile('source/command', 'context', {
            \ 'buffer_name': 'commands',
            \ })
call unite#custom#profile('source/mapping', 'context', {
            \ 'buffer_name': 'mappings',
            \ })

call unite#custom#profile('source/register', 'context', {
            \ 'buffer_name': 'registers',
            \ })

call unite#custom#profile('source/line,source/line:buffer', 'context', {
            \ 'buffer_name': 'lines',
            \ })

call unite#custom#profile('source/buffer_tab', 'context', {
            \ 'buffer_name': 'buffers',
            \ })

call unite#custom#profile('source/neomru/file', 'context', {
            \ 'buffer_name': 'mru',
            \ })

call unite#custom#profile('source/neomru/directory', 'context', {
            \ 'buffer_name': 'dirs',
            \ 'default_action': 'cd',
            \ 'resume': 1,
            \ })

call unite#custom#profile('source/tag', 'context', {
            \ 'buffer_name': 'tags',
            \ 'input': '',
            \ 'resume': 1,
            \ 'restore': 0,
            \ })

call unite#custom#profile('source/outline', 'context', {
            \ 'buffer_name': 'outline',
            \ })

call unite#custom#profile('source/tag/include', 'context', {
            \ 'buffer_name': 'outline',
            \ })

call unite#custom#profile('source/tag', 'context', {
            \ 'buffer_name': 'tags',
            \ 'input': '',
            \ 'resume': 1,
            \ 'restore': 0,
            \ })

call unite#custom#profile('source/quickfix', 'context', {
            \ 'buffer_name': 'quickfix',
            \ 'resume': 1,
            \ })

call unite#custom#profile('source/location_list', 'context', {
            \ 'buffer_name': 'location-list',
            \ 'resume': 1,
            \ })

call unite#custom#profile('source/history/command', 'context', {
            \ 'buffer_name': 'command-history',
            \ })

call unite#custom#profile('source/history/search', 'context', {
            \ 'buffer_name': 'search-history',
            \ })

call unite#custom#profile('source/yankround', 'context', {
            \ 'buffer_name': 'yanks',
            \ })

call unite#custom#profile('source/neosnippet', 'context', {
            \ 'buffer_name': 'snippets',
            \ })

call unite#filters#sorter_default#use([(has('python') || has('python3')) ? 'sorter_selecta' : 'sorter_rank'])

call unite#custom#source('file_rec/async,file_rec/neovim', 'ignore_globs', split(&wildignore, ','))

call unite#custom#source('buffer,file_rec/async,file_rec/neovim,file_rec/git', 'matchers', [
            \ 'converter_relative_word',
            \ 'matcher_fuzzy'
            \ ])

call unite#custom#source('neomru/file', 'matchers', [
            \ 'converter_relative_word',
            \ 'matcher_project_files',
            \ 'matcher_hide_current_file',
            \ 'matcher_fuzzy'
            \ ])

call unite#custom#source('file_rec/async,file_rec/neovim,file_rec/git,neomru/file', 'converters', [
            \ 'converter_file_directory'
            \ ])

highlight link uniteInputPrompt Special

let s:SystemOpenAction = { 'is_selectable': 1 }

function! s:SystemOpenAction.func(candidates) abort
    let cmd = has('mac') ? '!open' : '!xdg-open'

    for candidate in a:candidates
        if !isdirectory(candidate.action__path)
            silent! execute cmd . " " . fnameescape(candidate.action__path) . " &"
        endif
    endfor

    redraw!
endfunction

function! s:SetUniteSettings() abort
    call unite#custom#action('file', 'system-open', s:SystemOpenAction)
    inoremap <silent> <buffer> <expr> <C-o> unite#do_action('system-open')
endfunction

augroup UniteSettings
    autocmd!
    autocmd FileType unite call s:SetUniteSettings()
augroup END

let g:loaded_unite_settings_vim = 1
