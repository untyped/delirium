#lang scheme/base

(require srfi/13
         "base.ss"
         "core.ss")

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

; js -> (U string #f)
(define (inner-html-ref selector)
  (normalize-html-case
   (respond/expr
    (lambda (embed-url)
      (js ((!dot Delirium api getInnerHTML) ,selector))))))

; js -> (listof string)
(define (inner-html-ref* selector)
  (map normalize-html-case
       (respond/expr
        (lambda (embed-url)
          (js ((!dot Delirium api getAllInnerHTML) ,selector))))))

; js -> js-data
(define (js-ref expr)
  (respond/expr
   (lambda (embed-url)
     (js ((function ()
            (with (!dot Delirium (getWindow))
                  (return ,expr))))))))

; js -> (U string #f)
(define (jquery-path-ref selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getJQueryReference) ,selector)))))

; js -> (listof string)
(define (jquery-path-ref* selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getAllJQueryReferences) ,selector)))))

; -> boolean
;
; Delirium doesn't use any third-party libraries to support XPath in non-supporting browsers.
;
; If this function returns #f, your best bet is to use JQuery selector expressions instead.
(define (xpath-supported?)
  (js-ref (js (!dot Delirium xPathSupported))))

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

; Helpers --------------------------------------

; string -> string
;
; IE capitalizes tag names in innerHTML; FF does not.
; This function normalizes all tag names to lowercase.
;
; It also removes leading and trailing spaces from the HTML.
(define (normalize-html-case html)
  (and html (string-trim-both (regexp-replace* #px"[<]/?[^\\s]+" html string-downcase))))

; Provide statements ---------------------------

(provide/contract
 [url-ref          (-> string?)]
 [title-ref        (-> string?)]
 [inner-html-ref   (-> javascript-expression? (or/c string? false/c))]
 [inner-html-ref*  (-> javascript-expression? (listof string?))]
 [js-ref           (-> javascript-expression? any)]
 [jquery-path-ref  (-> javascript-expression? (or/c string? false/c))]
 [jquery-path-ref* (-> javascript-expression? (listof string?))]
 [xpath-supported? (-> boolean?)]
 [xpath-path-ref   (-> javascript-expression? (or/c string? false/c))]
 [xpath-path-ref*  (-> javascript-expression? (listof string?))])
