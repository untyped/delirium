#lang scheme/base

(require net/url
         web-server/dispatchers/dispatch
         (prefix-in filter:    web-server/dispatchers/dispatch-filter)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         (planet schematics/instaweb/defaults)
         (planet schematics/instaweb/dispatcher)
         (planet untyped/unlib/url)
         web-server/private/request-structs
         (file "base.ss")
         (file "instaweb-servlet-config.ss"))

;  #:target-dispatcher (U (-> clear-cache-thunk (connection request -> void)) #f)
;  #:htdocs-path       (listof (U path string))
;  #:mime-types-path   path
; ->
;  dispatcher
;
; If #:servlet-lang is custom, #:custom-dispatcher is invoked to create the servlet part of the dispatcher.
; If #:servlet-lang is any other value, #:servlet-path and #:servlet-namespace are used to specify the arguments
; to the appropriate default constructor from web server.
;
; When they are not being used, #:servlet-path, #:servlet-namespace or #:custom-dispatcher must be #f.
; exn:fail:contract is raised if this is not the case.
(define (make-delirium-dispatcher
         #:test              test
         #:run-tests         run-tests
         #:test-url          test-url
         #:target-dispatcher target-dispatcher)
  
  (define delirium-dispatcher
    (make-application-dispatcher
     #:servlet-lang      'scheme/base
     #:servlet-path      delirium-servlet-path
     #:servlet-namespace `((file ,(path->string delirium-servlet-config-path)))))
  
  (make-instaweb-dispatcher
   #:app-dispatcher  (lambda (conn req)
                       (if (string=? (url->string (url-path-only (url-remove-params (request-uri req)))) test-url)
                           (delirium-dispatcher conn req)
                           (target-dispatcher conn req)))
   #:htdocs-path     (list delirium-htdocs-path)
   #:mime-types-path default-mime-types-path))

; Provide statements -----------------------------

(provide make-delirium-dispatcher)
