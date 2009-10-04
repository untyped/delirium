#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:2/test)))

@title{Introduction}

@section{What is Delirium?}

Delirium is a tool for testing PLT web application user interfaces. It allows programmers to write user interface tests for PLT web applications using the popular unit testing framework Schemeunit. 
Web user interface testing is difficult because you need to control the server and the browser at the same time. Delirium gives you the ability to write a single Schemeunit script that does both of these things. There is very little configuration involved and you won't need to write a line of Javascript (unless you want to, that is).

Here is an example test case that tests a login page for a simple web application:

@schemeblock[
  (test-case "Users can log in via the login page"
    (code:comment "The test database starts off empty: we need a new user:")
    (let ([user (make-user #:username "dave" #:password "password")]
          [now  (current-milliseconds)])
      (code:comment "Save the user to the database:")
      (save! user)
      (code:comment "Open the login page in the browser:")
      (open/wait "/login")
      (code:comment "Fill in the login form in the browser:")
      (enter-text (node/id 'username-field) "dave")
      (enter-text (node/id 'password-field) "password")
      (code:comment "Click 'Submit' and wait for the page to refresh:")
      (click/wait 'submit-button)
      (code:comment "Check the page title is 'Welcome, dave!'")
      (check-equal? (title-ref) "Welcome, dave!")
      (code:comment "Check the login was recorded:")
      (check > (user-last-login user) now)))]

The code in this example comes from three sources:

@itemize{
  @item{Delirium tests are defined on the server, so they have access to all the library code used in the web application being tested. The @scheme[make-user], @scheme[save!] and @scheme[user-last-login] in the example are all imported from the application itself.}
  @item{Delirium is built on top of Schemeunit, which provides a rich testing framework. The @scheme[test-case], @scheme[check] and @scheme[check-equal?] forms in the example are standard procedures and macros from SchemeUnit.}
  @item{Delirium provides an API for remote-controlling the web browser. The @scheme[open/wait], @scheme[click/wait], @scheme[node/id], @scheme[type] and @scheme[title-ref] procedures pause the test script while they remotely execute Javascript code on the browser before parsing and returning any relevant results.}}

Note that, like Schemeunit tests, Delirium tests are all fully fledged Scheme code: you can use all the abstractions that you would expect including comprehensions, higher order procedures and macros.

@section{How does it work?}

Delirium runs on top of the PLT Web Server. This allows it to maintain a REPL-style communication with the web browser using continuations:

@itemize{
  @item{test code is run until a browser API call is encountered.}
  @item{Scheme code on the server sends the API command to the browser as a block of Javascript.}
  @item{Javascript code in the browser executes the command.}
  @item{the result of the command is sent back to the server as a block of JSON.}
  @item{the JSON is converted into a Scheme value, which is returned by the API call.}
  @item{more tests are run until the next browser API call is encountered...}}

Delirium is typically used to test PLT web applications. These applications are set up so they can be run in two different modes:

@itemize{
  @item{@italic{Production mode} bypasses all of the Delirium setup and simply runs the application.}
  @item{@italic{Test mode} runs the application with whatever external resources (databases, configuration files, user credentials) are needed for testing, and sets up a special @italic{test servlet} that runs Delirium.}}
  
Here is an example web application written using @scheme[web-server/servlet-env] and Delirium:

@schemeblock[
  (code:comment " -> response")
  (define (start request)
    (code:comment "Application code goes here..."))
  
  (define tests
    (test-suite "Delirium tests"
      (code:comment "Test code goes here...")))

  (code:comment "-> thunk")
  (define (run-production)
    (serve/servlet start))

  (code:comment "-> thunk")
  (define (run-tests)
    (serve/delirium start tests))]

In this example, @scheme[run-production] runs the regular application on port 8000 using the PLT web server's built-in @scheme[serve/servlet] produre. @scheme[run-tests] runs the same application using the @scheme[serve/delirium] wrapper procedure. @scheme[serve/delirium] configures the web server to run the application as normal except for the following caveats:

@itemize{
  @item{the URL @tt{/test} is mapped to a Delirium @italic{test page};}
  @item{the URLs @tt{/scripts/delirium} and @scheme{/styles/delirium} are mapped to static Javascript and CSS used by Delirium.}}

Opening the URL @tt{/test} loads a Delirium test page into the browser. Application web pages are loaded into an iframe on the test page, allowing Delirium to remote-control the application using Javascript. Once the iframe has been created, Delirium invokes the test suite and continues as described above.
