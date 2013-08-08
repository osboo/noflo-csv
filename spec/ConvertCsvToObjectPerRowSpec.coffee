if typeof process is "object" and process.title is "node"
  chai = require "chai" unless chai
  componentModule = require "../components/ConvertCsvToObjectPerRow"
  noflo = require "noflo"
  util = require "util"

describe "ConvertCsvToObjectPerRow", ->
  @timeout 5000  # Dear mocha, don't timeout tests that take less than 5 seconds. Kthxbai
  component = null
  csvSocket = null
  outSocket = null
  errorSocket = null
  outMessages = []
  errorMessages = []

  before ->
    component = componentModule.getComponent()
    csvSocket = noflo.internalSocket.createSocket()
    outSocket = noflo.internalSocket.createSocket()
    errorSocket = noflo.internalSocket.createSocket()

    component.inPorts.csv.attach csvSocket
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

      csvSocket.send 'ts,year,ms,chars,age,date\n20322051544,1979.0,8.8017226E7,ABC,45,2000-01-01\n28392898392,1974.0,8.8392926E7,DEF,23,2050-11-27\n'
      setTimeout done, 1000  # wait 1 second to be sure all messages have been processed.

    it "should send the parsed data to the out port", ->
      chai.expect(outMessages).to.deep.equal( [
        { ts: "20322051544", year: "1979.0", ms: "8.8017226E7", chars: "ABC", age: "45", date: "2000-01-01" },
        { ts: "28392898392", year: "1974.0", ms: "8.8392926E7", chars: "DEF", age: "23", date: "2050-11-27" }
      ] )

    it "should not send any error messages", ->
      chai.expect(errorMessages).to.deep.equal( [ ] )

  describe "can report errors", ->
    before (done) ->
      outMessages.length = 0
      errorMessages.length = 0

      csvSocket.send 'ts,year,ms,chars,age,date\n20322051544,1979.0,8.8017226E7,ABC,45,2000-01-01\n28392898392,1974.0,8.8392926E7,DEF,"23,2050-11-27\n'
      setTimeout done, 1000  # wait 1 second to be sure all messages have been processed.

    it "should send the parsed data to the out port", ->
      chai.expect(outMessages).to.deep.equal( [
        { ts: "20322051544", year: "1979.0", ms: "8.8017226E7", chars: "ABC", age: "45", date: "2000-01-01" }
      ] )

    it "should send an error messages", ->
      chai.expect(errorMessages).to.deep.equal( [
        csvText: 'ts,year,ms,chars,age,date\n20322051544,1979.0,8.8017226E7,ABC,45,2000-01-01\n28392898392,1974.0,8.8392926E7,DEF,"23,2050-11-27\n',
        error: "Quoted field not terminated at line 1"
      ] )
