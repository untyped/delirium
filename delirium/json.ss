#lang scheme/base

(require scheme/contract
         (prefix-in json: (planet dherman/json/json)))

; Procedures -------------------------------------

; string -> json-serializable
(define read-json json:read)

; Provide statements -----------------------------

(provide (rename-out [json:json? json?]))

(provide/contract
 [read-json (-> input-port? json:json?)])