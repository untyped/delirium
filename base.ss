#lang scheme/base

(require scheme/contract
         scheme/match
         scheme/pretty
         (planet schematics/schemeunit/test)
         (planet untyped/unlib/debug)
         (planet untyped/unlib/exn)
         (only-in (file "text-ui.ss") test/text-ui))

; Variables ------------------------------------

;; exn:delirium : (struct string continuation-marks)
;; exn:fail:delirium : (struct string continuation-marks)
(define-struct (exn:delirium exn) () #:transparent)
(define-struct (exn:fail:delirium exn:fail) () #:transparent)

;; exn:delirium:browser : (struct string continuation-marks string)
;; exn:fail:delirium:browser : (struct string continuation-marks string)
(define-struct (exn:delirium:browser exn:delirium) (command) #:transparent)
(define-struct (exn:fail:delirium:browser exn:fail:delirium) (command) #:transparent)

; Provide statements --------------------------- 

(provide (all-from-out scheme/contract
                       scheme/match
                       scheme/pretty
                       (planet schematics/schemeunit/test)
                       (planet untyped/unlib/debug)
                       (planet untyped/unlib/exn))
         (rename-out [test/text-ui test/text-ui/pause-on-fail])
         (all-defined-out))
