#!/usr/bin/env node

// https://livebook.manning.com/book/node-js-in-action-second-edition/chapter-12/v-12/50

// read json from stdin
// targetPrice - price -> targetGain:
// update JSON by rmv targetPrice and add targetGain
// spit out new JSON


// test case
// echo '{"symbol":"ABBV","price":"107.69","target": "112.05","dividend":"5.20","dividendPct":"4.83%"}' | ./calculate-target-gains.js | jq .

const concat = require('mississippi').concat;
const readFile = require('fs').readFile;

// https://stackoverflow.com/questions/175739/built-in-way-in-javascript-to-check-if-a-string-is-a-valid-number
function isNumeric(str) {
  if (typeof str != "string") return false // we only process strings!  
  return !isNaN(str) && // use type coercion to parse the _entirety_ of the string 
                        // (`parseFloat` alone does not do this)...
         !isNaN(parseFloat(str)) // ...and ensure strings of whitespace fail
}

function parse(str) {
  const value = JSON.parse(str);
  // var foo = (value["target"] - value["price"]).toFixed(2);
  t = isNumeric(value["target"]) ? value["target"] : 0 ;
  p = isNumeric(value["price"])  ? value["price"]  : 0 ;
  
  var foo = (t-p).toFixed(2);
  if (isNumeric(foo)) {
    value["targetGain"] = (value["target"] - value["price"]).toFixed(2);
  } else {
    value["targetGain"] = 0;
  }
  delete value["target"];
  console.log(JSON.stringify(value));
}

process.stdin.pipe(concat(parse));
