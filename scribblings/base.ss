#lang scheme/base

(require scribble/eval
         scribble/manual
         scribble/scheme
         scribble/struct
         scribble/urls
         
         (for-label (file "../delirium.ss")
                    (file "../instaweb.ss")))

; Variables ------------------------------------

(define url:dherman/javascript.plt
  "http://planet.plt-scheme.org/display.ss?package=javascript.plt&owner=dherman")

(define url:schematics/schemeunit.plt
  "http://planet.plt-scheme.org/display.ss?package=schemeunit.plt&owner=schematics")

(define url:schematics/instaweb.plt
  "http://planet.plt-scheme.org/display.ss?package=instaweb.plt&owner=schematics")

; Provide statements --------------------------- 

(provide (all-from-out scribble/eval)
         (all-from-out scribble/manual)
         (all-from-out scribble/urls)

         (all-defined-out)

         (for-label (all-from-out (file "../delirium.ss"))
                    (all-from-out (file "../instaweb.ss"))))
