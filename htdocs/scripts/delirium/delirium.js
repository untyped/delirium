// object
var Delirium = {};

Delirium.api = {};

// IFrameElement
Delirium.target = null;

// -> window
Delirium.getWindow = function () {
  return Delirium.target.contentWindow;
};

// -> document
Delirium.getDocument = function () {
  return Delirium.target.contentWindow.document;
};

// Protocol --------------------------------------

// string [ json-marshallable ] -> void
Delirium.sendResult = function (url, data) {
  // Delirium.log("sendResult", url, data);

  $.ajax({
    url        : url,
    type       : "post",
    data       : (typeof(data) == "undefined")
                   ? { type: "result" }
                   : { type: "result", json: Delirium.toJSON(data) },
    dataType   : "text/json",
    success    : function (responseText) {
                   eval(responseText);
                 }});
};

// string [ exn ] -> void
Delirium.sendExn = function (url, exn) {
  // Delirium.log("sendExn", url, exn);

  $.ajax({
    url        : url,
    type       : "post",
    data       : (typeof(exn) == "undefined")
                   ? { type: "exn" }
                   : { type: "exn", json: Delirium.toJSON(exn) },
    dataType   : "text/json",
    success    : function (responseText) {
                   eval(responseText);
                 }});
};

// Start and stop commands -----------------------

// string string -> void  
Delirium.start = function (targetId, kUrl) {
  Delirium.target = $("#" + targetId).get(0);
  Delirium.sendResult(kUrl);
};

// -> void
Delirium.stop = function () {
  // Do nothing
};

// History ---------------------------------------

// object
Delirium.history = {};

// arrayOf(string)
Delirium.history.locations = [];

// integer
//
// One greater than the array index of the current URL in locations.
Delirium.history.position = 0;

// -> (U string null)
//
// Returns the current url in the history.
Delirium.history.current = function () {
  if (Delirium.history.position == 0) {
    return null;
  } else {
    // Delirium.log("History",
    //   Delirium.history.locations[Delirium.history.position - 1],
    //   Delirium.history.position,
    //   Delirium.history.locations);
    return Delirium.history.locations[Delirium.history.position - 1];
  }
};

// -> string
//
// Truncates the history, pushes url at the current position, and returns url. 
Delirium.history.push = function (url) {
  while (Delirium.history.locations.length > Delirium.history.position) {
    Delirium.history.locations.pop();
  }
  
  Delirium.history.locations.push(url);
  Delirium.history.position = Delirium.history.locations.length;

  return Delirium.history.current()
};

// -> string
//
// Returns the previous url in the history and moves the current position to match.
Delirium.history.back = function () {
  if (Delirium.history.position > 1) {
    Delirium.history.position--;
    return Delirium.history.current();
  } else {
    throw [ [ "back" ], "at beginning of history" ];
  };
};

// -> string
//
// Returns the next url in the history and moves the current position to match.
Delirium.history.forward = function () {
  if (Delirium.history.position < Delirium.history.locations.length) {
    Delirium.history.position++;
    return Delirium.history.current();
  } else {
    throw [ [ "forward" ], "at end of history" ];
  };
};

// Logging ---------------------------------------

// any ... -> void
//
// We currently only log in Mozilla with the Firebug addon installed.
Delirium.log = (function () {
  // Firebug:
  if(window.console && window.console.firebug){
    return function () {
      window.console.log.apply(this, arguments);
    };
  // Browsers with a console (Safari):
  } else if (window.console && window.console.log) {
    return function () {
      var str = "";
      for (var i = 0; i < arguments.length; i++) {
        str += i > 0 ? " " + arguments[i] : "" + arguments[i];
      }
      window.console.log(str);
    };
  // Other browsers:
  } else {
    return function () {
      // Do nothing
    };
  };
})();

// XPath -----------------------------------------

// boolean
//
// Believe it or not, the ?: operator is necessary in IE.
Delirium.xPathSupported = window.XPathEvaluator && window.XPathResult
  ? true
  : false;

// node string -> arrayOf(node)
Delirium.evaluateXPath = (function () {
  if (Delirium.xPathSupported) {
    var evaluator = new XPathEvaluator();

    var type = XPathResult.ORDERED_NODE_SNAPSHOT_TYPE;
  
    return function (root, xpath) {
      var snapshot = evaluator.evaluate(xpath, root, null, type, null);
      
      var result = new Array(snapshot.snapshotLength);
  
      for (var i = 0; i < snapshot.snapshotLength; i++) {
        result[i] = snapshot.snapshotItem(i);
      }
      
      return result;
    };
  } else {
    return function (root, xpath) {
      throw "XPath unsupported by this browser.";
    };
  }
})();

// JSON ------------------------------------------

// any -> string
Delirium.toJSON = function (data) {
  try {
    return $.toJSON(data);
  } catch (exn) {
    Delirium.log("toJSON", "Could not serialize", data);
    return "\"Could not convert object to JSON.\"";
  }
};

// Wait hooks ------------------------------------

// hashOf(function -> function)
Delirium.loadHooks = {};

// string -> function
//
// Registers a wait hook that checks if the target window's URL has changed,
// updates Delirium.history as appropriate, and sends a void return value to
// kUrl.
//
// Returns a function to use as an argument to Delirium.unregisterWaitHook if
// the hook is not fired.
Delirium.registerDefaultWaitHook = function (kUrl) {
  // Delirium.log("registerDefaultWaitHook", kUrl);

  return Delirium.registerWaitHook(function() {
    if (Delirium.getWindow().location.href != Delirium.history.current()) {
      Delirium.history.push(Delirium.getWindow().location.href);
      $("currenttitle").innerHTML = Delirium.getDocument().title;
      $("currenturl").innerHTML = Delirium.history.current();
    }
    Delirium.sendResult(kUrl);
  });
};

// function function -> function
//
// Returns a function to use as an argument to Delirium.unregisterWaitHook if
// the hook is not fired.
Delirium.registerWaitHook = function (fn) {
  // Delirium.log("registerWaitHook", fn);
  
  Delirium.loadHooks[fn] = function () {
    Delirium.unregisterWaitHook(fn);
    fn();
  };
  
  $(Delirium.target).bind("load", Delirium.loadHooks[fn]);
  
  if (typeof(Delirium.getWindow().DeliriumClient) == "object") {
    Delirium.getWindow().DeliriumClient.registerWaitHook(
      fn, 
      Delirium.unregisterWaitHook, 
      Delirium.log);
  }
  
  return fn;
};

// function -> void
Delirium.unregisterWaitHook = function (fn) {
  // Delirium.log("Delirium", "unregister", fn);
    
  if (typeof(Delirium.getWindow().DeliriumClient) == "object") {
    Delirium.getWindow().DeliriumClient.unregisterWaitHook(
      fn, 
      Delirium.log);
  }

  $(Delirium.target).unbind("load", Delirium.loadHooks[fn]);
  
  delete Delirium.loadHooks[fn];
};
