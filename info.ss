#lang setup/infotab

(define name "Delirium")

(define blurb 
  '((p "A tool for testing PLT web application user interfaces using Javascript remote control scripts and SchemeUnit test suites.")))

(define release-notes
  '((p "Changes:")
    (ul (li "updated to PLT 4.2.1."))))

(define primary-file "main.ss")

(define url "http://svn.untyped.com/delirium/")

(define categories '(net devtools))

(define scribblings '(("scribblings/delirium.scrbl" (multi-page))))

(define required-core-version "4.2.1")

(define repositories '("4.x"))
