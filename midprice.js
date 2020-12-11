#!/usr/bin/env node
// parse the "range":"30.11 - 71.37", calculate midrange, inject midrange into json and drop range from json

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
  const json = JSON.parse(str);
  range = json["range"];
  // that regex is digits period digits spaces '-' everything else
  if (match = range.match(/^(\d+\.\d+\s+)-(.*)$/)) {
	first = parseFloat(+match[1]);			// float
	second = parseFloat(match[2]);			// float
        mid = ((second + first)/2.0).toFixed(2);	// back to string
  	// console.log(JSON.stringify(first));
  	// console.log(JSON.stringify(second));
  	// console.log(JSON.stringify(mid));
	delete json["range"];
	json["midprice"] = mid;
  } 
  console.log(JSON.stringify(json));
}

process.stdin.pipe(concat(parse));
