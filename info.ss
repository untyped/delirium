#lang setup/infotab

(define name "delirium")

(define blurb 
  '((p "A tool for testing PLT web application user interfaces. "
       "Delirium allows programmers to write UI using all the clarity and speed of SchemeUnit.")))

(define release-notes
  '((p "This release focuses on browser compatibility. Delirium has been tested successfully on Internet Explorer 6 and 7, "
       "Firefox 2 and 3 for Windows and OS X, and Safari 3 for OS X. The XPath functions in the API only work natively in Firefox, "
       "so jQuery selectors and accessors have been added to provide flexible cross-browser node selection.")
    (p "Note: this version of Delirium has only been tested with SchemeUnit 2. "
       "Support for SchemeUnit 3 is planned for a future release.")))

(define primary-file "delirium.ss")

(define url "http://svn.untyped.com/delirium/")

(define categories '(net devtools))

(define scribblings '(("scribblings/delirium.scrbl" (multi-page))))

(define required-core-version "4.0")

(define repositories '("4.x"))
