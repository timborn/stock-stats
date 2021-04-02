# https://stackoverflow.com/questions/57242240/jq-object-cannot-be-csv-formatted-only-array
# Usage: jq -srf json2csv.jq INPUT.json

def json2header:
  [paths(scalars)];

def json2array($header):
  json2header as $h
  | if $h == $header or (($h|sort) == ($header|sort))
    then [$header[] as $p | getpath($p)]
    else "headers do not match: expected followed by found paths:" | debug
    | ($header|map(join(".")) | debug)
    | ($h|map(join(".")) | debug)
    | "headers do not match" | error
    end ;

# given an array of conformal objects, produce "CSV" rows, with a header row:
def json2csv:
  (.[0] | json2header) as $h
  | ([$h[]|join(".")], (.[] | json2array($h))) 
  | @csv ;

# `main`
json2csv
