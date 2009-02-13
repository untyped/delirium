#lang scheme/base

(require scheme/match
         scheme/pretty
         srfi/13
         srfi/26
         (planet schematics/schemeunit:3/base)
         (planet schematics/schemeunit:3/counter)
         (planet schematics/schemeunit:3/format)
         (planet schematics/schemeunit:3/location)
         (planet schematics/schemeunit:3/result)
         (planet schematics/schemeunit:3/test)
         (planet schematics/schemeunit:3/monad)
         (planet schematics/schemeunit:3/hash-monad)
         (planet schematics/schemeunit:3/name-collector)
         (planet schematics/schemeunit:3/text-ui-util))

(provide run-tests
         display-context
         display-exn
         display-summary+return
         display-ticker
         display-result)

; prompt
(define test-prompt
  (make-continuation-prompt-tag 'test-prompt))

;; display-ticker : test-result -> void
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

;; display-test-preamble : test-result -> (hash-monad-of void)
(define (display-test-preamble result)
  (lambda (hash)
    (if (test-success? result)
        hash
        (begin
          (display-delimiter)
          hash))))

;; display-test-postamble : test-result -> (hash-monad-of void)
(define (display-test-postamble result)
  (lambda (hash)
    (if (test-success? result)
        hash
        (begin
          (display-delimiter)
          hash))))

;; display-result : test-result -> void
(define (display-result result)
  (cond
    ((test-error? result)
     (display-test-name (test-result-test-case-name result))
     (display-error)
     (newline))
    ((test-failure? result)
     (display-test-name (test-result-test-case-name result))
     (display-failure)
     (newline))
    (else
     (void))))

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


;; display-context : test-result [(U #t #f)] -> void
(define (display-context result [verbose? #f])
  (cond
    [(test-failure? result)
     (let* ([exn (test-failure-result result)]
            [stack (exn:test:check-stack exn)])
       (for-each
        (lambda (info)
          (cond
            [(check-name? info)
             (display-check-info info)]
            [(check-location? info)
             (display-check-info-name-value
              'location
              (trim-current-directory
               (location->string
                (check-info-value info)))
              display)]
            [(check-params? info)
             (display-check-info-name-value
              'params
              (check-info-value info)
              (lambda (v) (map pretty-print v)))]
            [(check-actual? info)
             (display-check-info-name-value
              'actual
              (check-info-value info)
              pretty-print)]
            [(check-expected? info)
             (display-check-info-name-value
              'expected
              (check-info-value info)
              pretty-print)]
            [(and (check-expression? info)
                  (not verbose?))
             (void)]
            [else
             (display-check-info info)]))
        (if verbose?
            stack
            (strip-redundant-params stack))))]
    [(test-error? result)
     (display-exn (test-error-result result))]
    [else (void)]))

;; display-verbose-check-info : test-result -> void
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

(define (display-summary+return monad)
  (monad-value
   ((compose
     (sequence*
      (display-counter)
      (counter->vector))
     (match-lambda
       ((vector s f e)
        (return-hash (+ f e)))))
    monad)))

;; run-tests : test [(U 'quiet 'normal 'verbose)] -> integer
(define (run-tests test [mode 'normal])
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
