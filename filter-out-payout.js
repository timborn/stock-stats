#!/usr/bin/env node

// toss records where payout >= MAX
// also has nice side effect of making payout a number instead of a string
// NB payouts of zero are inherently suspect

// https://livebook.manning.com/book/node-js-in-action-second-edition/chapter-12/v-12/50

// read json from stdin
// convert payout to a number (dropping the % sign)
// spit out new JSON

const concat = require('mississippi').concat;

// https://stackoverflow.com/questions/175739/built-in-way-in-javascript-to-check-if-a-string-is-a-valid-number
function isNumeric(str) {
  // for our purposes, accept string or number
  // sometimes the 'number' is just a dash
  if (str == '-') { return false; }
  return parseFloat(str);
}

function parse(str) {
  const value = JSON.parse(str);

  // console.log("parseFloat(value['payout']) = "+parseFloat( value["payout"] ));
  // console.log("isNumeric = "+isNumeric(value["payout"]) );

  if ( isNumeric(value["payout"]) ) {
    value["payout"] = parseFloat( value["payout"] );
  } else {
    // console.log("ZAP - setting payout to ZERO");
    value["payout"] = 0;
  }
  
  // if I knew how to use a CONSTANT in javascript, here would be MAX
  if (value["payout"] < 100) { console.log(JSON.stringify(value)); }
}

process.stdin.pipe(concat(parse));
