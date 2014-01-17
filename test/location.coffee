testScript = '''
if true
  x = 6
  console.log "A console #{x + 7} log"

foo = "bar"
z = /// ^ (a#{foo}) ///

x = () ->
    try
        console.log "foo"
    catch err
        # Rewriter will generate explicit indentation here.

    return null
'''

test "Verify location of generated tokens", ->
  tokens = CoffeeScript.tokens "a = 79"

  eq tokens.length, 4

  aToken = tokens[0]
  eq aToken[2].first_line, 0
  eq aToken[2].first_column, 0
  eq aToken[2].last_line, 0
  eq aToken[2].last_column, 0

  equalsToken = tokens[1]
  eq equalsToken[2].first_line, 0
  eq equalsToken[2].first_column, 2
  eq equalsToken[2].last_line, 0
  eq equalsToken[2].last_column, 2

  numberToken = tokens[2]
  eq numberToken[2].first_line, 0
  eq numberToken[2].first_column, 4
  eq numberToken[2].last_line, 0
  eq numberToken[2].last_column, 5

test "Verify location of generated tokens (with indented first line)", ->
  tokens = CoffeeScript.tokens "  a = 83"

  eq tokens.length, 4
  [aToken, equalsToken, numberToken] = tokens

  eq aToken[2].first_line, 0
  eq aToken[2].first_column, 2
  eq aToken[2].last_line, 0
  eq aToken[2].last_column, 2

  eq equalsToken[2].first_line, 0
  eq equalsToken[2].first_column, 4
  eq equalsToken[2].last_line, 0
  eq equalsToken[2].last_column, 4

  eq numberToken[2].first_line, 0
  eq numberToken[2].first_column, 6
  eq numberToken[2].last_line, 0
  eq numberToken[2].last_column, 7

test "Verify all tokens get a location", ->
  doesNotThrow ->
    tokens = CoffeeScript.tokens testScript
    for token in tokens
        ok !!token[2]

if require?
  test "Verify setting of nodes' file number", ->
    {walk: walkNodes} = require '../src/nodes'
    eqNodesFileNum = (nodes, fileNum) ->
      eq nodes.locationData.file_num, fileNum
      walkNodes nodes, (n) ->
        eq n.locationData.file_num, fileNum
        return

    # Get value from *cached* 'helpers' module.
    firstFileNum = require('../lib/coffee-script/helpers').scripts.length

    eqNodesFileNum CoffeeScript.nodes('a = 1'), firstFileNum
    eqNodesFileNum CoffeeScript.nodes('a = 2'), firstFileNum + 1
