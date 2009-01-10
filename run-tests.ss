#lang scheme/base

(require (file "all-delirium-tests.ss")
         (file "instaweb.ss")) ; required for mzc only

; Main program body ----------------------------

(instaweb/delirium #:port         8765 
                   #:servlet-path "test-servlet.ss"
                   #:test         all-delirium-tests)
