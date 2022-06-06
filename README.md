# TCL Syntax Checker for VIM
## 1. Overview
This project introduced a TCL syntax checker for Vim users. 

The core of the checker is the [Nagelfar engine](https://wiki.tcl-lang.org/page/Nagelfar) created by Peter Spjuth since 1999. 

A VIM plugin is then developed to integrate Nagelfar into VIM. Whenever we save a TCL file, the Nagelfar engine gets invoked automatically and the syntax results are displayed in the quickfix window of VIM. The VIM plugin is disabled by default if the TCL file is large (e.g., more than 3000 lines) to prevent VIM from hanging for too long. It also allows users to enter their own rule exceptions.

## 2. How to Update Nagelfar Database?
In order to run Nagelfar in Terminal, call this command

<code>tclsh path/to/nagelfar/nagelfar.tcl -H [path-to-TCL-file]</code>

Although Nagelfar is very powerful, it has a major drawbacks. If we use Nagelfar in our specific TCL code base, we would probably receive many warning messages of "W Unknown command". The reason is that the Nagelfar could not recognize our functions or variables as the valid ones.

To solve this problem, we need to update the Nagelfar database with our function names, following these steps below
* The database is stored in **\<nagelfar-directory\>/syntaxdb.tcl**
  
  <img src="https://user-images.githubusercontent.com/4446300/172264397-a35cbe4d-de41-4b0f-b87a-a47d25fdaebb.png" width="350" height="291">
 
* List all unknown functions using this command  
  <code><pre>
  find "path-to-your-tcl-code-base" -type f -iname "*.tcl" –print0 | \
  xargs -0 tclsh "path-to-nagelfar132/nagelfar.tcl" -H | \
  grep "W Unknown command" | cut -d "\"" -f 2 | \
  sort | uniq > all_new_funcs.log
  </code></pre>

  * 1st line: Look up all TCL files inside our code base
  
  * 2nd line: Run nagelfar.tcl on every single TCL file
  
  * 3rd line: Select only "W Unknown command" messages and extract the command names
  
  * 4th line: Remove the duplicates and save the results to the all_new_funcs.log file

* Copy all new function names to **\<nagelfar-directory\>/syntaxdb.tcl**
  
## 3. How to Integrate Nagelfar into VIM?
  
* Develop a VIM plugin named **tcl_syntax_checker.vim**. It is written based on Vimscript language.
  
* The plugin consists of five main parts, as shown below
  
  <img src="https://user-images.githubusercontent.com/4446300/172266480-0faffa2e-924a-49fd-ba24-b48f6df37de6.png" width="720" height="292">
  
* The flow chart is shown below
  
  <img src="https://user-images.githubusercontent.com/4446300/172267073-85970c57-21bb-46e8-af9b-88e49a021c2f.png" width="532" height="456">

* To install the plugin, follow these steps
 
  * Open $HOME/.vimrc, add the lines
  <code><pre>
  source path/to/tcl_syntax_checker/tcl_syntax_checker.vim
  let g:tclsc_engine = 'path/to/tcl_syntax_checker/nagelfar132/nagelfar.tcl'
  let g:tclsc_nlines = 3000  
  " Example of exceptions. Note: change " to \\\"
  let g:tclsc_exceptions = [
                          \ "E Bad expression: can't read \\\"darth_vader_mind\\\": no such variable", 
                          \ "E Unknown variable \\\"order_66\\\""                        
                          \]
  </code></pre>

  * Restart VIM
  * If the file is large, we need to call the plugin manually <code>:XTclCheckSyntax 1</code>
