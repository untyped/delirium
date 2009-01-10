#lang setup/infotab

(define name "delirium")

(define compile-omit-files
  '("doc"))

(define blurb 
  '((p "A tool for testing PLT web application user interfaces. "
       "Delirium allows programmers to write user interface tests with "
       "unprecidented clarity and speed.")))

(define release-notes
  '((p "Updated for PLT 4.x; dramatically expanded and improved the browser API.")))

(define primary-file "delirium.ss")

(define url "http://svn.untyped.com/delirium/")

(define doc.txt "doc.txt")

(define categories '(net devtools))

(define scribblings '(("doc/delirium.scrbl" (multi-page))))

(define required-core-version "4.0")

(define repositories '("4.x"))
