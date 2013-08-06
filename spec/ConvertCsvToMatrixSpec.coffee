if typeof process is "object" and process.title is "node"
  chai = require "chai" unless chai
  componentModule = require "../components/ConvertCsvToMatrix"
  noflo = require "noflo"
  util = require "util"

describe "ConvertCsvToMatrix", ->
  @timeout 5000  # Dear mocha, don't timeout tests that take less than 5 seconds. Kthxbai
  component = null
  inSocket = null
  outSocket = null
  errorSocket = null
  outMessages = []
  errorMessages = []

  before ->
    component = componentModule.getComponent()
    inSocket = noflo.internalSocket.createSocket()
    outSocket = noflo.internalSocket.createSocket()
    errorSocket = noflo.internalSocket.createSocket()

    component.inPorts.in.attach inSocket
    component.outPorts.out.attach outSocket
    component.outPorts.error.attach errorSocket

    # Listen for messages on the out and url ports.  Add the messages to an array for later inspection.
    errorSocket.on "data", (message) ->
      errorMessages.push message
      # console.log util.inspect message, 4, true, true  # uncomment this line if you want to see log messages as they arrive.

    outSocket.on "data", (message) ->
      outMessages.push message

  describe "can parse CSV data", ->
    before (done) ->
      outMessages.length = 0
      errorMessages.length = 0

      inSocket.send '#Welcome\n"1","2","3","4"\n"a","b","c","d"'
      setTimeout done, 1000  # wait 1 second to be sure all messages have been processed.

    it "should send the parsed data to the out port", ->
      chai.expect(outMessages).to.deep.equal( [ [ [ '1', '2', '3', '4' ], [ 'a', 'b', 'c', 'd' ] ] ] )

    it "should not send any error messages", ->
      chai.expect(errorMessages).to.deep.equal( [ ] )

  describe "can report errors", ->
    before (done) ->
      outMessages.length = 0
      errorMessages.length = 0

      inSocket.send '#Welcome\n"1","2","3","4"\n"a","b","c","d'
      setTimeout done, 1000  # wait 1 second to be sure all messages have been processed.

    it "should send the parsed data to the out port", ->
      chai.expect(outMessages).to.deep.equal( [ ] )

    it "should not send any error messages", ->
      chai.expect(errorMessages).to.deep.equal( [
        csvText: '#Welcome\n"1","2","3","4"\n"a","b","c","d',
        error: "Quoted field not terminated at line 1"
      ] )
