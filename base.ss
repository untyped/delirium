#lang scheme/base

(require scheme/contract
         scheme/match
         scheme/pretty
         (planet schematics/schemeunit:2/test)
         (planet untyped/unlib/debug)
         (planet untyped/unlib/exn)
         (file "json.ss")
         (only-in (file "text-ui.ss") test/text-ui))

; Variables ------------------------------------

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

(provide (all-from-out scheme/contract
                       scheme/match
                       scheme/pretty
                       (planet schematics/schemeunit:2/test)
                       (planet untyped/unlib/debug)
                       (planet untyped/unlib/exn))
         (rename-out [test/text-ui test/text-ui/pause-on-fail]))

(provide/contract
 [struct (exn:fail:browser exn:fail) ([message            string?]
                                      [continuation-marks continuation-mark-set?]
                                      [command            string?]
                                      [result             json?])])
