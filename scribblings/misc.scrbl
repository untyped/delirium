#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:3)))

@title[#:tag "misc"]{Miscellaneous procedures}

@declare-exporting[(planet untyped/delirium/delirium)]

@defproc[(run-tests/pause [test schemeunit-test?]) integer?]{
Version of @italic{Schemeunit.plt}'s @scheme[run-tests] procedure that pauses after each failed test and asks you if you wish to continue running tests. This is useful as it allows you to inspect the state of the web page at the point of failure to see what went wrong.}

@defproc[(schemeunit-test? [test any]) boolean]{
Predicate that returns @scheme[#t] if @schemeid[test] is either a SchemeUnit test suite or test case, and @scheme[#f] otherwise.}
