" File:        vim-steam.vim
" Description: Plugin to launch steam games
" Maintainer:  Raphael Robatsch <raphael@tapesoftware.net>
" Version:     0.1.0
" License:     see <https://github.com/raphaelr/vim-steam/blob/master/LICENSE>

if exists("loaded_vim_steam")
    finish
endif
let loaded_vim_steam = 1
let s:ruby_script_loaded = 0

command -nargs=1 -complete=customlist,<SID>SteamComplete Steam call <SID>SteamRun(<q-args>)

function s:SteamRun(arg)
    if !s:LoadRubyExt()
        return
    endif

    execute "ruby VimSteam.run '" . a:arg . "'"
endfunction

function s:SteamComplete(lead, cmdline, cursor)
    if !s:LoadRubyExt()
        return
    endif
    
    execute "ruby VimSteam.complete '" . a:lead . "'"
endfunction

function s:LoadRubyExt()
    if s:ruby_script_loaded
        return 1
    endif

    if !has("ruby")
        echoerr "vim-steam requires Ruby"
        return 0
    endif

    ruby << EOF
        should_retry = true
        begin
            require "vim-steam"
        rescue LoadError
            this_script = VIM.evaluate('expand("<sfile>")')
            ruby_dir = File.join(File.dirname(this_script), "..", "ruby")
            $LOAD_PATH << ruby_dir

            should_retry_now = should_retry
            should_retry = false
            retry if should_retry_now
        end
EOF
    
    let s:ruby_script_loaded = 1
    return 1
endfunction

" vim: set et tw=100 ts=4 sw=4:
