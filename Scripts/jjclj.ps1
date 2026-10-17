<# 
  .Synopsis
    Run Clojure Leiningen

  .Description
    All parameters optional.  Without any parameters prints out help.
	
  jj <action> WHERE <action> IS:

  [help] to print help
  [edit] this
  [prof] edit Leiningen profile 

    USING LUMO 
    
      Install lumo:
      
        npm i -g lumo-cljs
      
      Write simple script:
      
        --- hello.cljs ---
        (println "Hello World!")
        ---
        
      Run it:
      
        lumo hello.cljs
        
      Pull in NPM dependencies and even load JSON:
      
        (require
          '[clojure.string :refer [capitalize]]   ;; Require a Clojure library
          '[fs :refer [writeFileSync]]            ;; Require a Node.JS module (filesystem)
          '["./randomUsers.json" :as input-json]  ;; Require a JSON file as JS data  
          )
        ...
        .. (js->clj input-json :keywordize-keys true) ;; use of JSON      

    SETUP LEIN EXEC
    
      Ensure ~/.lein/profiles.clj has "{:user {:plugins [[lein-exec "0.3.6"]]}}"
      
      Install Leiningen using windows installer: will create default ~/.lein/profiles.clj
      
      Edit this with "jjclj prof"

    START REPL
    
      Run REPL anywhere:
    
        lein repl
      
      This will use dependencies from "user" profile.  Make sure to set the dependencies up in ~/.lein/profiles.clj, e.g. for clj-time:
      
        {:user {
          :java-cmd "C:\\Program Files\\Java\\jdk1.8.0_40\\bin\\java.exe"
          :plugins [[lein-exec "0.3.6"]]
          :dependencies [[clj-time "0.13.0"]]}}
          
      Then in `lein repl` session you can:
      
        user=> (use 'clj-time.core)
        user=> (clj-time.core/now)
    
    RUN LEIN EXEC

      Allows running script as a project from script file or one-line expression.  Pulls dependencies from
      ~/.lein/profiles.clj.  
    
          lein exec [-p]
          lein exec -e[p] <string-s-expr>
          lein exec [-p] <script-path> [args]

          -e  evaluates the following string as an S-expression
          -ep evaluates the following string as an S-expression in project context (w/classpath)
          -p  indicates the script should be evaluated in project context (with classpath)    
        
    EXAMPLES OF LEIN EXEC
    
      lein exec -e "(println 'foo' (+ 20 30))"
      lein exec -ep "(use 'clj-time) (pprint (map #(str (clj-time/now) " :: " %) (range 5)))"
      lein exec -p script/run-server.clj -p 8088
      lein exec ~/common/delete-logs.clj
    
    DEPENDENCIES FROM LEIN PROFILE IN LEIN EXEC SCRIPT
    
      Put dependencies in ~/.lein/profiles.clj:

        ...
        :dependencies [[clj-time "0.13.0"]]
        ...
          
      Sample try.clj that used dependency:
      
        (use 'clj-time.core)        
        (println (clj-time.core/now))    

      Run the above with:
      
        lein exec -p try.clj      
    
    DEPENDENCIES FOR LEIN EXEC SCRIPT 
    
      Pomegranate downloads dependencies from Maven Central and Clojars in script.
      
      Sample try.clj the depends on clj-time and uses it:
    
        (use '[leiningen.exec :only (deps)])
        (deps '[[clj-time "0.13.0"]])            
        (use 'clj-time.core)                
        (println (clj-time.core/now))
        
      Run the above with:
      
        lein exec -p try.clj

    LEIN w/PROJECT
    
      Put source file in src/my-stuff/core.clj

      Then project.clj can be:
      
        (defproject my-stuff "0.1.0-SNAPSHOT"
         :description "FIXME: write description"
         :dependencies [[org.clojure/clojure "1.8.0"]]
         :main my-stuff.core) ;; mystuff/core.clj has -main method
        
      Then just: 
      
        lein run
        lein uberjar

  .LINK 
    https://github.com/kumarshantanu/lein-exec
  .LINK 
    https://github.com/technomancy/leiningen/blob/master/doc/TUTORIAL.md
      
#>

param(
	[ValidateSet(
		"help", 
		"edit",
    "prof"
	)] [string]$action="help",
	[parameter(ValueFromRemainingArguments=$true)]$remaining_args
)

# loads another script
. "$scripts/utils.ps1"

function helpfn {
	Get-Help -Name $MyInvocation.ScriptName
}

switch ($action) {
    "help" {helpfn}
    "edit" {
        jjnp $MyInvocation.MyCommand.Definition
    }
    "prof" {
        jjnp "${env:HOME}\.lein\profiles.clj"
    }
}
