#lang scheme/base

(require (only-in srfi/1/list iota)
         srfi/26/cut)

(require "accessor.ss"
         "command.ss"
         "core.ss"
         "selector.ss"
         "test-base.ss")

; Test suite -----------------------------------

(define command-tests
  (test-suite "command.ss"
    
    (test-case "open/wait, reload/wait, back/wait and forward/wait"
      (let ([open/title   (lambda (title)
                            (open/wait 
                             (lambda (request)
                               (send/back (make-html-response 
                                           (xml (head (title ,title))
                                                (body (p ,title))))))))]
            [check-reload (lambda (title)
                            (check-equal? (title-ref) title)
                            (reload/wait)
                            (check-equal? (title-ref) title))])
        (with-check-info (['sequence 'open])
          (open/title "Page 1")
          (check-reload "Page 1")
          (open/title "Page 2")
          (check-reload "Page 2")
          (open/title "Page 3")
          (check-reload "Page 3"))
        (with-check-info (['sequence 'back])
          (back/wait)
          (check-reload "Page 2")
          (back/wait)
          (check-reload "Page 1"))
        (with-check-info (['sequence 'forward])
          (forward/wait)
          (check-reload "Page 2")
          (forward/wait)
          (check-reload "Page 3"))
        (with-check-info (['sequence 'change])
          (back/wait)
          (check-reload "Page 2")
          (open/title "Page 4")
          (check-reload "Page 4"))
        (with-check-info (['sequence 'change-complete])
          (back/wait)
          (check-reload "Page 2")
          (forward/wait)
          (check-reload "Page 4"))))
    
    (test-case "click, click/wait"
      (let ([request-box (box #f)])
        (open/wait (lambda (request)
                     (send/suspend/dispatch
                      (lambda (embed-url)
                        (make-html-response
                         (xml (html (head (title "Test form"))
                                    (body (form (@ [method "POST"] 
                                                   [action ,(embed-url (lambda (request)
                                                                         (set-box! request-box request)
                                                                         (send/back (make-html-response
                                                                                     (xml (html (body (p "Submitted"))))))))])
                                                ,@(map (lambda (num)
                                                         (xml (div "Box " ,(number->string num)
                                                                   (input (@ [id    ,(format "box~a" num)]
                                                                             [name  ,(format "box~a" num)]
                                                                             [class "checkbox"]
                                                                             [type  "checkbox"])))))
                                                       (iota 3))
                                                (input (@ [id "submit"] [name "submit"] [type "submit"])))))))))))
        (click (node/id 'box1))
        (check-equal? (js-ref (!dot document (getElementById "box1") checked)) #t)
        (click/wait (node/id 'submit))
        (let ([bindings (request-bindings (unbox request-box))])
          (check-false (exists-binding? 'box0 bindings) "check 1")
          (check-true  (exists-binding? 'box1 bindings) "check 2")
          (check-false (exists-binding? 'box2 bindings) "check 3"))))
    
    (test-case "click, select, enter-text and click/wait"
      (let ([request-box (box #f)])
        (open/wait (lambda (request)
                     (send/suspend/dispatch
                      (lambda (embed-url)
                        (make-html-response
                         (xml (html (head (title "Test form"))
                                    (body (form (@ [method "POST"]
                                                   [action ,(embed-url (lambda (request)
                                                                         (set-box! request-box request)
                                                                         (send/back '(html (body (p "Submitted"))))))])
                                                (input (@ [id "check-box"] [name "check-box"] [type "checkbox"]))
                                                (select (@ [id "select"] [name "select"])
                                                        (option (@ [value "value1"]) "Value 1")
                                                        (option (@ [value "value2"]) "Value 2")
                                                        (option (@ [value "value3"]) "Value 3"))
                                                (input (@ [id "text-field"] [name "text-field"] [type "text"]))
                                                (input (@ [id "submit"] [name "submit"] [type "submit"])))))))))))
        (click (node/id 'check-box))
        (select (node/id 'select) "value2")
        (enter-text (node/id 'text-field) "Sample text")
        (check-exn exn:fail:browser? (cut click (node/id 'does-not-exist)))
        (check-exn exn:fail:browser? (cut select (node/id 'does-not-exist) "value"))
        (check-exn exn:fail:browser? (cut enter-text (node/id 'does-not-exist) "Text"))
        (click/wait (node/id 'submit))
        (let ([bindings (request-bindings (unbox request-box))])
          (check-true (exists-binding? 'check-box bindings) "check 1")
          (check-true (exists-binding? 'select bindings) "check 2")
          (check-equal? (extract-binding/single 'select bindings) "value2" "check 3")
          (check-true (exists-binding? 'text-field bindings) "check 4")
          (check-equal? (extract-binding/single 'text-field bindings) "Sample text" "check 5"))))
    
    (test-case "click*, select*, type*"
      (let ([request-box (box #f)])
        (open/wait (lambda (request)
                     (send/suspend/dispatch
                      (lambda (embed-url)
                        (make-html-response
                         (xml (html (head (title "Test form"))
                                    (body (form (@ [method "POST"]
                                                   [action ,(embed-url (lambda (request)
                                                                         (set-box! request-box request)
                                                                         (send/back '(html (body (p "Submitted"))))))])
                                                (input (@ [id "check-box1"] [name "check-box1"] [type "checkbox"]))
                                                (input (@ [id "check-box2"] [name "check-box2"] [type "checkbox"]))
                                                (select (@ [id "select1"] [name "select1"])
                                                        (option (@ [value "value1"]) "Value 1")
                                                        (option (@ [value "value2"]) "Value 2")
                                                        (option (@ [value "value3"]) "Value 3"))
                                                (select (@ [id "select2"] [name "select2"])
                                                        (option (@ [value "value1"]) "Value 1")
                                                        (option (@ [value "value2"]) "Value 2")
                                                        (option (@ [value "value3"]) "Value 3"))
                                                (input (@ [id "text-field1"] [name "text-field1"] [type "text"]))
                                                (input (@ [id "text-field2"] [name "text-field2"] [type "text"]))
                                                (input (@ [id "submit"] [name "submit"] [type "submit"])))))))))))
        (click* (node/jquery "input:checkbox"))
        (select* (node/jquery "select") 'value2)
        (enter-text* (node/jquery "input:text") "Sample text")
        (check-exn exn:fail:browser? (cut click* (node/id 'does-not-exist)))
        (check-exn exn:fail:browser? (cut select* (node/id 'does-not-exist) "value"))
        (check-exn exn:fail:browser? (cut enter-text* (node/id 'does-not-exist) "Text"))
        (click/wait (node/id 'submit))
        (let ([bindings (request-bindings (unbox request-box))])
          (check-true (exists-binding? 'check-box1 bindings) "check-box1")
          (check-true (exists-binding? 'check-box2 bindings) "check-box2")
          (check-true (exists-binding? 'select1 bindings) "select1")
          (check-true (exists-binding? 'select2 bindings) "select2")
          (check-equal? (extract-binding/single 'select1 bindings) "value2" "select1 value")
          (check-equal? (extract-binding/single 'select2 bindings) "value2" "select2 value")
          (check-true (exists-binding? 'text-field1 bindings) "text-field1")
          (check-true (exists-binding? 'text-field2 bindings) "text-field2")
          (check-equal? (extract-binding/single 'text-field1 bindings) "Sample text" "text-field2 value")
          (check-equal? (extract-binding/single 'text-field2 bindings) "Sample text" "text-field1 value"))))
    
    (test-case "select/wait and enter-text/wait"
      (letrec ([counter       0]
               [generate-page (lambda (embed-url)
                                (make-html-response
                                 (xml (html (head (title "Test form"))
                                            (body (select (@ [id "combo"]
                                                             [onchange ,(js (= (!dot window location href)
                                                                               ,(embed-url (lambda (request)
                                                                                             (set! counter (add1 counter))
                                                                                             (send/suspend/dispatch generate-page)))))])
                                                          (option (@ [value "a"]) "Option A")
                                                          (option (@ [value "b"]) "Option B")
                                                          (option (@ [value "c"]) "Option C"))
                                                  (input (@ [id "text"]
                                                            [value "initial"]
                                                            [onchange ,(js (= (!dot window location href)
                                                                              ,(embed-url (lambda (request)
                                                                                            (set! counter (sub1 counter))
                                                                                            (send/suspend/dispatch generate-page)))))])))))))])
        (open/wait (lambda (request) (send/suspend/dispatch generate-page)))
        (select/wait (node/id 'combo) "a")
        (check-equal? counter 0)
        (select/wait (node/id 'combo) "b")
        (check-equal? counter 1)
        (select/wait (node/id 'combo) "c")
        (check-equal? counter 2)
        (select/wait (node/id 'combo) "a")
        (check-equal? counter 2)
        (enter-text/wait (node/id 'text) "initial")
        (check-equal? counter 2)
        (enter-text/wait (node/id 'text) "other")
        (check-equal? counter 1)
        (enter-text/wait (node/id 'text) "initial")
        (check-equal? counter 1)
        (enter-text/wait (node/id 'text) "other")
        (check-equal? counter 0)))))

; Provide statements --------------------------- 

(provide command-tests)
