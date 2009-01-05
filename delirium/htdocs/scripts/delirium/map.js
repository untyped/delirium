// fold -----------------------------------------

// fold : (a b ... k -> k) 
//        k
//        (array-of a)
//        (array-of b) 
//        ... 
//     -> k
//
// Good old Lisp fold, implemented (rather inefficiently) 
// in JavaScript.
Delirium.fold = function () {
  var fn = arguments[0];
  var accum = arguments[1];
  var arrays = $A(arguments).slice(2);
  var iterations = arrays[0].length;
  
  for (var i = 1; i < arrays.length; i++) {
    if (arrays[i].length != iterations) {
      throw "Delirium.fold: array arguments are different lengths";
    }
  }
  
  if (iterations == 0) {
    return accum;
  }
  
  var args = new Array(arrays.length + 1);
  
  for (var i = 0; i < iterations; i++) {
    for (var j = 0; j < arrays.length; j++) {
       args[j] = arrays[j][i];
    }
    args[args.length - 1] = accum;
    accum = fn.apply(this, args);
  }
  
  return accum;
};

// map and forEach ------------------------------

// map : (a b ... -> c) 
//       (array-of a)
//       (array-of b) 
//       ... 
//    -> (array-of c)
//
// Good old Lisp map, implemented (rather inefficiently) 
// in JavaScript.
Delirium.map = function () {
  var fn = arguments[0];
  var iterations = arguments[1].length;
  
  for (var i = 2; i < arguments.length; i++) {
    if (arguments[i].length != iterations) {
      throw "Delirium.map: array arguments are different lengths";
    }
  }
  
  if (iterations == 0) {
    return [];
  }
  
  var ans = new Array(iterations);
  var args = new Array(arguments.length - 1);
  
  for (var i = 0; i < iterations; i++) {
    for (var j = 1; j < arguments.length; j++) {
       args[j-1] = arguments[j][i];
    }
    
    ans[i] = fn.apply(this, args);
  }
  
  return ans;
};

// forEach : (a b ... -> c) 
//           (array-of a)
//           (array-of b) 
//           ... 
//        -> undefined
//
// Good old Lisp foreach, implemented (rather inefficiently) 
// in JavaScript.
Delirium.forEach = function () {
  var fn = arguments[0];
  var iterations = arguments[1].length;
  
  for (var i = 2; i < arguments.length; i++) {
    if (arguments[i].length != iterations) {
      throw "Delirium.foreach: array arguments are different lengths";
    }
  }
  
  if (iterations == 0) {
    return;
  }
  
  var args = new Array(arguments.length - 1);
  
  for (var i = 0; i < iterations; i++) {
    for (var j = 1; j < arguments.length; j++) {
       args[j-1] = arguments[j][i];
    }
    
    fn.apply(this, args);
  }
};
  
// indexedMap : (integer a b ... -> c) 
//              (array-of a)
//              (array-of b) 
//              ... 
//           -> (array-of c)
//
// Like map, but the iterator function takes the current
// iteration index as its first argument.
Delirium.indexedMap = function () {
  var fn = arguments[0];
  var iterations = arguments[1].length;
  
  for (var i = 2; i < arguments.length; i++) {
    if (arguments[i].length != iterations) {
      throw "Delirium.indexedMap: array arguments are different lengths";
    }
  }
  
  if (iterations == 0) {
    return [];
  }
  

  var ans = new Array(iterations);
  var args = new Array(arguments.length);
  
  for (var i = 0; i < iterations; i++) {
    args[0] = i;
    
    for (var j = 1; j < arguments.length; j++) {
       args[j] = arguments[j][i];
    }
    
    ans[i] = fn.apply(this, args);
  }
  
  return ans;
};

// indexedForEach : (integer a b ... -> c) 
//                  (array-of a)
//                  (array-of b) 
//                  ... 
//               -> undefined
//
// Like forEach, but the iterator function takes the current 
// iteration index as its first argument.
Delirium.indexedForEach = function () {
  var fn = arguments[0];
  var iterations = arguments[1].length;
  
  for (var i = 2; i < arguments.length; i++) {
    if (arguments[i].length != iterations) {
      throw "Delirium.foreach: array arguments are different lengths";
    }
  }
  
  if (iterations == 0) {
    return;
  }
  
  var args = new Array(arguments.length);
  
  for (var i = 0; i < iterations; i++) {
    args[0] = i;
    for (var j = 1; j < arguments.length; j++) {
       args[j] = arguments[j][i];
    }
    
    fn.apply(this, args);
  }
};

