// Delirium.api.getXPathReference(Delirium.target.contentDocument.documentElement);

// getTitle : -> string
Delirium.api.getTitle = function () {
  // Delirium.log("getTitle");
  return Delirium.target.contentDocument.title;
};

// arrayOf(node) -> (U string false)
Delirium.api.getInnerHTML = function (elems) {
  var ans = Delirium.api.getAllInnerHTML(elems);
  return (ans.length > 0) ? ans[0] : false;
};

// arrayOf(node) -> arrayOf(string)
Delirium.api.getAllInnerHTML = function (elems) {
  var ans = Delirium.map(function (elem) { return elem.innerHTML; }, elems);
  return ans;
};

// arrayOf(node) -> (U string false)
Delirium.api.getXPathReference = function (elems) {
  var ans = Delirium.api.getAllXPathReferences(elems);
  return (ans.length > 0) ? ans[0] : false;
};

// arrayOf(node) -> (U string false)
Delirium.api.getAllXPathReferences = function (elems) {
  var ans = Delirium.map(function (elem) {
    var document = Delirium.target.contentDocument;
    var curr = elem;
    var accum = "";
    
    do {
      Delirium.log(curr, curr.tagName);
      
      var id = curr.id;
      var tag = curr.tagName.toLowerCase();
      var parent = curr.parentNode;
    
      if (id) {
      
        accum = "//" + tag + "[@id='" + id + "']" + accum;
        curr = false;
      
      } else if (parent && parent != document) {
      
        for (var i = 0; i < parent.childNodes.length; i++) {
          if (curr = parent.childNodes[i]) {
            accum = "/" + tag + "[" + (i + 1)  + "]" + accum;
      
            curr = parent;
            break;
          }
        }
      
      } else {
      
        accum = "/" + tag + accum;
        curr = false;
      
      }
    } while (curr);
      
    return accum;
  }, elems);

  return ans;
};
