#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit:3)))

@title[#:style '(toc) #:tag "delirium"]{@bold{Delirium}: Unit Testing for Web User Interfaces}

by Dave Gurnell and Noel Welsh 

@tt{{dave, noel} at @link["http://www.untyped.com"]{@tt{untyped}}}

Delirium is a web testing framework that integrates with
@link[schemeunit-url]{SchemeUnit} and the PLT web server.

@table-of-contents[]

@; ----------------------------------------------------------------------

@include-section{intro.scrbl}
@include-section{run.scrbl}
@include-section{api.scrbl}
@include-section{misc.scrbl}
