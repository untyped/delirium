// getTitle : -> string
Delirium.api.getTitle = function () {
  // Delirium.log("getTitle");
  return Delirium.getDocument().title;
};

// arrayOf(node) -> (U string false)
Delirium.api.getInnerHTML = function (elems) {
  var ans = Delirium.api.getAllInnerHTML(elems);
  return (ans.length > 0) ? ans[0] : false;
};

// arrayOf(node) -> arrayOf(string)
Delirium.api.getAllInnerHTML = function (elems) {
  var ans = $.map(elems, function (elem) { return elem.innerHTML; });
  return ans;
};

// arrayOf(node) -> (U string false)
Delirium.api.getTextContent = function (elems) {
  var ans = Delirium.api.getAllTextContent(elems);
  return (ans.length > 0) ? ans[0] : false;
};

// arrayOf(node) -> arrayOf(string)
Delirium.api.getAllTextContent = function (elems) {
  var ans = $.map(elems, function (elem) { return elem.textContent; });
  return ans;
};

// arrayOf(node) -> (U string false)
Delirium.api.getJQueryReference = function (elems) {
  // Delirium.log("getJQueryReference", elems);

  var ans = Delirium.api.getAllJQueryReferences(elems);
  return (ans.length > 0) ? ans[0] : false;
};

// arrayOf(node) -> arrayOf(string)
Delirium.api.getAllJQueryReferences = function (elems) {
  // Delirium.log("getAllJQueryReferences", elems);

  var ans = $.map(elems, function (elem) {
    var document = Delirium.getDocument();
    var curr = elem;
    var accum = "";
    
    // Delirium.log("getAllJQueryReferences", "starting", curr);
    
    do {
      var id = curr.id;
      var tag = curr.tagName.toLowerCase();
      var parent = curr.parentNode;
    
      // Delirium.log("getAllJQueryReferences", curr, id, tag, parent);
      
      if (tag == "body") {
        accum = "body > " + accum;
        curr = parent;
      } else if (id) {
        accum = tag + "#" + id + " > " + accum;
        curr = false;
      } else if (parent && parent != document) {
        var index = 0;
      
        for (var i = 0; i < parent.childNodes.length; i++) {
          if (curr == parent.childNodes[i]) {
            accum = tag + ":eq(" + index  + ") > " + accum;
      
            curr = parent;
            break;
          } else if (parent.childNodes[i].tagName == curr.tagName) {
            index++;
          }
        }
      } else {
        accum = tag + " > " + accum;
        curr = false;
      }
      
      // Delirium.log("getAllJQueryReferences", accum);
    } while (curr);
      
    return accum.substring(0, accum.length - 3);
  });

  return ans;
};

// arrayOf(node) -> (U string false)
Delirium.api.getXPathReference = function (elems) {
  // Delirium.log("getXPathReference", elems);

  var ans = Delirium.api.getAllXPathReferences(elems);
  return (ans.length > 0) ? ans[0] : false;
};

// arrayOf(node) -> arrayOf(string)
Delirium.api.getAllXPathReferences = function (elems) {
  // Delirium.log("getAllXPathReferences", elems);

  var ans = $.map(elems, function (elem) {
    var document = Delirium.getDocument();
    var curr = elem;
    var accum = "";
    
    // Delirium.log("getAllXPathReferences", "starting", curr);
    
    do {
      var id = curr.id;
      var tag = curr.tagName.toLowerCase();
      var parent = curr.parentNode;
    
      // Delirium.log("getAllXPathReferences", curr, id, tag, parent);
      
      if (tag == "body") {
        accum = "/body" + accum;
        curr = parent;
      } else if (id) {
        accum = "//" + tag + "[@id='" + id + "']" + accum;
        curr = false;
      } else if (parent && parent != document) {
        var index = 1;
      
        for (var i = 0; i < parent.childNodes.length; i++) {
          if (curr == parent.childNodes[i]) {
            accum = "/" + tag + "[" + index  + "]" + accum;
      
            curr = parent;
            break;
          } else if (parent.childNodes[i].tagName == curr.tagName) {
            index++;
          }
        }
      } else {
        accum = "/" + tag + accum;
        curr = false;
      }
      
      // Delirium.log("getAllXPathReferences", accum);
    } while (curr);
      
    return accum;
  });

  return ans;
};
