#lang scheme/base

(require scheme/contract
         net/url
         web-server/http/request-structs
         web-server/servlet
         "base.ss"
         "accessor.ss"
         "command.ss"
         "core.ss"
         "selector.ss")

; Procedures -----------------------------------

; test-suite (request -> response) [(test-suite -> any)] -> (request -> response)
(define (make-delirium-controller test servlet-controller [run-tests test/text-ui/pause-on-fail])
  (lambda (request)
    (if (regexp-match #rx"^/test" (url->string (request-uri request)))
        (run-delirium request test run-tests)
        (servlet-controller request))))

; test-suite -> void
(define (run-delirium request test [run-tests test/text-ui/pause-on-fail])
  (send-test-page)
  (test/delirium request test run-tests)
  (send/finish (make-stop-response)))

; -> void
(define (send-test-page)
  (send/suspend/dispatch
   (lambda (embed-url)
     (make-html-response
      (xml ;,xhtml-1.0-transitional-doctype
       (html (@ [xmlns "http://www.w3.org/1999/xhtml"])
             (head (script (@ [type "text/javascript"] [src "/scripts/prototype/prototype.js"]))
                   (script (@ [type "text/javascript"] [src "/scripts/jquery/jquery.js"]))
                   (script (@ [type "text/javascript"]) ,(js (!dot jQuery (noConflict))))
                   ;(!raw "\n<!--[if IE]>\n")
                   ;(script (@ [type "text/javascript"] [src "/scripts/firebug/firebug-lite.js"]))
                   ;(!raw "\n<![endif]-->\n")
                   (script (@ [type "text/javascript"] [src "/scripts/delirium/delirium.js"]))
                   (script (@ [type "text/javascript"] [src "/scripts/delirium/map.js"]))
                   (script (@ [type "text/javascript"] [src "/scripts/delirium/accessor.js"]))
                   (script (@ [type "text/javascript"] [src "/scripts/delirium/command.js"]))
                   (script (@ [type "text/javascript"] [src "/scripts/delirium/selector.js"]))
                   (script (@ [type "text/javascript"])
                           (!raw "\n// <![CDATA[\n")
                           (!raw ,(js (!dot Event (observe window
                                                           "load"
                                                           (function ()
                                                             (!dot Delirium
                                                                   (start "target"
                                                                          ,(embed-url (lambda (request) request)))))))))
                           (!raw "\n// ]]>\n"))
                   (link (@ [rel "stylesheet"] [type "text/css"] [href "/style/delirium/screen.css"])))
             (body (div (@ [id "container"])
                        (table (@ [id "layout"] [cellspacing "0"] [cellpadding "0"])
                               (tbody (tr (@ [id "statusrow"])
                                          (td (table (tr (th "Title:")
                                                         (td (@ [id "currenttitle"]) " "))
                                                     (tr (th "URL:") 
                                                         (td (tt (@ [id "currenturl"]) " "))))))
                                      (tr (@ [id "targetrow"])
                                          (td (iframe (@ [id "target"]))))
                                      (tr (@ [id "titlerow"])
                                          (th (@ [id "title"])
                                              "Delirium by " (a (@ [href "http://www.untyped.com"])
                                                                "Untyped")))))))))))))

; Provide statements --------------------------- 

(provide (all-from-out "accessor.ss"
                       "command.ss"
                       "selector.ss")
         current-delirium-delay
         delirium-htdocs-path
         schemeunit-test?
         javascript?
         javascript-expression?
         javascript-statement?
         test/text-ui/pause-on-fail)

(provide/contract
 [make-delirium-controller (->* (schemeunit-test? (-> request? response?))
                                ((-> schemeunit-test? any))
                                (-> request? response?))]
 [run-delirium             (->* (request? schemeunit-test?)
                                (procedure?)
                                response?)])
