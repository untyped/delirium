#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:2/test)))

@title[#:style '(toc) #:tag "delirium"]{@bold{Delirium}: Unit Testing for Web User Interfaces}

by Dave Gurnell and Noel Welsh 

@tt{{dave, noel} at @link["http://www.untyped.com"]{@tt{untyped}}}

Delirium is a web user interface testing framework built on top of the PLT web server and @link[schemeunit-url]{Schemeunit}.
It lets you write Schemeunit test cases to test the user interface of your (PLT and non-PLT) web applications.

@table-of-contents[]

@; ----------------------------------------------------------------------

@include-section{intro.scrbl}
@include-section{run.scrbl}
@include-section{api.scrbl}
@include-section{misc.scrbl}
