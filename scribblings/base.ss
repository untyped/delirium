#lang scheme/base

(require scheme/contract
         scribble/eval
         scribble/manual
         scribble/scheme
         scribble/struct
         scribble/urls
         (for-label "../delirium.ss"))

; Variables ------------------------------------

(define schemeunit-url
  "http://planet.plt-scheme.org/display.ss?package=schemeunit.plt&owner=schematics")

; Provide statements --------------------------- 

(provide (all-from-out scribble/eval
                       scribble/manual
                       scribble/urls)
         (for-label (all-from-out "../delirium.ss")))

(provide/contract
 [schemeunit-url string?])