#lang setup/infotab

(define name "delirium")

(define compile-omit-files
  '("doc"))

(define blurb 
  '((p "A tool for testing PLT web application user interfaces. "
       "Delirium allows programmers to write user interface tests with "
       "unprecedented clarity and speed.")))

(define release-notes
  '((p "Added missing documentation for " (tt "node-count") ", " (tt "node-exists?") ", " 
       (tt "check-found") " and " (tt "check-not-found") ".")))

(define primary-file "delirium.ss")

(define url "http://svn.untyped.com/delirium/")

(define doc.txt "doc.txt")

(define categories '(net devtools))

(define scribblings '(("doc/delirium.scrbl" (multi-page))))

(define required-core-version "4.0")

(define repositories '("4.x"))
