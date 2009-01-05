#lang scheme/base

(require web-server/dispatchers/dispatch
         web-server/servlet
         web-server/servlet-env
         (planet untyped/mirrors:1)
         "all-delirium-tests.ss"
         "base.ss"
         "delirium.ss")

; Main program body ----------------------------

(serve/servlet
 (make-delirium-controller
  all-delirium-tests
  (lambda (request)
    (next-dispatcher)))
 #:command-line?     #t
 #:launch-browser?   #t
 #:port              8765 
 #:listen-ip         "127.0.0.1"
 #:servlet-path      "/test"
 #:servlet-regexp    #rx"^."
 #:extra-files-paths (list delirium-htdocs-path)
 #:file-not-found-responder
 (lambda (request)
   (debug "404 not found" (url->string (request-uri request)))
   (make-html-response
    (xml (html (head (title "404 not found"))
               (body (p "Looks like something is missing:")
                     (blockquote (tt ,(url->string (request-uri request))))))))))

