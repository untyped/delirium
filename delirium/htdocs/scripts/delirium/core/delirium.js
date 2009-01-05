// object
var Delirium = {};
Delirium.api = {};

// IFrameElement
Delirium.target = null;

// Protocol --------------------------------------

// string [ json-marshallable ] -> void
Delirium.sendResult = function (url, data) {
  Delirium.log("Delirium.sendResult", url, data);

  var params = typeof(data) == "undefined"
    ? { type: "result" }
    : { type: "result", json: Delirium.toJSON(data) };

  new Ajax.Request(url, {
    method: "post",
    contentType: "text/json",
    parameters: params });
};

// string [ exn ] -> void
Delirium.sendExn = function (url, exn) {
  Delirium.log("Delirium.sendExn", url, exn);

  var params = typeof(exn) == "undefined"
    ? { type: "exn" }
    : { type: "exn", json: Delirium.toJSON(exn) };

  new Ajax.Request(url, {
    method: "post",
    contentType: "text/json",
    parameters: params });
};

// Start and stop commands -----------------------

// string string -> void  
Delirium.start = function (targetId, kUrl) {
  Delirium.target = $(targetId);
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
Delirium.history.locations = $A();

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
    ///   Delirium.history.locations);
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
  if (window.console && window.console.log && !(/Konqueror|Safari|KHTML/.test(navigator.userAgent))) {
    return function () {
      window.console.log.apply(this, arguments);
    };
  } else {
    return function () {
      // Do nothing
    };
  };
})();

// XPath -----------------------------------------

// node string -> arrayOf(node)
Delirium.evaluateXpath = (function () {
  var evaluator = new XPathEvaluator();

  var type = XPathResult.ORDERED_NODE_SNAPSHOT_TYPE;

  return function (root, xpath) {
    var snapshot = evaluator.evaluate(xpath, root, null, type, null);
     
    var result = new Array(snapshot.snapshotLength);
    for (var i = 0; i < snapshot.snapshotLength; i++) {
      result[i] = snapshot.snapshotItem(i);
    }
    
    // Delirium.log("Eval xpath", xpath, result);
    
    return result;
  };
})();

// JSON ------------------------------------------

// any -> string
Delirium.toJSON = function (data) {
  return Object.isArray(data)
    ? $A(data).toJSON()
    : Object.toJSON(data);
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
  return Delirium.registerWaitHook(function() {
    if (Delirium.target.contentWindow.location.href != Delirium.history.current()) {
      Delirium.history.push(Delirium.target.contentWindow.location.href);
      $("currenttitle").innerHTML = Delirium.target.contentDocument.title;
      $("currenturl").innerHTML = Delirium.history.current();
    }
    Delirium.sendResult(kUrl);
  })
};

// function function -> function
//
// Returns a function to use as an argument to Delirium.unregisterWaitHook if
// the hook is not fired.
Delirium.registerWaitHook = function (fn) {
  // Delirium.log("Delirium", "register", fn);
  
  Delirium.loadHooks[fn] = function () {
    Delirium.unregisterWaitHook(fn);
    fn();
  };
  
  Event.observe(Delirium.target, "load", Delirium.loadHooks[fn]);
  
  if (typeof(Delirium.target.contentWindow.DeliriumClient) == "object") {
    Delirium.target.contentWindow.DeliriumClient.registerWaitHook(
      fn, 
      Delirium.unregisterWaitHook, 
      Delirium.log);
  }
  
  return fn;
};

// function -> void
Delirium.unregisterWaitHook = function (fn) {
  // Delirium.log("Delirium", "unregister", fn);
    
  if (typeof(Delirium.target.contentWindow.DeliriumClient) == "object") {
    Delirium.target.contentWindow.DeliriumClient.unregisterWaitHook(
      fn, 
      Delirium.log);
  }

  Event.stopObserving(Delirium.target, "load", Delirium.loadHooks[fn]);
  
  delete Delirium.loadHooks[fn];
};
