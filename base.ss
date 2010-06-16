#lang scheme/base

(require (planet untyped/unlib:3/require))

(define-library-aliases schemeunit (planet schematics/schemeunit:3) #:provide)
(define-library-aliases json       (planet dherman/json:1)          #:provide)
(define-library-aliases mirrors    (planet untyped/mirrors:2)       #:provide)
(define-library-aliases unlib      (planet untyped/unlib:3)         #:provide)

(require (for-syntax scheme/base)
         net/url
         scheme/contract
         scheme/match
         scheme/pretty
         scheme/runtime-path
         srfi/26
         (json-in json)
         (mirrors-in main)
         (schemeunit-in test)
         (unlib-in debug exn))

; Configuration --------------------------------

; path
(define-runtime-path delirium-htdocs-path
  "htdocs")

; path
(define-runtime-path delirium-mime-types-path
  "mime.types")

; Exceptions -----------------------------------

; (struct string continuation-marks string any)
(define-struct (exn:fail:browser exn:fail)
  (command result)
  #:transparent
  #:property prop:custom-write
  ; exn:fail:browser output-port boolean -> void
  (lambda (exn out write?)
    ; any output-port -> void
    (define show (if write? write display))
    (display "#<exn:fail:browser " out)
    (show (exn-message exn) out)
    (display ">\n" out)
    (display "Command:\n" out)
    (show (exn:fail:browser-command exn) out)
    (newline out)
    (display "Result:\n" out)
    (show (exn:fail:browser-result exn) out)
    (newline out)))

; Provide statements --------------------------- 

(provide (all-from-out net/url
                       scheme/contract
                       scheme/match
                       scheme/pretty
                       srfi/26)
         (schemeunit-out test)
         (unlib-out debug exn))

(provide/contract
 [delirium-htdocs-path               path?]
 [delirium-mime-types-path           path?]
 [struct (exn:fail:browser exn:fail) ([message            string?]
                                      [continuation-marks continuation-mark-set?]
                                      [command            string?]
                                      [result             json?])])
