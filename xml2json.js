#!/usr/bin/env node
var parser = require('xml2json');
const concat = require('mississippi').concat;

function parse(str) {
  var json = parser.toJson(str);
  console.log(json);
}

process.stdin.pipe(concat(parse));
