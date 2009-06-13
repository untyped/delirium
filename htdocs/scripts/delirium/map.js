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
  var arrays = $.makeArray(arguments).slice(2);
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
