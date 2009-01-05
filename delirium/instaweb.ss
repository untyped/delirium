#lang scheme/base

(require net/sendurl
         scheme/async-channel
         (planet schematics/instaweb/defaults)
         (planet schematics/instaweb/dispatcher)
         (planet schematics/instaweb/instaweb)
         (file "base.ss")
         (file "dispatcher.ss")
         (file "instaweb-servlet-config.ss"))

; Procedures -----------------------------------

; symbol
(define undefined (gensym 'undefined))

; symbol
(define undefined-keyword (gensym 'undefined-keyword))

; any -> boolean
(define (defined? item)
  (not (eq? undefined item)))

;  #:test               schemeunit-test
;  [#:port              integer]
;  [#:listen-ip         string]
;  [#:run-tests         (-> schemeunit-test any)]
;  [#:servlet-lang      (U 'scheme 'scheme/base 'mzscheme 'web-server)]
;  [#:servlet-path      (U path string #f)]
;  [#:servlet-namespace (U (listof require-spec) #f)]
;  [#:htdocs-path       (list-of (U path string))]
;  [#:mime-types-path   path]
;  [#:run-tests?        boolean]
;  [#:send-url?         boolean]
;  [#:test-url          string]
;  [#:new-window?       boolean]
; ->
;  void
(define (instaweb/delirium
         #:test              test
         #:port              [port                     8765]
         #:listen-ip         [listen-ip                "127.0.0.1"]
         #:run-tests         [run-tests                test/text-ui/pause-on-fail]
         #:servlet-lang      [target-servlet-lang      'scheme/base]
         #:servlet-path      [target-servlet-path      "servlet.ss"]
         #:servlet-namespace [target-servlet-namespace default-servlet-namespace]
         #:htdocs-path       [target-htdocs-path       default-htdocs-path]
         #:mime-types-path   [target-mime-types-path   default-mime-types-path]
         #:send-url?         [send-url?                #t]
         #:test-url          [test-url                 "/test"]
         #:new-window?       [new-window?              #t])
  
  (define target-app-dispatcher
    (make-application-dispatcher
     #:servlet-lang      target-servlet-lang
     #:servlet-path      target-servlet-path
     #:servlet-namespace target-servlet-namespace))
  
  (instaweb/delirium/dispatcher
   #:test            test
   #:port            port
   #:listen-ip       listen-ip
   #:run-tests       run-tests
   #:app-dispatcher  target-app-dispatcher
   #:htdocs-path     target-htdocs-path
   #:mime-types-path target-mime-types-path
   #:send-url?       send-url?
   #:new-window?     new-window?))

;   #:test              schemeunit-test
;   #:app-dispatcher    (connection request -> void)
;  [#:port              integer]
;  [#:listen-ip         string]
;  [#:run-tests         (-> schemeunit-test any)]
;  [#:htdocs-path       (list-of (U path string))]
;  [#:mime-types-path   path]
;  [#:run-tests?        boolean]
;  [#:send-url?         boolean]
;  [#:test-url          string]
;  [#:new-window?       boolean]
; ->
;  void
;
; where run-server-thunk  : (-> stop-server-thunk)
;   and stop-server-thunk : (-> void)
(define (instaweb/delirium/dispatcher
         #:test              test
         #:app-dispatcher    target-app-dispatcher
         #:port              [port                   8765]
         #:listen-ip         [listen-ip              "127.0.0.1"]
         #:run-tests         [run-tests              test/text-ui/pause-on-fail]
         #:htdocs-path       [target-htdocs-path     default-htdocs-path]
         #:mime-types-path   [target-mime-types-path default-mime-types-path]
         #:send-url?         [send-url?              #t]
         #:test-url          [test-url               "/test"]
         #:new-window?       [new-window?            #t])
  
  (define target-dispatcher
    (make-instaweb-dispatcher
     #:app-dispatcher  target-app-dispatcher
     #:htdocs-path     target-htdocs-path
     #:mime-types-path target-mime-types-path))
  
  (define delirium-dispatcher
    (make-delirium-dispatcher
     #:test              test
     #:run-tests         run-tests
     #:test-url          test-url
     #:target-dispatcher target-dispatcher))
  
  (define result-channel
    (make-async-channel))
  
  (define (run-tests+stop test)
    (async-channel-put
     result-channel
     (begin0
       (run-tests test)
       ; For whatever reason, this ain't returning in some of our Untyped software.
       ; Given that we're going to quit from mzscheme anyway we don't *need* to
       ; gracefully stop the server here.
       #;(stop-server))))
  
  (define stop-server
    (begin (test-set! test)
           (run-tests-set! run-tests+stop)
           (run-server port listen-ip #:dispatcher delirium-dispatcher)))
  
  (if send-url?
      (begin (printf "Sending the test URL to your default browser.~n")
             (send-url test-url new-window?))
      (begin (printf "Visit \"http://127.0.0.1:~a~a\" in your browser to start the tests." port test-url)))
  
  (async-channel-get result-channel))

; Provide statements --------------------------- 

(provide instaweb/delirium
         instaweb/delirium/dispatcher
         test/text-ui/pause-on-fail)
