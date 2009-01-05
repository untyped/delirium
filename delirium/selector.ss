#lang scheme/base

(require scheme/contract
         srfi/26
         (planet untyped/unlib:3/number)
         "base.ss"
         "core.ss")

; Selectors ------------------------------------

; -> js
(define (node/document)
  (js (!dot Delirium api (findDocument))))

; (U string symbol) [js] -> js
(define (node/id id [roots (node/document)])
  (js (!dot Delirium api (findById ,roots ,(symbol+string->string id)))))
  
; (U string symbol) [js] -> js
(define (node/tag tag [roots (node/document)])
  (js (!dot Delirium api (findByTag ,roots ,(symbol+string->string tag)))))

; (U string symbol) [js] -> js
(define (node/class class [roots (node/document)])
  (node/jquery (format ".~a" class) roots))

; string [js] -> js
(define (node/xpath xpath [roots (node/document)])
  (js (!dot Delirium api (findByXPath ,roots ,xpath))))

; string [js] -> js
(define (node/jquery query [roots (node/document)])
  (js (!dot Delirium api (findByJQuery ,roots ,query))))

; string [js] -> js
(define (node/link/text text [roots (node/document)])
  (node/jquery (format "a:contains('~a')" text) roots))

; natural natural js -> js
(define (node/cell/xy x y roots)
  (js (!dot Delirium api (findTableCell ,roots ,x ,y))))

; js -> js
(define (node/first roots)
  (js (!array (!index ,roots 0))))

; js -> js
(define (node/parent roots)
  (js (!dot Delirium api (findParent ,roots))))

; Selector utilities ---------------------------

; js -> integer
(define (node-count selector)
  (respond/expr
   (lambda (embed-url)
     (js (!dot ,selector length)))))

; js -> boolean
(define (node-exists? selector)
  (not (zero? (node-count selector))))

; js -> void
(define-check (check-found selector)
  (with-check-info (['selector (javascript->string (js ,selector))])
    (check-not-exn (cut check-true (node-exists? selector)))))

; js -> void
(define-check (check-not-found selector)
  (with-check-info (['selector (javascript->string (js ,selector))])
    (check-not-exn (cut check-false (node-exists? selector)))))

; (U symbol string) -> string
(define (symbol+string->string item)
  (if (symbol? item)
      (symbol->string item)
      item))

; Provide statements ---------------------------

(provide/contract
 ; Selectors and selector utilities:
 [node/document   (-> javascript-expression?)]
 [node/id         (->* ((or/c string? symbol?)) (javascript-expression?) javascript-expression?)]
 [node/tag        (->* ((or/c string? symbol?)) (javascript-expression?) javascript-expression?)]
 [node/class      (->* ((or/c string? symbol?)) (javascript-expression?) javascript-expression?)]
 [node/xpath      (->* (string?) (javascript-expression?) javascript-expression?)]
 [node/jquery     (->* (string?) (javascript-expression?) javascript-expression?)]
 [node/link/text  (->* (string?) (javascript-expression?) javascript-expression?)]
 [node/cell/xy    (-> natural? natural? javascript-expression? javascript-expression?)]
 [node/first      (-> javascript-expression? javascript-expression?)]
 [node/parent     (-> javascript-expression? javascript-expression?)]
 [node-count      (-> javascript-expression? integer?)]
 [node-exists?    (-> javascript-expression? boolean?)]
 [check-found     (->* (javascript-expression?) (string?) any)]
 [check-not-found (->* (javascript-expression?) (string?) any)])
