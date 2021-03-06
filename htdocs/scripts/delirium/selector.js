// Notes on selectors:
//
//   - all selector names start with "find";
//   - the equivalent Scheme procedures start with "elem/"
//     to avoid confusion with other Untyped libraries (e.g. Snooze);
//   - all selectors return arrays of nodes;
//   - all selectors with the exception of findDocument take an
//     array of root nodes as a first argument.

// findDocument : -> arrayOf(node)
Delirium.api.findDocument = function () {
  return $(Delirium.getDocument());
};

// findById : arrayOf(node) string -> arrayOf(node)
Delirium.api.findById = function (roots, id) {
  // Delirium.log("findById", roots, id);
  return $(roots).find("#" + id);
};

// findByTag : arrayOf(node) string -> arrayOf(node)
Delirium.api.findByTag = function (roots, tag) {
  // Delirium.log("findByTag", roots, tag);
  return $(roots).find(tag);
};

// arrayOf(node) string -> arrayOf(node)
//
// This only works in Mozilla browsers.
Delirium.api.findByXPath = function (roots, xpath) {
  // Firefox's document.evaluate() method evaluates "//" XPath 
  // expressions relative to the document node, regardless of the 
  // root node is specified. This means that, for example:
  //
  //   document.evaluate("//b", document.evaluate("//a", document, ...), ...)
  //
  // is equivalent to "//b" instead of "//a//b" as one might expect.
  //
  // We add a "." prefix to "//" paths to enforce the result we expect.
  if (xpath.length >= 2 && xpath[0] == "/" && xpath[1] == "/") {
    xpath = "." + xpath;
  }
  
  // Delirium.log("findByXPath", roots, xpath);

  var ans = Delirium.fold(
    function (root, accum) {
      return accum.concat(Delirium.evaluateXPath(root, xpath));
    },
    [],
    roots);
    
  // Delirium.log("findByXPath", ans);
  
  return $(ans);
};

// arrayOf(node) string -> arrayOf(node)
Delirium.api.findByJQuery = function (roots, query) {
  // Delirium.log("findByJQuery", roots, query);
  return $(roots).find(query);
};

// arrayOf(element) integer integer -> arrayOf(element)
Delirium.api.findTableCell = function (roots, x, y) {
  // Delirium.log("findTableCell", roots, x, y);
  
  var handleRoot = function (root) {
    if (root.rows) {
      if (root.rows.length > y) {
        var row = root.rows[y];
        
        if (row.cells) {
          if (row.cells.length > x) {
            return row.cells[x];
          } else {
            throw [ [ "findTableCell", x, y ], "x-index too large", root, "max", row.length ];
          }
        } else {
          throw [ [ "findTableCell", x, y ], "not a row", root, row ];
        }
      } else {
        throw [ [ "findTableCell", x, y ], "y-index too large", root, "max", root.rows.length ];
      }
    } else {
      throw [ [ "findTableCell", x, y ], "not a table", root ];
    }
  };
  
  return $.map(roots, handleRoot);
};

// arrayOf(element) -> arrayOf(element)
Delirium.api.findParent = function (roots) {
    return $.map(roots, function (root) {
        return root.parentNode;    
    });
};
