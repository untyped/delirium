#lang setup/infotab

(define name "delirium")

(define blurb 
  '((p "A tool for testing PLT web application user interfaces using Javascript remote control scripts and SchemeUnit test suites.")))

(define release-notes
  '((p "Changes:")
    (ul (li "updated to PLT 4.1.3;")
        (li "added " (tt "main.ss") " for shorter require statements."))))

(define primary-file "main.ss")

(define url "http://svn.untyped.com/delirium/")

(define categories '(net devtools))

(define scribblings '(("scribblings/delirium.scrbl" (multi-page))))

(define required-core-version "4.0")

(define repositories '("4.x"))
