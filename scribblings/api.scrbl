#lang scribble/doc

@(require (file "base.ss")
          (for-label scheme/base
                     (planet schematics/schemeunit/test)))

@title[#:tag "browser"]{Browser API}

@defmodule[(planet untyped/delirium/delirium)]{

The @italic{browser API} is used to tell the web browser to do things. Procedures in the API fall into three categories:

@itemize{
  @item{@italic{Selectors} access nodes on the current page. Selectors are used in conjunction with commands and accessors to specify the bits of the page with which you wish to interact. For example, @scheme[node/id] selects an HTML element by its ID attribute.}
 
  @item{@italic{Accessors} query some aspect of the browser or current page and return it to the server. For example, @scheme[title-ref] retrieves the value of the @var{<title>} element of the current page.}

  @item{@italic{Commands} tell the browser to perform an action such as clicking a link or typing in a URL. For example, @scheme[type] enters text into a text field or text area.}}
    
These types of procedure are defined in three modules, each of which is documented separately below. All three of these modules are required and reprovided by @filepath{delirium.ss}, so you shouldn't normally need to require them directly in your code.

} @;{end defmodule}

@section{Javascript representations}

An aside regarding Javascript representations. Delirium sends commands to the client as blocks of Javascript, which are @italic{eval}'d by a client-side Javascript harness. Delirium uses the Javascript representation from @italic{Mirrors.plt}, which is in turn based on the AST structures from Dave Herman's @italic{Javascript.plt}.

Delirium takes care of most of this Javascript stuff internally. The internal workings are only exposed through contracts on the arguments and return values of the procedures in the API:

@defproc*[([(javascript-expression? [item any]) boolean?]
           [(javascript-statement? [item any]) boolean?])]

The @scheme[js-ref] accessor is the only procedure which requires the programmer to have knowledge of Mirrors' Javascript language.

@section{Selectors}

@defmodule[(planet untyped/delirium/selector)]{
Selectors create Javascript fragments that, when executed in the browser,
select @italic{arrays} of nodes from the page.

On the browser side, all selectors return arrays of nodes: even those that cannot select more than one node. This allows selectors to be nested. Most selectors can take another selector as an optional first argument, allowing you to specify the part(s) of the page that you want to search.

@defproc[(node/document) javascript-expression?]

Selects the @italic{document element} of the current page. Equivalent to
selecting the @scheme[document] object in Javascript.

@defproc[(node/id [id (U string? symbol?)]
                  [relative-to javascript-expression? (node/document)])
         javascript-expression?]{
Selects an element by its @scheme[id] attribute. Equivalent to using @link["http://developer.mozilla.org/en/docs/DOM:document.getElementById"]{@tt{document.getElementById}} in Javascript.}

@defproc[(node/tag [tag-name (U string? symbol?)]
                   [relative-to javascript-expression? (node/document)])
         javascript-expression?]{
Selects elements by their tag name. Equivalent to using @link["http://developer.mozilla.org/en/docs/DOM:element.getElementsByTagName"]{@tt{element.getElementsByTagName}} in Javascript.}

@defproc[(node/class [class-name (U string? symbol?)]
                     [relative-to javascript-expression? (node/document)])
         javascript-expression?]{
Selects elements by their CSS class. Elements with multiple CSS classes are returned if one of them is @scheme[class-name]. Equivalent to using @link["http://www.prototypejs.org/api/utility/getElementsByClassName"]{@tt{document.getElementsByClassName}} in @link["http://www.prototypejs.org"]{Prototype}.}

@defproc[(node/xpath [xpath string?]
                     [relative-to javascript-expression? (node/document)])
         javascript-expression?]{
Selects nodes using an @link["http://www.w3.org/TR/xpath"]{XPath} query string.}

@defproc[(node/jquery [query string?]
                      [relative-to javascript-expression? (node/document)])
         javascript-expression?]{
Select nodes using a @link["http://jquery.com"]{jQuery} string.}

@defproc[(node/link/text [text string?]
                         [relative-to javascript-expression? (node/document)])
         javascript-expression?]{
Selects links that @italic{contain} the specified @scheme[text]. @scheme[text] can appear anywhere in the text of the link: it doesn't have to be a complete match.}

@defproc[(node/cell/xy [x natural?]
                       [y natural?]
                       [table javascript-expression?])
         javascript-expression?]{
Selects the cell(s) (@tt{<td>} or @tt{<th>}) at position @scheme[x],@scheme[y] in the specified @scheme[table]@schemeidfont{(s)}.}

@defproc[(node/first [selected javascript-expression?]) javascript-expression?]{
Selects the first node of the @scheme[selected] nodes.}

@defproc[(node/parent [selected javascript-expression?]) javascript-expression?]{
Selects the parents of the @scheme[selected] nodes.}

@defproc[(node-count [selected javascript-expression?]) integer?]{
Returns the number of @scheme[selected] nodes.}

@defproc[(node-exists? [selected javascript-expression?]) boolean?]{
Returns @scheme[#t] if one or more nodes were @scheme[selected].}

@defproc[(check-found [selected javascript-expression?] [message string? ""]) void?]{
SchemeUnit check that passes if one or more nodes were @scheme[selected].}

@defproc[(check-not-found [selected javascript-expression?] [message string? ""]) void?]{
SchemeUnit check that passes if no nodes were @scheme[selected].}

} @;{end defmodule}

@section{Accessors}

@defmodule[(planet untyped/delirium/accessor)]{

Accessors query parts of the current page in the browser and return 
their values as Scheme literals. Delirium defines the following built-in
accessors:

@defproc[(title-ref) string?]{
Returns the value of the @scheme[<title>] element of the current page.}

@defproc[(inner-html-ref [selected javascript-expression?]) (U string? #f)]{
Returns the concatenated @link["http://developer.mozilla.org/en/docs/DOM:element.innerHTML"]{@tt{innerHTML}} properties of the @scheme[selected] nodes, or @scheme[#f] if no nodes were selected.}

@defproc[(inner-html-ref* [selected javascript-expression?]) (listof string?)]{
Returns a list of the @link["http://developer.mozilla.org/en/docs/DOM:element.innerHTML"]{@tt{innerHTML}} properties of the @scheme[selected] nodes.}

@defproc[(js-ref [expr javascript-expression?]) any]{
Returns the result of evaluating the specified Javascript expression in the browser window. Results are serialized as JSON and deserialized using Dave Herman's @italic{JSON.plt} package. Raises @scheme[exn:fail:delirium:browser] if @scheme[expr] throws a Javascript exception.}

@defproc[(xpath-path-ref [selected javascript-expression?]) (U string? #f)]{
Returns an XPath path that can be used as a reference for the first @scheme[selected] node. Useful for remembering the location of a node for repeated selection. Returns @scheme[#f] if no nodes were selected.

The path is assembled from the tag names and indices of each element between the selected node and the nearest absolutely identifiable ancestor node. Absolutely identifiable nodes include the document root and elements with IDs. For example:

@schemeblock[
  "/div[@id='student-data']/table/tbody/tr[4]/td[3]"]}

@defproc[(xpath-path-ref* [selected javascript-expression?]) (listof string?)]{
Like @scheme[xpath-path-ref], but returns a list of XPath paths, one for each @scheme[selected] node.}

} @;{end defmodule}

@section{Commands}

@defmodule[(planet untyped/delirium/command)]{

Commands simulate the actions of a user in the web browser:

@defproc[(open/wait [url (U string? (-> request? response?))]) void?]{
Opens the specified @scheme[url] in the browser. Waits for the page to finish reloading before returning.}

@defproc[(reload/wait) void?]{
Simulates the user reloading or refreshing the page. Waits for the page to finish reloading before returning.}

@defproc[(back/wait) void?]{
Simulates the user clicking the "Back" button. While some browsers avoid reloading pages in the history if they are cached, @scheme[back/wait] always causes the page to be reloaded from the server. Waits for the page to finish reloading before returning.}

@defproc[(forward/wait) void?]{
Simulates the user clicking the "Back" button. While some browsers avoid reloading pages in the history if they are cached, @scheme[forward/wait] always causes the page to be reloaded from the server. Waits for the page to finish reloading before returning.}

@defproc[(click [selected javascript-expression?]) void?]{
Similates clicking on the first @scheme[selected] node.}

@defproc[(click* [selected javascript-expression?]) void?]{
Like @scheme[click] but simulates clicking on @italic{all} @scheme[selected] nodes.} 

@defproc[(click/wait [selector javascript-expression?]) void?]{
Like @scheme[click] but waits for the page to refresh after the command has been performed. Raises @scheme[exn:fail:delirium:browser] if the selection does not contain exactly one node.}

@defproc[(select [selector javascript-expression?]
                 [value (U string? symbol?)]) void?]{
Simulates selecting @scheme[value] in the first @scheme[selected] @tt{<select>} input (where text is the @italic{value} of the @scheme{<option>}, not the human-friendly text). Raises @scheme[exn:fail:delirium:browser] if no elements are selected, if the first node is not a @tt{<select>}, or if @scheme[value] is not a valid @tt{<option>}.}

@defproc[(select* [selector javascript-expression?]
                  [value (U string? symbol?)]) void?]{
Like @scheme[select] but simulates selecting @scheme[value] in every @scheme[selected] element. Raises @scheme[exn:fail:delirium:browser] if no elements are selected, if one of the nodes node is not a @tt{<select>}, or if @scheme[value] is not a valid @tt{<option>} for one of the nodes.}

@defproc[(select/wait [selector javascript-expression?]
                      [value (U string? symbol?)]) void?]{
Like @scheme[select] but waits for the page to refresh after the command has been performed. Raises @scheme[exn:fail:delirium:browser] if the selection does not contain exactly one node, if the wrong type of node is selected, or if @scheme[value] is not a valid @tt{<option>}.}

@defproc[(enter-text [selected javascript-expression?]
                     [text string?]) void?]{
Simulates typing @scheme[text] into the first @scheme[selected] @tt{<input>} or @tt{<textarea>}. Raises @scheme[exn:fail:delirium:browser] if the wrong type of node is selected.}

@defproc[(enter-text* [selected javascript-expression?]
                      [text string?]) void?]{
Like @scheme[enter-text] but simulates typing @scheme[text] into all the @scheme[selected] nodes instead of just the first. Raises @scheme[exn:fail:delirium:browser] if the wrong type of node is selected.}
  
@defproc[(enter-text/wait [selected javascript-expression?]
                          [text string?]) void?]{
Like @scheme[enter-text] but waits for the page to refresh after the command has been performed. Raises @scheme[exn:fail:delirium:browser] if the selection does not contain exactly one node or if the wrong type of node is selected.}
  
} @;{end defmodule}
