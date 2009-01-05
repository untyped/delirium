#lang scheme/base

(require srfi/26/cut)

(require (file "accessor.ss")
         (file "core.ss")
         (file "command.ss")
         (file "selector.ss")
         (file "test-base.ss"))

; Helpers --------------------------------------

; integer integer (integer integer -> xml) -> xml
(define (make-cells width height make-cell-body)
  (xml ,@(for/list ([j (in-range 0 height)])
           (xml (tr ,@(for/list ([i (in-range 0 width)])
                        (xml (td ,(make-cell-body i j)))))))))

; integer integer -> string
(define (make-simple-cell-body x y)
  (format "~a,~a" x y))

; integer integer -> xml
(define (make-inner-table x y)
  (xml (table (@ [class "inner"] [style "border: 1px solid blue"])
              ,(make-cells 3 3 (lambda (x2 y2)
                                 (xml ,(format "~a,~a ~a,~a" x (+ y 3) x2 y2)))))))

; Test suite -----------------------------------

(define selector-tests
  (test-suite "selector.ss"
    
    '#:before 
    (lambda ()
      (open/wait
       (lambda (request)
         (send/suspend
          (lambda (url)
            (make-html-response
             (xml (html (head (title "Selector tests"))
                        (body (ul (@ [id "list1"])
                                  (li (@ [id "item1"] [class "an-item"]) "item1")
                                  (li (@ [id "item2"] [class "an-item"]) "item2"))
                              (ul (@ [id "list2"])
                                  (li (@ [id "item3"] [class "an-item"]) "item3")
                                  (li (@ [id "item4"] [class "another-item"]) "item4"))
                              (ul (@ [id "list3"])
                                  (li (a (@ [href "#"]) "link1"))
                                  (li (a (@ [href "#"]) (strong "link2")))
                                  (li (span "link3"))))))))))))
    
    (test-case "node/document"
      (check-found (node/document)))
    
    (test-case "absolute node/id"
      (check-found (node/id "list1"))
      (check-found (node/id 'list2))
      (check-not-found (node/id "list4")))
    
    (test-case "absolute node/class"
      (check-found (node/class "an-item"))
      (check-found (node/class 'another-item))
      (check-not-found (node/class "not-item")))
    
    (test-case "absolute node/tag"
      (check-found (node/tag "ul"))
      (check-found (node/tag 'li))
      (check-not-found (node/tag "p")))
    
    (test-case "absolute node/xpath"
      (check-found (node/xpath "//li"))
      (check-found (node/xpath "//ul/descendant::li"))
      (check-not-found (node/xpath "//li/descendant::ul")))
    
    (test-case "relative node/id"
      (check-found (node/id "item1" (node/tag "ul")))
      (check-found (node/id "item1" (node/id "list1")))
      (check-not-found (node/id "item1" (node/id "list2"))))
    
    (test-case "relative node/id"
      (check-found (node/class "an-item" (node/id "list1")))
      (check-found (node/class "an-item" (node/id "list2")))
      (check-not-found (node/class "another-item" (node/id "list1"))))
    
    (test-case "relative node/tag"
      (check-found (node/tag "li" (node/tag "ul")))
      (check-found (node/tag "li" (node/id "list1")))
      (check-not-found (node/tag "p" (node/tag "ul"))))
    
    (test-case "relative node/xpath"
      (check-found (node/xpath "descendant::text()[contains(., 'item1')]" (node/tag "ul")))
      (check-found (node/xpath "descendant::text()[contains(., 'item1')]" (node/id "list1")))
      (check-not-found (node/xpath "descendant::text()[contains(., 'item1')]" (node/id "list2"))))
    
    (test-case "node/link/text"
      (check-found (node/link/text "link1"))
      (check-found (node/link/text "link2"))
      (check-not-found (node/link/text "link3")))
    
    (test-case "node/cell/xy"
      (open/wait
       (lambda (request)
         (send/suspend
          (lambda (url)
            (make-html-response
             (xml (html (head (title "Selector tests"))
                        (body (table (@ [class "outer"] [style "border: 1px solid red"])
                                     (thead ,(make-cells 3 3 make-simple-cell-body))
                                     (tbody ,(make-cells 3 3 make-inner-table)
                                     (tfoot ,(make-cells 3 3 make-simple-cell-body))))))))))))
      (check-equal? (inner-html-ref (node/cell/xy 1 1 (node/xpath "//table[@class = 'outer']"))) "1,1")
      (check-equal? (inner-html-ref (node/cell/xy 1 1 (node/xpath "//table[@class = 'inner']" (node/cell/xy 1 4 (node/xpath "//table[@class = 'outer']"))))) "1,4 1,1")
      (check-equal? (inner-html-ref (node/cell/xy 1 7 (node/xpath "//table[@class = 'outer']"))) "1,1"))
    
    ))

; Provide statements --------------------------- 

(provide selector-tests)
