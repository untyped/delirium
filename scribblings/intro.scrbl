#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:2/test)))

@title{Introduction}

@section{What is Delirium?}

Delirium is a tool for testing PLT web application user interfaces. It allows programmers to write tests with unprecedented clarity and speed. Delirium is built on top of SchemeUnit and the PLT Web Server.

Web interface testing is difficult because you need to control the server and the browser at the same time. Delirium gives you the ability to write a single SchemeUnit script that does both in a single test script. There is very little configuration involved and you won't need to write a lick of Javascript.

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

This is a standard SchemeUnit test-case being run inside Delirium. The code used comes from three sources:

@itemize{
  @item{Delirium tests are defined on the server, so they have access to all the library code used in the web application being tested. The @scheme[make-user], @scheme[save!] and @scheme[user-last-login] in the example are all imported from the application itself.}
  @item{Delirium is built on top of SchemeUnit, which provides a rich testing framework. The @scheme[test-case], @scheme[check] and @scheme[check-equal?] forms in the example are standard procedures and macros from SchemeUnit.}
  @item{Delirium provides an API for remote-controlling the web browser. The @scheme[open/wait], @scheme[click/wait], @scheme[node/id], @scheme[type] and @scheme[title-ref] procedures in the example work by remotely executing Javascript code on the browser and returning the results.}}

Note that, like SchemeUnit tests, Delirium tests are all fully fledged Scheme code: you can use all the abstractions that you would expect, including loops, conditionals, procedures and macros.

@section{How does it work?}

Delirium only works on web applications created for the PLT Web Server. Applications are set up so they can be run in two different modes:

@itemize{
  @item{@italic{Production mode} bypasses all of the Delirium setup and simply runs the application.}
  @item{@italic{Test mode} runs the application with whatever external resources (databases, configuration files, user credentials) are needed for testing, and sets up a special @italic{test servlet} that runs Delirium.}}
  
Here is an example start procedure from a test servlet:

@schemeblock[
  (code:comment "start : request -> response")
  (define (start request)
    (code:comment "run-delirium : request schemeunit-test-suite -> response")
    (run-delirium request my-ui-test-suite))]

The test servlet is typically mapped to a URL like @tt{http://localhost:8080/test}. When the servlet is invoked, @scheme[run-delirium] will send a test-page to the browser. The test-page contains an @tt{<iframe>} in which the web application is loaded. All browser API calls like @scheme[open/wait] and @scheme[enter-text] are directed at the frame. All the test suite has to do is call @scheme[open/wait] to load part of the web application and start testing it.

Delirium uses continuations to maintain a REPL-style testing loop:

@itemize{
  @item{Tests are run until a browser API call is encountered.}
  @item{Scheme code on the server sends a command to the browser as a block of Javascript.}
  @item{Javascript code in the browser executes the command.}
  @item{The result of the command is sent back to the server as a block of JSON.}
  @item{The JSON is converted into a Scheme value, which is returned by the API call.}
  @item{More tests are run until the next browser API call is encountered...}}
