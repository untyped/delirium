#lang scheme/base

(require "base.ss")

(require web-server/managers/manager
         web-server/servlet
         web-server/servlet-env
         (unlib-in keyword)
         "accessor.ss"
         "command.ss"
         "core.ss"
         "selector.ss"
         "text-ui.ss")

; Procedures -----------------------------------

;  (request -> response) 
;  schemeunit-test
;  [#:run-tests?               boolean]
;  [#:run-tests                (-> schemeunit-test any)]
;  [#:manager                  (U manager #f)]
;  [#:port                     natural]
;  [#:listen-ip                (U string #f)]
;  [#:servlet-path             string]
;  [#:servlet-regexp           regexp]
;  [#:extra-files-paths        (listof path)]
;  [#:mime-types-path          (U path #f)]
;  [#:launch-browser?          boolean]
;  [#:file-not-found-responder (U (request -> response) #f)]
; ->
;  void
(define (serve/delirium
         start
         test
         #:run-tests?               [run-tests?               #t]
         #:run-tests                [run-tests                run-tests/pause]
         #:manager                  [manager                  #f]
         #:port                     [port                     8765]
         #:listen-ip                [listen-ip                "127.0.0.1"]
         #:servlet-path             [servlet-path             "/"]
         #:servlet-regexp           [servlet-regexp           #rx"^."]
         #:extra-files-paths        [extra-files-paths        null]
         #:mime-types-path          [mime-types-path          #f]
         #:launch-browser?          [launch-browser?          #t]
         #:file-not-found-responder [file-not-found-responder #f])
  ; (listof path)
  (define all-extra-files-paths
    `(,delirium-htdocs-path ,@extra-files-paths))
  
  (keyword-apply*
   serve/servlet
   (if run-tests?
       (make-delirium-controller start test run-tests)
       start)
   `(#:command-line? #t
                     ,@(if manager
                           `(#:manager ,manager)
                           null)
                     #:port                     ,port
                     #:listen-ip                ,listen-ip
                     #:servlet-path             ,(if run-tests? "/test" servlet-path)
                     #:servlet-regexp           ,servlet-regexp
                     #:extra-files-paths        ,all-extra-files-paths
                     ,@(if mime-types-path 
                           `(#:mime-types-path ,mime-types-path)
                           null)
                     #:launch-browser?          ,launch-browser?
                     ,@(if file-not-found-responder
                           `(#:file-not-found-responder ,file-not-found-responder)
                           null))))

; (request -> response) test-suite [(test-suite -> any)] -> (request -> response)
(define (make-delirium-controller servlet-controller test [run-tests run-tests/pause])
  (lambda (request)
    (if (regexp-match #rx"^/test" (url->string (request-uri request)))
        (run-delirium request test run-tests)
        (servlet-controller request))))

; test-suite -> void
(define (run-delirium request test [run-tests run-tests/pause])
  (send-test-page)
  (test/delirium request test run-tests)
  (send/finish (make-stop-response)))

; Helpers ----------------------------------------

; -> void
(define (send-test-page)
  (send/suspend/dispatch
   (lambda (embed-url)
     (make-html-response
      (xml ;,xhtml-1.0-transitional-doctype
       (html (@ [xmlns "http://www.w3.org/1999/xhtml"])
             (head (script (@ [type "text/javascript"] [src "/scripts/jquery/jquery-1.3.2.min.js"]))
                   (script (@ [type "text/javascript"] [src "/scripts/jquery/jquery.json-1.3.min.js"]))
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
                           (!raw ,(js ($ (function () (!dot Delirium (start "target" ,(embed-url (lambda (request) request))))))))
                           (!raw "\n// ]]>\n"))
                   (link (@ [rel "stylesheet"] [type "text/css"] [href "/styles/delirium/screen.css"])))
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

; request -> response
(define (default-404-handler request)
  (debug "404 not found" (url->string (request-uri request)))
  (make-html-response
   #:code    404
   #:message "Not found"
   (xml (html (head (title "404 not found"))
              (body (p "Sorry! We could not find that file or resource on our server:")
                    (blockquote (tt ,(url->string (request-uri request)))))))))

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
         run-tests/pause)

(provide/contract
 [serve/delirium           (->* ((-> request? response/full?) schemeunit-test?)
                                (#:run-tests? boolean?
                                              #:run-tests                (-> any/c any)
                                              #:manager                  (or/c manager? #f)
                                              #:port                     natural-number/c
                                              #:listen-ip                (or/c string? #f)
                                              #:servlet-path             string?
                                              #:servlet-regexp           regexp?
                                              #:extra-files-paths        (listof path?)
                                              #:mime-types-path          path?
                                              #:launch-browser?          boolean?
                                              #:file-not-found-responder (or/c (-> request? response/full?) false/c))
                                void?)]
 [make-delirium-controller (->* ((-> request? response/full?) schemeunit-test?)
                                ((-> schemeunit-test? any))
                                (-> request? response/full?))])
