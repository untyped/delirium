#lang scheme/base

(require srfi/26/cut
         (file "accessor-test.ss")
         (file "command-test.ss")
         (file "core.ss")
         (file "delirium.ss") ; required for mzc only
         (file "selector-test.ss")
         (file "test-base.ss"))

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
