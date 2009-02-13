#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:3)))

@title[#:tag "run"]{Running Delirium}

@declare-exporting[(planet untyped/delirium/delirium)]

Delirium can be started from a top-level application or from within a servlet.

@section{Running Delirium as a top-level application}

@defproc[(serve/delirium [start                      (request? -> response/full?)]
                         [test                       schemeunit-test?]
                         [#:run-tests?               run-tests?               boolean?                       #t]
                         [#:run-tests                run-tests                (schemeunit-test? -> any)      run-tests/pause]
                         [#:manager                  manager                  (U manager? #f)                #f]
                         [#:port                     port                     natural?                       8765]
                         [#:listen-ip                listen-up                (U string? #f)                 "127.0.0.1"]
                         [#:servlet-path             servlet-path             (U string? #f)                 "/"]
                         [#:servlet-regexp           servlet-regexp           (U string? #f)                 #rx""]
                         [#:extra-files-paths        extra-files-paths        (listof path?)                 null]
                         [#:mime-types-path          mime-types-path          (U path? #f)                   #f]
                         [#:launch-browser?          launch-browser?          boolean?                       #t]
                         [#:file-not-found-responder file-not-found-responder (U (request? -> response/full?) #f) #f])
         void?]{

Wrapper for @scheme[serve/servlet] that sets up sensible defaults for Delirium. All relevant arguments are passed straight through except the following:
        
@itemize{
  @item{if @scheme[run-tests?] is @scheme[#t], @scheme[start] is wrapped using @scheme[(make-delirium-controller start test run-tests)];}
  @item{if @scheme[run-tests?] is @scheme[#t], @scheme["/test"] is passed on as the value of @scheme[servlet-path];}
  @item{if @scheme[manager], @scheme[mime-types-path] or @scheme[file-not-found-responder] is @scheme[#f]it reverts to its default value in @scheme[serve/servlet].}}}

@section{Running Delirium from within a servlet}

@defproc[(make-delirium-controller [application-controller (request? -> response/full?)]
                                   [test schemeunit-test?]
                                   [run-tests procedure? run-tests/pause])
         (request? -> response/full?)]{
Wraps @scheme[application-controller], creating a controller procedure that runs the Delirium @scheme[test] suite if the URL begins with @scheme["/test"]. All other URLs are passed through to the application.}
                                 
@defproc[(run-delirium [request request?]
                       [test schemeunit-test?]
                       [run-tests procedure? run-tests/pause])
         response/full?]{
Sends the Delirium test page to the browser and starts running the given @schemeid[test] case (which can be a SchemeUnit test suite or test case).

The optional @schemeid[run-tests] argument specifies a function to actually run the tests. The default value of @schemeid[run-tests] is a version of @italic{Schemeunit.plt}'s @scheme[run-tests] procedure that pauses after each failed test and asks if you wish to continue running tests. This is useful because it allows you to inspect the state of the web page at the point of failure to see what went wrong.}
