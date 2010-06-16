#lang scheme/base

(require "base.ss")

(require (prefix-in json: (json-in json)))

; Procedures -------------------------------------

; string -> json-serializable
(define read-json json:read)

; Provide statements -----------------------------

(provide (rename-out [json:json? json?]))

(provide/contract
 [read-json (-> input-port? json:json?)])
