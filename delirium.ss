#lang scheme/base

(require scheme/contract
         net/url
         web-server/http
         web-server/servlet
         web-server/servlet-env
         web-server/stuffers
         web-server/configuration/configuration-table
         web-server/configuration/responders
         (prefix-in fsmap: web-server/dispatchers/filesystem-map)
         (prefix-in files: web-server/dispatchers/dispatch-files)
         (prefix-in lift: web-server/dispatchers/dispatch-lift)
         (prefix-in sequence: web-server/dispatchers/dispatch-sequencer)
         web-server/managers/lru
         web-server/managers/manager
         web-server/private/mime-types
         web-server/private/util
         (planet untyped/unlib:3/keyword)
         "base.ss"
         "accessor.ss"
         "command.ss"
         "core.ss"
         "selector.ss")

; Procedures -----------------------------------

(define (serve/delirium
         start
         test
         #:run-tests                 [run-tests                 run-tests/pause]
         #:port                      [port                      8765]
         #:listen-ip                 [listen-ip                 "127.0.0.1"]
         #:servlet-manager           [servlet-manager           (make-default-manager "Servlet")]
         #:tests-manager             [tests-manager             (make-default-manager "Test")]
         #:servlet-path              [servlet-path              "/servlets/standalone.ss"]
         #:tests-path                [tests-path                 "/test"]
         #:servlet-regexp            [servlet-regexp            (regexp (format "^~a" servlet-path))]
         #:tests-regexp              [tests-regexp              (regexp (format "^~a" tests-path))]
         #:server-root-path          [server-root-path          '(lib "web-server/default-web-root")]
         #:servlet-extra-files-paths [servlet-extra-files-paths null]
         #:tests-extra-files-paths   [tests-extra-files-paths   (list delirium-htdocs-path)]
         #:servlet-current-directory [servlet-current-directory (current-directory)]
         #:tests-current-directory   [tests-current-directory   servlet-current-directory]
         #:servlet-namespace         [servlet-namespace         null]
         #:tests-namespace           [tests-namespace           servlet-namespace]
         #:servlet-stateless?        [servlet-stateless?        #f]
         #:servlet-stuffer           [servlet-stuffer           default-stuffer]
         #:mime-types-path           [mime-types-path           (make-mime-types-path server-root-path)]
         #:launch-browser?           [launch-browser?           #t]
         #:file-not-found-responder  [file-not-found-responder  (gen-file-not-found-responder
                                                                 (build-path server-root-path "conf" "not-found.html"))])
  (serve/launch/wait
   (sequence:make
    (dispatch/delirium start
                       test
                       #:run-tests                 run-tests
                       #:servlet-regexp            servlet-regexp
                       #:tests-regexp              tests-regexp
                       #:servlet-namespace         servlet-namespace
                       #:tests-namespace           tests-namespace
                       #:servlet-current-directory servlet-current-directory
                       #:tests-current-directory   tests-current-directory
                       #:servlet-stateless?        servlet-stateless?
                       #:servlet-stuffer           servlet-stuffer
                       #:servlet-manager           servlet-manager
                       #:tests-manager             tests-manager)
    (map (lambda (extra-files-path)
           (files:make
            #:url->path (fsmap:make-url->path extra-files-path)
            #:path->mime-type (make-path->mime-type mime-types-path)
            #:indices (list "index.html" "index.htm")))
         (append tests-extra-files-paths servlet-extra-files-paths))
    (files:make
     #:url->path (fsmap:make-url->path (build-path server-root-path "htdocs"))
     #:path->mime-type (make-path->mime-type mime-types-path)
     #:indices (list "index.html" "index.htm"))
    (lift:make file-not-found-responder))))

(define (dispatch/delirium start
                           test
                           #:run-tests                 [run-tests                 run-tests/pause]
                           #:servlet-regexp            [servlet-regexp            #rx""]
                           #:tests-regexp              [tests-regexp              #rx"^/test"]
                           #:servlet-namespace         [servlet-namespace         null]
                           #:tests-namespace           [tests-namespace           servlet-namespace]
                           #:servlet-current-directory [servlet-current-directory (current-directory)]
                           #:tests-current-directory   [tests-current-directory   servlet-current-directory]
                           #:servlet-stateless?        [servlet-stateless?        #f]
                           #:servlet-stuffer           [servlet-stuffer           default-stuffer]
                           #:servlet-manager           [servlet-manager           (make-default-manager "Servlet")]
                           #:tests-manager             [tests-manager             (make-default-manager "Test")])
  (sequence:make (dispatch/servlet (lambda (request)
                                     (run-delirium request test run-tests))
                                   #:regexp            tests-regexp
                                   #:namespace         null
                                   #:current-directory tests-current-directory
                                   #:manager           tests-manager)
                 (dispatch/servlet start
                                   #:regexp            servlet-regexp
                                   #:namespace         servlet-namespace
                                   #:current-directory servlet-current-directory
                                   #:stateless?        servlet-stateless?
                                   #:stuffer           servlet-stuffer
                                   #:manager           servlet-manager)))

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

; request -> response
(define (default-404-handler request)
  (debug "404 not found" (url->string (request-uri request)))
  (make-html-response
   #:code    404
   #:message "Not found"
   (xml (html (head (title "404 not found"))
              (body (p "Sorry! We could not find that file or resource on our server:")
                    (blockquote (tt ,(url->string (request-uri request)))))))))

; string -> manager
(define (make-default-manager page-type)
  (make-threshold-LRU-manager
   (lambda (request)
     `(html (head (title ,page-type " page Has Expired."))
            (body (p "Sorry, this page has expired. Please go back."))))
   (* 64 1024 1024)))

; path -> path
(define (make-mime-types-path server-root-path)
  (let ([path (build-path server-root-path "mime.types")])
    (if (file-exists? path)
        path
        (build-path (directory-part default-configuration-table-path) "mime.types"))))

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
                                (#:run-tests procedure?
                                             #:port                      natural-number/c
                                             #:listen-ip                 (or/c string? #f)
                                             #:servlet-manager           manager?
                                             #:tests-manager             manager?
                                             #:servlet-path              string?
                                             #:tests-path                string?
                                             #:servlet-regexp            regexp?
                                             #:tests-regexp              regexp?
                                             #:server-root-path          any/c
                                             #:servlet-extra-files-paths (listof path?)
                                             #:tests-extra-files-paths   (listof path?)
                                             #:servlet-current-directory path?
                                             #:tests-current-directory   path?
                                             #:servlet-namespace         any/c
                                             #:tests-namespace           any/c
                                             #:servlet-stateless?        boolean?
                                             #:servlet-stuffer           stuffer?
                                             #:mime-types-path           path?
                                             #:launch-browser?           boolean?
                                             #:file-not-found-responder  (-> request? response/full?))
                                void?)])
