#lang scheme/base

(require web-server/dispatchers/dispatch
         web-server/servlet
         web-server/servlet-env
         (planet untyped/mirrors:1)
         "all-delirium-tests.ss"
         "base.ss"
         "delirium.ss")

; Main program body ----------------------------

(serve/delirium (lambda (request) (next-dispatcher)) all-delirium-tests)

