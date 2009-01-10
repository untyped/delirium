#lang scheme/base

(require scheme/contract)

(require (file "base.ss")
         (file "core.ss"))

; Accessors ------------------------------------

; -> string
(define (url-ref)
  (respond/expr 
   (lambda (embed-url)
     (js ((!dot Delirium history current))))))

; -> string
(define (title-ref)
  (respond/expr 
   (lambda (embed-url)
     (js ((!dot Delirium api getTitle))))))

; js -> (listof string)
(define (inner-html-ref selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getInnerHTML) ,selector)))))

; js -> (listof string)
(define (inner-html-ref* selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getAllInnerHTML) ,selector)))))

; js -> js-data
(define (js-ref expr)
  (respond/expr
   (lambda (embed-url)
     (js ((function ()
                 (with (!dot Delirium target contentWindow)
                       (return ,expr))))))))

; js -> (U string #f)
(define (xpath-path-ref selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getXPathReference) ,selector)))))

; js -> (U string #f)
(define (xpath-path-ref* selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getAllXPathReferences) ,selector)))))

; Provide statements ---------------------------

(provide/contract
 [url-ref         (-> string?)]
 [title-ref       (-> string?)]
 [inner-html-ref  (-> javascript-expression? (or/c string? false/c))]
 [inner-html-ref* (-> javascript-expression? (listof string?))]
 [js-ref          (-> javascript-expression? any)]
 [xpath-path-ref  (-> javascript-expression? (or/c string? false/c))]
 [xpath-path-ref* (-> javascript-expression? (listof string?))])
