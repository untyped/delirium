#lang scheme/base

(require net/url
         web-server/servlet
         (file "delirium.ss")
         (file "instaweb-servlet-config.ss"))

; Servlet configuration ------------------------

; symbol
(define interface-version 'v1)

; number
(define timeout 15)

; Start procedure ------------------------------

; request -> response
(define (start request)
  (printf "== Delirium servlet start ~s~n" (url->string (request-uri request)))
  (run-delirium request 
                (test-ref)
                (run-tests-ref)))

; Provide statements --------------------------- 

(provide interface-version
         timeout
         start)
