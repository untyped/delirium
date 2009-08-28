#lang scheme/base

(require srfi/26/cut
         "accessor.ss"
         "command.ss"
         "core.ss"
         "selector.ss"
         "test-base.ss")

; Test suite -----------------------------------

(define accessor-tests
  (test-suite "accessor.ss"
    
    #:before
    (cut open/wait (lambda (request)
                     (send/suspend
                      (lambda (url)
                        (make-html-response
                         (xml (html (head (title "Open/wait worked")
                                          (script (@ [type "text/javascript"])
                                                  ,(js (var [testData (!array 1 2 3)]))))
                                    (body (p "Open/wait worked.")
                                          (p (@ [id "second-para"])
                                             "Another " (em "paragraph") ". ")
                                          (p (a (@ [href "http://www.untyped.com"])
                                                "Click here for awesomeness."))))))))))
    
    (test-case "title-ref"
      (check-equal? (title-ref) "Open/wait worked"))
    
    (test-case "inner-html-ref"
      (check-equal? (inner-html-ref (node/jquery "p")) "Open/wait worked.")
      (check-equal? (inner-html-ref (node/jquery "ul")) #f))
    
    (test-case "inner-html-ref*"
      (check-equal? (inner-html-ref* (node/jquery "p")) (list "Open/wait worked."
                                                              "Another <em>paragraph</em>."
                                                              "<a href=\"http://www.untyped.com\">Click here for awesomeness.</a>"))
      (check-equal? (inner-html-ref* (node/jquery "ul")) null))
    
    (test-case "text-content-ref"
      (check-equal? (text-content-ref (node/jquery "p")) "Open/wait worked.")
      (check-equal? (text-content-ref (node/jquery "ul")) #f))
    
    (test-case "text-content-ref*"
      (check-equal? (text-content-ref* (node/jquery "p")) (list "Open/wait worked."
                                                                "Another paragraph."
                                                                "Click here for awesomeness."))
      (check-equal? (text-content-ref* (node/jquery "ul")) null))
    
    (test-case "js-ref"
      (check-equal? (js-ref (js testData)) (list 1 2 3)))
    
    (test-case "jquery-path-ref"
      (let ([ref (jquery-path-ref (node/jquery "p"))])
        (check-equal? ref "html > body > p:eq(0)" "check 1")
        (check-equal? (jquery-path-ref (node/jquery ref)) ref "check 2")))
    
    (test-case "jquery-path-ref*"
      (let ([refs (jquery-path-ref* (node/jquery "p"))])
        (check-equal? refs 
                      (list "html > body > p:eq(0)"
                            "p#second-para"
                            "html > body > p:eq(2)")
                      "check 1")
        (check-equal? (jquery-path-ref (node/jquery (car refs)))
                      (car refs)
                      "check 2")
        (check-equal? (jquery-path-ref (node/jquery (cadr refs)))
                      (cadr refs)
                      "check 3")))
    (test-case "xpath-path-ref"
      (when (xpath-supported?)
        (let ([ref (xpath-path-ref (node/xpath "//p"))])
          (check-equal? ref "/html/body/p[1]" "check 1")
          (check-equal? (xpath-path-ref (node/xpath ref)) ref "check 2"))))
    
    (test-case "xpath-path-ref*"
      (when (xpath-supported?)
        (let ([refs (xpath-path-ref* (node/xpath "//p"))])
          (check-equal? refs 
                        (list "/html/body/p[1]"
                              "//p[@id='second-para']"
                              "/html/body/p[3]")
                        "check 1")
          (check-equal? (xpath-path-ref (node/xpath (car refs)))
                        (car refs)
                        "check 2")
          (check-equal? (xpath-path-ref (node/xpath (cadr refs)))
                        (cadr refs)
                        "check 3"))))))

; Provide statements --------------------------- 

(provide accessor-tests)
