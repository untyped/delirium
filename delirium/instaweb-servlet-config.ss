#lang scheme/base

(require (for-syntax scheme/base)
         scheme/contract
         scheme/runtime-path
         (file "base.ss")
         (file "core.ss"))

; Variables ------------------------------------

(define-runtime-path delirium-htdocs-path         "htdocs")
(define-runtime-path delirium-servlet-path        "instaweb-servlet.ss")
(define-runtime-path delirium-servlet-config-path "instaweb-servlet-config.ss")

; Tests ----------------------------------------

; (U schemeunit-test #f)
(define *test* #f)

; -> schemeunit-test
(define (test-ref)
  (if *test*
      *test*
      (raise-exn exn:fail:contract
        "No target test specified.")))

; -> void
(define (test-set! test)
  (set! *test* test))

; Test UI --------------------------------------

; (U (-> test any) #f)
(define *run-tests* test/text-ui/pause-on-fail)

; -> (U (-> test any) #f)
(define (run-tests-ref)
  *run-tests*)

; (-> test any) -> void
(define (run-tests-set! run-tests)
  (set! *run-tests* run-tests))

; Provide statements --------------------------- 

(provide/contract
 [delirium-htdocs-path         path?]
 [delirium-servlet-path        path?]
 [delirium-servlet-config-path path?]
 [test-ref                     (-> schemeunit-test?)]
 [test-set!                    (-> schemeunit-test? void?)]
 [run-tests-ref                (-> (-> schemeunit-test? any))]
 [run-tests-set!               (-> (-> schemeunit-test? any) void?)])
