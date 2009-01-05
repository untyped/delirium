#lang mzscheme

(require (only mzlib/etc opt-lambda)
         scheme/include
         scheme/match
         scheme/pretty
         srfi/13/string
         srfi/26/cut
         (planet schematics/schemeunit:2/plt/location)
         (planet schematics/schemeunit:2/plt/test)
         (planet schematics/schemeunit:2/plt/monad)
         (planet schematics/schemeunit:2/plt/hash-monad)
         (planet schematics/schemeunit:2/plt/counter)
         (planet schematics/schemeunit:2/plt/name-collector)
         (planet schematics/schemeunit:2/plt/text-ui-util))

(provide test/text-ui
         display-check-info
         display-exn
         display-summary+return
         display-ticker
         display-result)

; prompt
(define test-prompt
  (make-continuation-prompt-tag 'test-prompt))

; From schematics/schemeunit.plt/2/8/generic/text-ui.ss:
; ----- SNIP -----
;; test-result -> void
;;
;; Prints a summary of the test result
(define (display-ticker result)
  (cond
    ((test-error? result)
     (display "!"))
    ((test-failure? result)
     (display "-"))
    (else
     (display "."))))

;; test-result -> void
(define (display-result result)
  (cond
    ((test-error? result)
     (newline)
     (display (test-result-test-case-name result))
     (display " [ERROR]")
     (newline))
    ((test-failure? result)
     (newline)
     (display (test-result-test-case-name result))
     (display " [FAIL]")
     (newline))
    (else
     (display (test-result-test-case-name result))
     (display " [PASS]")
     (newline))))

; ----- SNIP -----

;; exn -> void
;;
;; Outputs a printed representation of the exception to
;; the current-output-port
(define (display-exn exn)
  (let ([op (open-output-string)])
    (parameterize ([current-error-port op])
      ((error-display-handler)
       (exn-message exn)
       exn))
    (display (get-output-string op))
    (newline)))

;; strip-redundant-parms : (list-of check-info) -> (list-of check-info)
;;
;; Strip any check-params? is there is an
;; actual/expected check-info in the same stack frame.  A
;; stack frame is delimited by occurrence of a check-name?
(define (strip-redundant-params stack)
  (define (binary-check-this-frame? stack)
    (let loop ([stack stack])
      (cond
        [(null? stack) #f]
        [(check-name? (car stack)) #f]
        [(check-actual? (car stack)) #t]
        [else (loop (cdr stack))])))
  (let loop ([stack stack])
    (cond
      [(null? stack) null]
      [(check-params? (car stack))
       (if (binary-check-this-frame? stack)
           (loop (cdr stack))
           (cons (car stack) (loop (cdr stack))))]
      [else (cons (car stack) (loop (cdr stack)))])))


;; test-result [(U #t #f)] -> void
(define display-check-info
  (opt-lambda (result [verbose? #f])
    (cond [(test-failure? result)
           (let* ([exn (test-failure-result result)]
                  [stack (exn:test:check-stack exn)])
             (for-each
              (lambda (info)
                (let ((value (check-info-value info)))
                  (cond
                    [(check-name? info)
                     (printf "name: ~a\n" value)]
                    [(check-location? info)
                     (printf "location: ~a\n"
                             (trim-current-directory
                              (location->string
                               (check-info-value info))))]
                    [(check-params? info)
                     (unless (null? value)
                       (display "params:\n")
                       (map pretty-print value))]
                    [(check-actual? info)
                     (display "actual: ")
                     (pretty-print (check-info-value info))]
                    [(check-expected? info)
                     (display "expected: ")
                     (pretty-print (check-info-value info))]
                    [(and (check-expression? info)
                          (not verbose?))
                     (void)]
                    [else
                     (printf "~a: ~v\n"
                             (check-info-name info)
                             value)])))
              (if verbose?
                  stack
                  (strip-redundant-params stack))))]
          [(test-error? result)
           (display-exn (test-error-result result))]
          [else (void)])))

;; test-result -> void
(define (display-verbose-check-info result)
  (cond
    ((test-failure? result)
     (let* ((exn (test-failure-result result))
            (stack (exn:test:check-stack exn)))
       (for-each
        (lambda (info)
          (cond
            ((check-location? info)
             (display "location: ")
             (display (trim-current-directory
                       (location->string
                        (check-info-value info)))))
            (else
             (display (check-info-name info))
             (display ": ")
             (write (check-info-value info))))
          (newline))
        stack)))
    ((test-error? result)
     (display-exn (test-error-result result)))
    (else
     (void))))

(define (std-test/text-ui display-check-info test)
  (call-with-continuation-prompt
   (lambda ()
     (let ([result
            (let/ec escape
              (fold-test-results
               (lambda (result seed)
                 (unless (test-success? result)
                   ((sequence* (display-test-case-name result)
                               (lambda (hash)
                                 (display-result result)
                                 (display-check-info result)
                                 hash))
                    seed)
                   (printf "Test failed.~n")
                   (call-with-current-continuation
                    (lambda (continue)
                      (escape (list continue seed)))
                    test-prompt))
                 ((sequence* (update-counter! result)
                             (display-test-case-name result)
                             (lambda (hash)
                               (display-result result)
                               (display-check-info result)
                               hash))
                  seed))
               ((sequence (put-initial-counter)
                          (put-initial-name))
                (make-empty-hash))
               test
               #:fdown (lambda (name seed)
                         ((push-suite-name! name) seed))
               #:fup   (lambda (name kid-seed)
                         ((pop-suite-name!) kid-seed))))])
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

(define (display-summary+return monad)
  (monad-value
   ((compose (sequence* (display-counter) (counter->vector))
             (match-lambda
               [(vector s f e)
                (return-hash (+ f e))]))
    monad)))

;; test [(U 'quiet 'normal 'verbose)] -> integer
(define test/text-ui
  (opt-lambda (test [mode 'normal])
    (monad-value
     ((compose (sequence* (display-counter) (counter->vector))
               (match-lambda
                 [(vector s f e)
                  (return-hash (+ f e))]))
      (case mode
        [(quiet)   (fold-test-results
                    (lambda (result seed)
                      ((update-counter! result) seed))
                    ((put-initial-counter)
                     (make-empty-hash))
                    test)]
        [(normal)  (std-test/text-ui display-check-info test)]
        [(verbose) (std-test/text-ui
                    (cut display-check-info <> #t)
                    test)])))))
