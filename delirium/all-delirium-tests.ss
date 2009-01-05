#lang scheme/base

(require srfi/26/cut
         "accessor-test.ss"
         "command-test.ss"
         "core.ss"
         "delirium.ss" ; required for mzc only
         "selector-test.ss"
         "test-base.ss")

(define all-delirium-tests
  (test-suite "delirium"
    
    '#:after
    (cut open/wait 
         (lambda (request)
           (send/suspend/dispatch
            (lambda (embed-url)
              (make-html-response
               (xml (html (body (p "Tests complete.")
                                (p "Check the command line for the results.")))))))))
    
    accessor-tests
    command-tests
    selector-tests))

; Provide statements --------------------------- 

(provide all-delirium-tests)
