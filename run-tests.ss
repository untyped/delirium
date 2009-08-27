#lang scheme/base

(require web-server/dispatchers/dispatch
         "all-delirium-tests.ss"
         "delirium.ss")

; Main program body ----------------------------

(serve/delirium
 (lambda (request)
   (next-dispatcher))
 all-delirium-tests)

