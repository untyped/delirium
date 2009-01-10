#lang scheme/base

(require scheme/contract
         (file "base.ss")
         (file "accessor.ss")
         (file "command.ss")
         (file "core.ss")
         (file "selector.ss"))

; Procedures -----------------------------------

; test-suite -> response
(define (run-delirium request test [run-tests test/text-ui/pause-on-fail])
  (send-test-page)
  (test/delirium request test run-tests)
  (make-stop-response))

; -> void
(define (send-test-page)
  (send/suspend/dispatch
   (lambda (embed-url)
     (make-html-response
      (xml ;,xhtml-1.0-transitional-doctype
           (html (@ [xmlns "http://www.w3.org/1999/xhtml"])
                 (head (script (@ [type "text/javascript"] [src "/scripts/delirium/lib/prototype/prototype.js"]))
                       (script (@ [type "text/javascript"] [src "/scripts/delirium/core/delirium.js"]))
                       (script (@ [type "text/javascript"] [src "/scripts/delirium/core/map.js"]))
                       (script (@ [type "text/javascript"] [src "/scripts/delirium/core/accessor.js"]))
                       (script (@ [type "text/javascript"] [src "/scripts/delirium/core/command.js"]))
                       (script (@ [type "text/javascript"] [src "/scripts/delirium/core/selector.js"]))
                       (script (@ [type "text/javascript"])
                               (!raw "\n// <![CDATA[\n")
                               (!raw ,(js ((!dot Event observe)
                                           window
                                           "load"
                                           (function ()
                                             ((!dot Delirium start) 
                                              "target"
                                              ,(embed-url (lambda (request) request)))))))
                               (!raw "\n// ]]>\n"))
                       (link (@ [rel "stylesheet"] [type "text/css"] [href "/stylesheets/delirium/delirium.css"])))
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

(provide (all-from-out (file "accessor.ss")
                       (file "command.ss")
                       (file "selector.ss"))
         schemeunit-test?
         javascript?
         javascript-expression?
         javascript-statement?
         test/text-ui/pause-on-fail)

(provide/contract
 [run-delirium (->* (request? schemeunit-test?) (procedure?) response?)])
