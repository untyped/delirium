#lang scheme/base

(require srfi/26/cut
         (file "accessor.ss")
         (file "command.ss")
         (file "core.ss")
         (file "selector.ss")
         (file "test-base.ss"))

; Test suite -----------------------------------

(define accessor-tests
  (test-suite "accessor.ss"
    
    '#:before
    (cut open/wait (lambda (request)
                     (send/suspend
                      (lambda (url)
                        (make-html-response
                         (xml (html (head (title "Open/wait worked")
                                          (script (@ [type "text/javascript"])
                                                  ,(js (var [testData (!array 1 2 3)]))))
                                    (body (p "Open/wait worked.")
                                          (p (@ [id "second-para"])
                                             "Another " (em "paragraph") ".")))))))))
    
    (test-case "title-ref"
      (check-equal? (title-ref) "Open/wait worked"))
    
    (test-case "inner-html-ref"
      (check-equal? (inner-html-ref (node/xpath "//p")) "Open/wait worked." "nodes found")
      (check-equal? (inner-html-ref (node/xpath "//ul")) #f "no nodes found"))
    
    (test-case "inner-html-ref*"
      (check-equal? (inner-html-ref* (node/xpath "//p")) (list "Open/wait worked." "Another <em>paragraph</em>.") "nodes found")
      (check-equal? (inner-html-ref* (node/xpath "//ul")) null "no nodes found"))
    
    (test-case "js-ref"
      (check-equal? (js-ref (js testData)) (list 1 2 3)))
    
    (test-case "xpath-path-ref"
      (let ([ref (xpath-path-ref (node/xpath "//p"))])
        (check-equal? ref "/html/body[1]/p[1]" "check 1")
        (check-equal? (xpath-path-ref (node/xpath ref)) ref "check 2")))
    
    (test-case "xpath-path-ref*"
      (let ([refs (xpath-path-ref* (node/xpath "//p"))])
        (check-equal? refs 
                      (list "/html/body[1]/p[1]"
                            "//p[@id='second-para']")
                      "check 1")
        (check-equal? (xpath-path-ref (node/xpath (car refs)))
                      (car refs)
                      "check 2")
        (check-equal? (xpath-path-ref (node/xpath (cadr refs)))
                      (cadr refs)
                      "check 3")))))

; Provide statements --------------------------- 

(provide accessor-tests)
