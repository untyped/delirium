#lang scribble/doc

@(require "base.ss")

@(require (for-label scheme/base
                     (schemeunit-in)))

@title[#:tag "misc"]{Miscellaneous procedures}

@declare-exporting[(planet untyped/delirium/delirium)]

@defparam[current-delirium-delay delay (U natural? 'keypress #f)]{
Delays all browser commands by the specified number of seconds. Setting the value to the symbol @scheme['keypress] delays until the Enter key is pressed (watch out for the 30 second timeout/retry on AJAX requests in many popular browsers).}

@defproc[(run-tests/pause [test schemeunit-test?]) integer?]{
Version of @italic{Schemeunit.plt}'s @scheme[run-tests] procedure that pauses after each failed test and asks you if you wish to continue running tests. This is useful as it allows you to inspect the state of the web page at the point of failure to see what went wrong.}

@defproc[(schemeunit-test? [test any]) boolean]{
Predicate that returns @scheme[#t] if @schemeid[test] is either a SchemeUnit test suite or test case, and @scheme[#f] otherwise.}
