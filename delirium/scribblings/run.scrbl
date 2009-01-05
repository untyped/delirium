#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:2/test)))

@title[#:tag "run"]{Running Delirium}

@declare-exporting[(planet untyped/delirium/delirium)]

Delirium can be started in one of several ways:

@section{Running Delirium from within a servlet}

@defproc[(run-delirium [request request?]
                       [test schemeunit-test?]
                       [run-tests procedure? test/text-ui/pause-on-fail])
         response?]{
Sends the Delirium test page to the browser and starts running the given @schemeid[test] case (which can be a SchemeUnit test suite or test case).

The optional @schemeid[run-tests] argument specifies a function to actually run the tests. The default value of @schemeid[run-tests] is a version of @italic{Schemeunit.plt}'s @scheme[test/text-ui] procedure that pauses after each failed test and asks if you wish to continue running tests. This is useful because it allows you to inspect the state of the web page at the point of failure to see what went wrong.}

@defproc[(make-delirium-controller [test schemeunit-test?]
                                   [application-controller (request? -> response?)]
                                   [run-tests procedure? test/text-ui/pause-on-fail])
         (request? -> response?)]{
Wraps @scheme[application-controller], creating a controller procedure that runs the Delirium @scheme[test] suite if the URL begins with @scheme["/test"]. All other URLs are passed through to the application.}