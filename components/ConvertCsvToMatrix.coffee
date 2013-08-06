
noflo = require "noflo"
csv = require "csv"

class ConvertCsvToMatrix extends noflo.Component
  constructor: ->
    @parseOptions = comment: '#', delimiter: ',', escape: '"'

    @inPorts =
      in: new noflo.Port()
      options: new noflo.Port()
    @outPorts =
      out: new noflo.Port()
      error: new noflo.Port()

    @inPorts.options.on "data", (newOptions) =>
      @parseOptions = newOptions

    @inPorts.in.on "data", (csvText) =>
      csv().from.string(csvText, @parseOptions)
      .to.array (parsedRowArrays) =>
        @outPorts.out.send parsedRowArrays
      .on "error", (error) =>
        @outPorts.error.send { csvText: csvText, error: error.message }

exports.getComponent = -> new ConvertCsvToMatrix()