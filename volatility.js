#!/usr/bin/env node
// parse the "Volatility":"2.17% 1.58%", inject VolatilityWk and 
// VolatilityMo into json and drop Volatility from json
// 221229 - they changed format and there are now two entries for Volatility:
//    "Volatility (Week)": "2.24%"
//    "Volatility (Month)": "2.29%"

const concat = require('mississippi').concat;
const readFile = require('fs').readFile;

// https://stackoverflow.com/questions/175739/built-in-way-in-javascript-to-check-if-a-string-is-a-valid-number
function isNumeric(str) {
  if (typeof str != "string") return false // we only process strings!  
  return !isNaN(str) && // use type coercion to parse the _entirety_ of the string 
                        // (`parseFloat` alone does not do this)...
         !isNaN(parseFloat(str)) // ...and ensure strings of whitespace fail
}

// expecting "Volatility":"2.17% 1.58%" 
// inject VolatilityWk and VolatilityMo into json and drop Volatility from json
function parse(str) {
  const json = JSON.parse(str);
  vol = json["Volatility"];
  // that regex is digits period digits spaces '-' everything else
  // if (match = vol.match(/^(\d+\.\d+\s+) (.*)$/)) {
  if (match = vol.match(/^(\d+\.\d+%)\s(.*)/)) {
	first = parseFloat(match[1]);			// float
	second = parseFloat(match[2]);			// float
        // mid = parseFloat(((second + first)/2.0).toFixed(2));	// back to string to get 2 decimal places, then back to a number
  	// console.log(JSON.stringify(first));
  	// console.log(JSON.stringify(second));
  	// console.log(JSON.stringify(mid));
	delete json["Volatility"];
	// if you really want the % on the end ...
	// json["VolatilityWk"] = first+'%';
	json["VolatilityWk"] = first;
	json["VolatilityMo"] = second;
  } 
  console.log(JSON.stringify(json));
}

// Expecting:
//    "Volatility (Week)": "2.24%"
//    "Volatility (Month)": "2.29%"
// Transform into 
// 	VolatilityWk
//	VolatilityMo
// with the same numbers, and delete original entries
function parse2(str) {
  const json = JSON.parse(str);
  json.VolatilityWk = json["Volatility (Week)"];
  delete json["Volatility (Week)"];
  json.VolatilityMo = json["Volatility (Month)"];
  delete json["Volatility (Month)"];
  console.log(JSON.stringify(json));
}


process.stdin.pipe(concat(parse2));
