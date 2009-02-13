#lang scheme/base

(require scheme/contract
         srfi/26/cut)

(require "base.ss"
         "core.ss")

; Commands -------------------------------------

; (U (request -> response) string) -> void
(define (open/wait url+generate)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api openAndWait)
          ,(embed-url (lambda (request) request))
          ,(if (string? url+generate)
               url+generate
               (embed-url url+generate)))))))

; -> void
(define (reload/wait)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api reloadAndWait)
          ,(embed-url (lambda (request) request)))))))

; -> void
(define (back/wait)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api backAndWait)
          ,(embed-url (lambda (request) request)))))))

; -> void
(define (forward/wait)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api forwardAndWait)
          ,(embed-url (lambda (request) request)))))))

; js -> void
(define (click selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api click) ,selector)))))

; js -> void
(define (click* selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api clickAll) ,selector)))))

; js -> request
(define (click/wait selector)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api clickAndWait)
          ,(embed-url (lambda (request) request))
          ,selector)))))

; js (U symbol string) -> void
(define (select selector value)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api select) ,selector ,(symbol+string->string value))))))

; js (U symbol string) -> void
(define (select* selector value)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api selectAll) ,selector ,(symbol+string->string value))))))

; js (U symbol string) -> void
(define (select/wait selector value)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api selectAndWait)
          ,(embed-url (lambda (request) request))
          ,selector 
          ,(symbol+string->string value))))))

; js string -> void
(define (enter-text selector value)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api enterText) ,selector ,value)))))

; js string -> void
(define (enter-text* selector value)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api enterTextAll) ,selector ,value)))))

; js string -> void
(define (enter-text/wait selector value)
  (respond/stmt
   (lambda (embed-url)
     (js ((!dot Delirium api enterTextAndWait)
          ,(embed-url (lambda (request) request))
          ,selector 
          ,value)))))

; js -> void
(define (focus selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot (!index ,selector 0) focus))))))

; js -> void
(define (blur selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot (!index ,selector 0) blur))))))

; Helpers --------------------------------------

; (U symbol string) -> string
(define (symbol+string->string item)
  (if (symbol? item)
      (symbol->string item)
      item))

; string -> string
(define (protect-url url-string)
  (regexp-replace #rx"test" url-string "target"))

; Provide statements ---------------------------

(provide/contract
 [open/wait        (-> (or/c (-> request? response/full?) string?) void?)]
 [reload/wait      (-> void?)]
 [back/wait        (-> void?)]
 [forward/wait     (-> void?)]
 [click            (-> javascript-expression? void?)]
 [click*           (-> javascript-expression? void?)]
 [click/wait       (-> javascript-expression? void?)]
 [select           (-> javascript-expression? (or/c string? symbol?) any)]
 [select*          (-> javascript-expression? (or/c string? symbol?) any)]
 [select/wait      (-> javascript-expression? (or/c string? symbol?) any)]
 [enter-text       (-> javascript-expression? string? any)]
 [enter-text*      (-> javascript-expression? string? any)]
 [enter-text/wait  (-> javascript-expression? string? any)]
 [focus            (-> javascript-expression? void?)]
 [blur             (-> javascript-expression? void?)])
