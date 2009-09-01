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

; js -> (U string #f)
(define (text-content-ref selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getTextContent) ,selector)))))

; js -> (listof string)
(define (text-content-ref* selector)
  (respond/expr
   (lambda (embed-url)
     (js ((!dot Delirium api getAllTextContent) ,selector)))))

; js -> js-data
(define-syntax-rule (js-ref expr)
  (respond/expr
   (lambda (embed-url)
     (js ((function ()
            (with (!dot Delirium (getWindow))
                  (return expr))))))))

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
  (js-ref (!dot Delirium xPathSupported)))

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

(provide js-ref)

(provide/contract
 [url-ref           (-> string?)]
 [title-ref         (-> string?)]
 [inner-html-ref    (-> javascript-expression? (or/c string? #f))]
 [inner-html-ref*   (-> javascript-expression? (listof string?))]
 [text-content-ref  (-> javascript-expression? (or/c string? #f))]
 [text-content-ref* (-> javascript-expression? (listof string?))]
 [jquery-path-ref   (-> javascript-expression? (or/c string? #f))]
 [jquery-path-ref*  (-> javascript-expression? (listof string?))]
 [xpath-supported?  (-> boolean?)]
 [xpath-path-ref    (-> javascript-expression? (or/c string? #f))]
 [xpath-path-ref*   (-> javascript-expression? (listof string?))])
