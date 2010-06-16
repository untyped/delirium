#lang setup/infotab

(define name "Delirium")

(define blurb 
  '((p "Acceptance testing for Racket web applications.")))

(define release-notes
  '((p "Changes:")
    (ul (li "updated to json.plt version 3 (from version 1.2: note that Javascript nulls are represented in Scheme as #\null instead of (void))"))))

(define primary-file "main.ss")

(define url "http://svn.untyped.com/delirium/")

(define categories '(net devtools))

(define scribblings '(("scribblings/delirium.scrbl" (multi-page))))

(define required-core-version "4.1.3")

(define repositories '("4.x"))

(define compile-omit-paths
  '("autoplanet.ss"
    "build.ss"
    "planet"
    "planetdev"))