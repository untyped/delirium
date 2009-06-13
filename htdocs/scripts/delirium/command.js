// Open, reload, back and forward ----------------

// string string -> void
Delirium.api.openAndWait = function (kUrl, openUrl) {
  // Delirium.log("openAndWait", kUrl, openUrl);
  
  Delirium.registerDefaultWaitHook(kUrl);
  Delirium.getWindow().location.href = openUrl;
};

// string string -> void
Delirium.api.reloadAndWait = function (kUrl) {
  // Delirium.log("reloadAndWait", kUrl);
  
  Delirium.registerDefaultWaitHook(kUrl);
  Delirium.getWindow().location.reload();
};

// string -> void
Delirium.api.backAndWait = function (kUrl) {
  // Delirium.log("backAndWait", kUrl);

  try {  
    var url = Delirium.history.back();
    
    Delirium.registerWaitHook(function() {
      $("#currenttitle").html(Delirium.getDocument().title);
      $("#currenturl").html(Delirium.history.current());
      Delirium.sendResult(kUrl);
    });
  
    Delirium.getWindow().location.href = url;
  } catch (exn) {
    Delirium.sendExn(kUrl, exn);
  }
};

// string -> void
Delirium.api.forwardAndWait = function (kUrl) {
  // Delirium.log("forwardAndWait", kUrl);

  try {  
    var url = Delirium.history.forward();

    Delirium.registerWaitHook(function() {
      $("currenttitle").innerHTML = Delirium.getDocument().title;
      $("currenturl").innerHTML = Delirium.history.current();
      Delirium.sendResult(kUrl);
    });
  
    Delirium.getWindow().location.href = url;
  } catch (exn) {
    Delirium.sendExn(kUrl, exn);
  }
};

// Interaction with HTML elements ----------------

// string arrayOf(node) -> void
Delirium.api.click = function(nodes) {
  // Delirium.log("clickAll", nodes);

  return Delirium.api.clickAll([ nodes[0] ]);
};

// arrayOf(node) -> boolean
//
// Clicks the element with the supplied ID.
Delirium.api.clickAll = function (nodes) {
  // Delirium.log("click", nodes);

  if (nodes.length && nodes.length > 0) {
    $.each(nodes, function (index, node) { 
      // Delirium.log("clickAll", "curr", node);
    
      var clickable = false;
      
      if (node && node.click) {
        // Delirium.log("clickAll", "click");
        
        clickable = true;
        node.click();
        if (node.href) {
          Delirium.getWindow().location.href = node.href;
        }
      } else if (node && node.fireEvent) {
        // Delirium.log("clickAll", "fireEvent");

        clickable = true;
        if (node.fireEvent("onclick") && node.href) {
            Delirium.getWindow().location.href = node.href;
        }
      } else if (node && node.dispatchEvent) {
        // Delirium.log("clickAll", "dispatchEvent");

        clickable = true;
        if (node.dispatchEvent(Delirium.event.createClickEvent()) && node.href) {
          Delirium.getWindow().location.href = node.href;          
        }
      }
      
      if (!clickable) {
        throw [ [ "clickAll", nodes ], "Unclickable node", node ];
      }
    });
  } else {
    throw [ [ "clickAll", nodes ], "Bad or empty array of selected nodes" ];
  }
};

// string arrayOf(node) -> void
Delirium.api.clickAndWait = function(kUrl, nodes) {
  // Delirium.log("clickAndWait", kUrl, nodes);

  try {
    if (nodes.length == 1) {
      Delirium.registerDefaultWaitHook(kUrl);
      Delirium.api.clickAll(nodes);
    } else {
      throw [ [ "clickAndWait", kUrl, nodes ],
              "Exactly one node must be selected." ];
    }
  } catch (exn) {
    Delirium.sendExn(kUrl, exn);
  }
};

// arrayOf(node) string -> void
Delirium.api.select = function(nodes, value) {
  // Delirium.log("select", nodes, value);

  return Delirium.api.changeAll([ nodes[0] ], value);
};

// arrayOf(node) string -> void
//
// Clicks the button with the supplied ID.
Delirium.api.selectAll = function (nodes, value) {
  // Delirium.log("selectAll", nodes, value);

  return Delirium.api.changeAll(nodes, value);
};

// string arrayOf(node) string -> void
Delirium.api.selectAndWait = function(kUrl, nodes, value) {
  // Delirium.log("selectAndWait", nodes, value);

  Delirium.api.changeAndWait(kUrl, nodes, value);
};

// string arrayOf(node) -> void
Delirium.api.enterText = function(nodes, value) {
  // Delirium.log("enterText", nodes, value);

  return Delirium.api.changeAll([ nodes[0] ], value);
};

// arrayOf(node) string -> void
//
// Types the supplied text into the text field or text
// area with the supplied ID.
Delirium.api.enterTextAll = function (nodes, value) {
  // Delirium.log("enterTextAll", nodes, value);

  return Delirium.api.changeAll(nodes, value);
};

// string arrayOf(node) string -> void
Delirium.api.enterTextAndWait = function(kUrl, nodes, value) {
  // Delirium.log("enterTextAndWait", nodes, value);

  Delirium.api.changeAndWait(kUrl, nodes, value);
};

// arrayOf(node) string -> void
//
// Changes the value of the specified element and fires a change event.
Delirium.api.changeAll = function (nodes, value) {
  // Delirium.log("changeAll", nodes, value);

  if (nodes.length && nodes.length >> 0) {
    // Used to inform changeAndWait whether or not 
    // it can rely on the wait hook to respond to the server.
    var fired = false;
  
    $.each(nodes, function (index, node) {
      var exists = false;
      
      if (node && node.fireEvent) {
        exists = true;
        if (node.value != value) {
          fired = true;
          node.value = value;
          node.fireEvent("onchange");
        }
      } else if (node && node.dispatchEvent) {
        exists = true;
        if (node.value != value) {
          fired = true;
          node.value = value;
          node.dispatchEvent(Delirium.event.createChangeEvent());
        }
      }
      
      if (!exists) {
        throw [ [ "changeAll", nodes, value ], "Value not found in ", node ];
      }
    });
    
    return fired;
  } else {
    throw [ [ "changeAll", nodes, value ], "Bad or empty array of selected nodes" ];
  }
};

// string arrayOf(node) string -> void
Delirium.api.changeAndWait = function(kUrl, nodes, value) {
  Delirium.log("changeAndWait", kUrl, nodes);

  try {
    if (nodes.length == 1) {
      var hook = Delirium.registerDefaultWaitHook(kUrl);
      
      if (!Delirium.api.changeAll(nodes, value)) {
        // If we get here, the node was unchanged and the wait hook will remain unfired:
        Delirium.unregisterWaitHook(hook);
        Delirium.sendResult(kUrl);
      }
    } else {
      throw [ [ "changeAndWait", kUrl, nodes, value ], "Exactly one node must be selected." ];
    }
  } catch (exn) {
    Delirium.sendExn(kUrl, exn);
  }
};

// Event code ------------------------------------

// object
Delirium.event = {};

// string -> event
//
// Used in FireFox and browsers that support node.dispatchEvent.
Delirium.event.createClickEvent = function () {
  var evt = Delirium.getDocument().createEvent("MouseEvents");
  
  // TODO : Fill in some of this stuff more intelligently:
  evt.initMouseEvent("click", true, true, Delirium.getWindow(),
    0, 0, 0, 0, 0, false, false, false, false, 0, null);
  
  return evt;
};

// string -> event
//
// Used in FireFox and browsers that support node.dispatchEvent.
Delirium.event.createChangeEvent = function () {
  var evt = Delirium.getDocument().createEvent("HTMLEvents");
  evt.initEvent("change", true, true);
  return evt;
};
