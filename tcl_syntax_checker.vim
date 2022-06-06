" Author:               Thomas Nguyen
" Version:              1.0
" Requirements:         TCLSH, Nagelfar

if exists("loaded_tcl_syntax_checker")
   finish
endif
let loaded_tcl_syntax_checker = 1

augroup ag_call_syntax_checker_if_tcl
    autocmd!
    autocmd BufWritePost *.tcl XTclCheckSyntax 0
augroup END

" Update VIM error format to support the results returned from Nagelfar
set errorformat+=%f\:\ %l\:\ %m

function! XTclCheckSyntax(run_mode)
   " Initialize shell command
   let my_shell_cmd = " "

   if &filetype ==# 'tcl'
      " Global variables
      "     Path to nagelfar
      if ! exists("g:tclsc_engine")
         let g:tclsc_engine = $XT_TOOL . '/nagelfar132/nagelfar.tcl'
      endif
      "     Max lines 
      if ! exists("g:tclsc_nlines")
         let g:tclsc_nlines = 2000
      endif
      "     Exceptions
      if ! exists("g:tclsc_exceptions")
         let g:tclsc_exceptions = ""
      endif

      " If called from autocmd, get the number of lines of TCL file
      if a:run_mode == 0
         let my_nlines = line('$')
      endif

      " Main function
      if (a:run_mode == 0 && my_nlines < g:tclsc_nlines) || (a:run_mode == 1)
         " Call checker
         let my_checker = 'tclsh ' . g:tclsc_engine . ' -H '
         " Get TCL file name
         let my_fname = expand("%:p")

         " Generate exceptions (if any)
         let my_exceptions = ""
         if (len(g:tclsc_exceptions) > 0) 
            for my_exception in g:tclsc_exceptions
               let my_exceptions = my_exceptions . ' | grep -v "' . my_exception . '"'
            endfor
         endif
         
         " Create final shell command
         let my_shell_cmd = system(join([my_checker] + [my_fname] + [my_exceptions], ' '))
      else
         echom "XT_WARNING: File is too large. Syntax checker won't be called automatically."
      endif
   endif

   return my_shell_cmd
endfunction

if !exists(":XTclCheckSyntax")
   command! -nargs=+ -complete=file_in_path -bar XTclCheckSyntax  cgetexpr XTclCheckSyntax(<args>)
endif

nnoremap <leader>cst :XTclCheckSyntax 1<CR>
