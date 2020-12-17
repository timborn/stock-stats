#!/usr/bin/env node
// dividend cover ratio is EPS(ttm) / DPS

// https://livebook.manning.com/book/node-js-in-action-second-edition/chapter-12/v-12/50

const concat = require('mississippi').concat;
const readFile = require('fs').readFile;

// https://stackoverflow.com/questions/175739/built-in-way-in-javascript-to-check-if-a-string-is-a-valid-number
function isNumeric(str) {
  // happy to accepts strings or numbers, as long as we can parse it
  // if (typeof str != "string") return false // we only process strings!  
  return !isNaN(str) && // use type coercion to parse the _entirety_ of the string 
                        // (`parseFloat` alone does not do this)...
         !isNaN(parseFloat(str)) // ...and ensure strings of whitespace fail
}

function parse(str) {
  const value = JSON.parse(str);
  // may as well make these numbers - I hope this doesn't break something else
  eps = isNumeric(value["EPSttm"]) ? parseFloat( value["EPSttm"] ): 0 ;
  dps = isNumeric(value["dividend"]) ? parseFloat( value["dividend"] ) : 0 ;
  
  if (dps != 0) {
    value["divCover"] = (value["EPSttm"] / value["dividend"]).toFixed(2);
  } else {
    value["divCover"] = "-";
  }
  console.log(JSON.stringify(value));
}

process.stdin.pipe(concat(parse));
