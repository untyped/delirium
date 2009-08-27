#lang scheme/base

; Adapted from (planet schematics/schemeunit:3/text-ui)

(require "base.ss")

(require srfi/13
         (schemeunit-in [base
                         counter
                         format
                         location
                         result
                         test
                         monad
                         hash-monad
                         name-collector
                         text-ui-util])
         (only-in (schemeunit-in text-ui)
                  display-context
                  display-result))

(require/expose (planet schematics/schemeunit:3/text-ui)
  (display-test-preamble
   display-test-postamble))

; Variables --------------------------------------

(define test-prompt
  (make-continuation-prompt-tag 'test-prompt))

; Main procedures --------------------------------

; test [(U 'quiet 'normal 'verbose)] -> integer
(define (run-tests/pause test [mode 'normal])
  (monad-value
   ((compose
     (sequence*
      (display-counter)
      (counter->vector))
     (match-lambda
       ((vector s f e)
        (return-hash (+ f e)))))
    (case mode
      ((quiet)
       (fold-test-results
        (lambda (result seed)
          ((update-counter! result) seed))
        ((put-initial-counter)
         (make-empty-hash))
        test))
      ((normal) (std-test/text-ui display-context test))
      ((verbose) (std-test/text-ui
                  (cut display-context <> #t)
                  test))))))

; Helper procedures ------------------------------

(define (std-test/text-ui display-context test)
  (call-with-continuation-prompt
   (lambda ()
     (let ([result
            (let/ec escape
              (fold-test-results
               (lambda (result seed)
                 ((sequence* (update-counter! result)
                             (display-test-preamble result)
                             (display-test-case-name result)
                             (lambda (hash)
                               (display-result result)
                               (display-context result)
                               hash)
                             (display-test-postamble result))
                  seed))
               ((sequence
                  (put-initial-counter)
                  (put-initial-name))
                (make-empty-hash))
               test
               #:fdown (lambda (name seed) ((push-suite-name! name) seed))
               #:fup (lambda (name kid-seed) ((pop-suite-name!) kid-seed))))])
       (match result
         [(list continue seed)
          (define response
            (begin (printf "~nTest failed: enter \"stop\" to stop or anything else to continue ... ")
                   (read-line)))
          (printf "You typed ~s~n" response)
          (if (string-ci=? response "stop")
              (exit)
              (continue (void)))]
         [monad monad])))
   test-prompt))

; Provides ---------------------------------------

(provide run-tests/pause)