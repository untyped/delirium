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
  return [ Delirium.target.contentDocument ];
};

// findById : arrayOf(node) string -> arrayOf(node)
Delirium.api.findById = function (roots, id) {
  // Delirium.log("findById", roots, id);

  if (roots.length == 0) {
    return [];
  } else if (roots.length == 1 && roots[0] == Delirium.target.contentDocument) {
    var ans = roots[0].getElementById(id);
    return ans ? [ ans ] : [];
  } else {
    var xpath = "descendant::*[@id = '" + id + "']";
    return Delirium.api.findByXpath(roots, xpath);
  }
};

// findByTag : arrayOf(node) string -> arrayOf(node)
Delirium.api.findByTag = function (roots, tag) {
  // Delirium.log("findByTag", roots, tag);
  
  return Delirium.fold(
    function (root, accum) {
      var found = $A(root.getElementsByTagName(tag));
      if (found.length > 0) {
        return accum.concat(found);
      } else {
        return accum;
      }
    },
    [],
    roots);
};

// findByXpath : arrayOf(node) string -> arrayOf(node)
//
// This currently only works in Mozilla browsers.
// IE support should a simple addition, and there is a portable
// XPath implementation out there for Safari.
Delirium.api.findByXpath = function (roots, xpath) {
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
  
  Delirium.log("findByXpath", roots, xpath);

  var ans = Delirium.fold(
    function (root, accum) {
      return accum.concat(Delirium.evaluateXpath(root, xpath));
    },
    [],
    roots);
    
  Delirium.log("findByXpath", ans);
  
  return ans;
};

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
  
  return Delirium.map(handleRoot, roots);
};
