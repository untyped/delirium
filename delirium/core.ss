#lang scheme/base

(require scheme/contract
         scheme/match
         (only-in srfi/1/list append-map drop-right)
         (only-in srfi/13/string string-pad-right)
         (prefix-in scheme: scheme/pretty)
         web-server/servlet
         (prefix-in pprint: (planet dherman/pprint/pprint))
         (planet untyped/mirrors/mirrors)
         (file "base.ss")
         (file "json.ss"))

; In the following type definitions:
;   embed-url : (request -> response) -> string

; request test (test -> any) -> response
(define (test/delirium request test test/ui)
  (test/ui test)
  (make-stop-response))

; Responders -----------------------------------

; (embed-url -> js) -> string
(define (respond/expr generate-expr)
  (respond/stmt
   (lambda (embed-url)
     ; string
     (define k-url (embed-url (lambda (request) request)))
     (js ((!dot Delirium sendResult) ,k-url ,(generate-expr embed-url))))))

; (embed-url -> js-stmt) -> string
(define (respond/stmt generate-stmt)
  ; string
  (define command #f)
  (parse-result
   (request-bindings
    (send/suspend/dispatch 
     (lambda (embed-url)
       ; string
       (define k-url
         (embed-url (lambda (request) request)))
       (set! command (js ((function ()
                            (try ,(generate-stmt embed-url)
                                 (catch exn
                                   ((!dot Delirium sendExn) ,k-url exn)))))))
       (make-js-response command))))
   (javascript->pretty-string command)))

; -> void
(define (make-stop-response)
  (make-js-response 
   (js ((function ()
          ((!dot Delirium stop)))))))

; Parsing results ------------------------------

; request-environment string -> any
(define (parse-result bindings command-string)
  ; type : (U 'exn 'json)
  (define type
    (if (exists-binding? 'type bindings)
        (string->symbol (extract-binding/single 'type bindings))
        (raise-exn exn:fail:browser
          "No return type received."
          command-string
          (void))))
  ; Procedure body:
  (case type
    [(result) (json-result->scheme bindings)]
    [(exn)    #;(printf "Command raised browser exn:~n~a~n" command-string)
              (raise-exn exn:fail:browser
                (format "Exception in browser: ~a" (json-result->string bindings))
                command-string
                (json-result->scheme bindings))]
    [else     #;(printf "Command raised browser exn:~n~a~n" command-string)
              (raise-exn exn:fail:browser
                (format "Unknown result type: ~s" type)
                command-string
                (json-result->scheme bindings))]))

; request-environment -> (U string #f)
(define (json-result->string bindings)
  (if (exists-binding? 'json bindings)
      (extract-binding/single 'json bindings)
      (void)))

; request-environment -> json-as-scheme
(define (json-result->scheme bindings)
  (if (exists-binding? 'json bindings)
      (let ([json-string (extract-binding/single 'json bindings)])
        (with-handlers ([exn? (lambda (exn) (format "Could not parse JSON: ~s" json-string))])
          (read-json (open-input-string json-string))))
      (void)))

; Contracts ------------------------------------

; contract
(define (schemeunit-test? item)
  (or (schemeunit-test-case? item)
      (schemeunit-test-suite? item)))

; (U vector list) -> list
(define (vector+list->list item)
  (if (vector? item)
      (vector->list item)
      item))

; Provide statements --------------------------- 

(provide (all-from-out (planet untyped/mirrors/mirrors))
         ; From Web Server:
         request?
         response?
         send/suspend/dispatch
         ; From Schemeunit:
         schemeunit-test?
         ; From Mirrors:
         javascript?
         javascript-expression?
         javascript-statement?)

(provide/contract
 [test/delirium      (-> request? schemeunit-test? (-> schemeunit-test? any) response?)]
 [respond/expr       (-> (-> procedure? javascript-expression?) any)]
 [respond/stmt       (-> (-> procedure? javascript?) any)]
 [make-stop-response (-> response?)])
