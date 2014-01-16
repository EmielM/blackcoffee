return if global.testingBrowser

SourceMap = require '../src/sourcemap'

test "encodeVlq tests", ->
  vlqEncodedValues = [
    [1, "C"],
    [-1, "D"],
    [2, "E"],
    [-2, "F"],
    [0, "A"],
    [16, "gB"],
    [948, "o7B"]
  ]
  for pair in vlqEncodedValues
    eq ((new SourceMap).encodeVlq pair[0]), pair[1]

eqJson = (a, b) ->
  eq (JSON.stringify JSON.parse a), (JSON.stringify JSON.parse b)

test "SourceMap tests", ->
  test = [
    [0, 0, "\n\nabcd"]
    [1, 5, "abc"]
    [1, 6, "a"]
    [1, 9, "\nabcd"]
    [3, 0, ""]
  ]
  helpers = require('../src/helpers')
  fileNum = helpers.getFileNum '', 'fakefile.coffee'
  fragments = for [srcLine,srcCol,dstCode] in test
    code: dstCode
    locationData:
      first_line: srcLine
      first_column: srcCol
      file_num: fileNum
  
  map = new SourceMap fragments

  eqJson map.generate(generatedFile:"faketarget.js"), '{"version":3,"file":"faketarget.js","sourceRoot":"","sources":["fakefile.coffee"],"names":[],"mappings":"AAAA;;IACK,GAAC,CAAG;IAET"}'

  # Look up a generated column - should get back the original source position.
  x = map.sourceLocation 2, 8
  eq 1, x.first_line
  eq 9, x.first_column

  # Look up a point futher along on the same line - should get back the same source position.
  x = map.sourceLocation 2, 10
  eq 1, x.first_line
  eq 9, x.first_column

  helpers.scripts.length = 0
  helpers.filenames.length = 0

test "SourceMap tests (with three combined files)", ->
  helpers = require('../src/helpers')

  firstFileNum = helpers.getFileNum '', 'first_fakefile.coffee'
  secondFileNum = helpers.getFileNum '', 'second_fakefile.coffee'
  thirdFileNum = helpers.getFileNum '', 'third_fakefile.coffee'

  test = [
    [firstFileNum,  0, 0, "dummy\n"]
    [firstFileNum,  1, 0, "dummy\n"]
    [secondFileNum, 0, 0, "dummy\n"]
    [secondFileNum, 1, 0, "dummy\n"]
    [secondFileNum, 2, 0, "dummy\n"]
    [thirdFileNum,  0, 0, "dummy\n"]
    [thirdFileNum,  1, 0, "dummy"]
  ]
  fragments = for [fileNum, srcLine, srcCol, dstCode] in test
    code: dstCode
    locationData:
      first_line: srcLine
      first_column: srcCol
      file_num: fileNum

  map = new SourceMap fragments

  eqJson map.generate(generatedFile:"faketarget.js"), '{"version":3,"file":"faketarget.js","sourceRoot":"","sources":["first_fakefile.coffee","second_fakefile.coffee","third_fakefile.coffee"],"names":[],"mappings":"AAAA;AACA;ACDA;AACA;AACA;ACFA;AACA"}'

  helpers.scripts.length = 0
  helpers.filenames.length = 0

