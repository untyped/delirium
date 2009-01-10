#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit/test)))

@title[#:tag "run"]{Running Delirium}

@declare-exporting[(planet untyped/delirium/delirium)]

Delirium can be started in one of several ways:

@section{Running Delirium from within a servlet}

@defproc[(run-delirium [request request?] [test schemeunit-test?] [run-tests procedure? test/text-ui/pause-on-fail]) response?]{

Sends the Delirium test page to the browser and starts running the given @schemeid[test] case (which can be a SchemeUnit test suite or test case).

The optional @schemeid[run-tests] argument specifies a function to actually run the tests. The default value of @schemeid[run-tests] is a version of @italic{Schemeunit.plt}'s @scheme[test/text-ui] procedure that pauses after each failed test and asks if you wish to continue running tests. This is useful because it allows you to inspect the state of the web page at the point of failure to see what went wrong.}

@section[#:tag "delirium-instaweb"]{Delirium/Instaweb integration}

@defmodule[(planet untyped/delirium/instaweb)]{
Provides functions for running Delirium in an analogous manner to Instaweb:

@defproc[(instaweb/delirium  
           [#:test test schemeunit-test?]
           [#:servlet-path servlet-path (or/c path? string?) "servlet.ss"]
           [#:port port integer? 8765]
           [#:listen-ip listen-ip (or/c string? #f) "127.0.0.1"]
           [#:test-url test-url url? (string->url (format "http://localhost:~a/test" port))]
           [#:run-tests run-tests procedure? test/text-ui/pause-on-fail]
           [#:htdocs-path htdocs-path (or/c path? string?) instaweb-default]
           [#:servlet-namespace servlet-namespace (listof require-spec?) instaweb-default]
           [#:send-url? send-url? boolean #t]
           [#:new-window? new-window? boolean #t]) void?]{

Constructs a servlet that serves requests to @schemeid[test-url] with Delirium and all other requests with files in @schemeid[htdocs-path] or the servlet given in @scheme[servlet-path] as per the standard Instaweb rules.

The arguments @schemeid[port], @schemeid[listen-ip], @schemeid[servlet-path], @schemeid[htdocs-path], and @schemeid[servlet-namespace] have the same meaning as those for @scheme[instaweb].

The argument @schemeid[run-tests] is the same as for @scheme[run-delirium].

The argument @schemeid[test-url] specifies the URL used to invoke Delirium. By default it is @tt{http://localhost:<port>/test}.

The argument @schemeid[send-url?] determines if a web browser is immediatelydirected to @schemeid[test-url], and @schemeid[new-window?] determines if a new window is opened if a web browser is already running.}

@defproc[(instaweb/delirium/dispatacher  
           [#:test test schemeunit-test?]
           [#:app-dispatcher dispatcher (connection? request? -> void?)]
           [#:port port integer? 8765]
           [#:listen-ip listen-ip (or/c string? #f) "127.0.0.1"]
           [#:test-url test-url url? (string->url (format "http://localhost:~a/test" port))]
           [#:run-tests run-tests procedure? test/text-ui/pause-on-fail]
           [#:htdocs-path htdocs-path (or/c path? string?) instaweb-default]
           [#:send-url? send-url? boolean #t]
           [#:new-window? new-window? boolean #t]) void?]{

To @scheme[instaweb/dispatcher] as @scheme[delirium/instaweb] is to @scheme[instaweb]: Allows you to specify the application part of the program as a @scheme[dispatcher] function rather than a servlet. Useful for testing exotic web applications that are not written as servlets.}

} @;end defmodule
