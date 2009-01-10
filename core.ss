#lang scheme/base

(require scheme/contract
         scheme/match
         (only-in srfi/1/list append-map drop-right)
         (only-in srfi/13/string string-pad-right)
         (prefix-in scheme: scheme/pretty)
         web-server/servlet
         (prefix-in pprint: (planet "pprint.ss" ("dherman" "pprint.plt" 2)))
         (planet "mirrors.ss" ("untyped" "mirrors.plt" 1))
         (file "json/json.ss")
         (file "base.ss"))

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
        (raise-exn exn:fail:delirium "No return type received.")))
  ; Procedure body:
  (case type
    [(result) (parse-json-result bindings)]
    [(exn)    (raise-exn exn:fail:delirium:browser
                (format-browser-exn (parse-json-result bindings) command-string)
                command-string)]
    [else     (raise-exn exn:fail:delirium:browser
                (format "Unknown result type: ~s" type)
                command-string)]))

; request-environment -> (U json-as-scheme void)
(define (parse-json-result bindings)
  (if (exists-binding? 'json bindings)
      (let* ([json/string (extract-binding/single 'json bindings)]
             [json/scheme (json-read (open-input-string json/string))])
        json/scheme)
      (void)))

; json-scheme string -> string
(define (format-browser-exn result command-string)
  (format "Command:~n~a~nException:~n~a~n" command-string result))
  ; integer
  ;(define key-width
  ;  (apply max (map string-length (map car (vector+list->list result)))))
  ; (U string number boolean list) -> string 
  ;(define format-val
  ;  (match-lambda 
  ;    [(? boolean? val) (format "~a" val)]
  ;    [(? number? val)  (format "~a" val)]
  ;    [(? string? val)  (pprint:pretty-format 
  ;                       (pprint:nest (+ key-width 2) 
  ;                                    (apply pprint:h-append 
  ;                                           (drop-right (append-map
  ;                                                        (lambda (item)
  ;                                                          (list (pprint:text item) pprint:line))
  ;                                                        (regexp-split #rx"\n" val))
  ;                                                       1))))]))
  ; string
  ;(apply string-append
  ;       (map (lambda (kvp)
  ;              (format "~a: ~a~n"
  ;                      (string-pad-right (car kvp) key-width #\space)
  ;                      (regexp-replace* #rx"\n"
  ;                                       (format (cdr kvp))
  ;                                       (format "~a~n" (make-string key-width #\space)))))
  ;            (vector+list->list result))))

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

(provide (all-from-out (planet "mirrors.ss" ("untyped" "mirrors.plt" 1)))
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
