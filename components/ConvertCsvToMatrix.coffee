
noflo = require "noflo"
csv = require "csv"

class ConvertCsvToMatrix extends noflo.Component
  constructor: ->
    @parseOptions = comment: '#', delimiter: ',', escape: '"'

    @inPorts =
      csv: new noflo.Port()
      config: new noflo.Port()
    @outPorts =
      out: new noflo.Port()
      error: new noflo.Port()

    @inPorts.config.on "data", (newOptions) =>
      @parseOptions = newOptions

    @inPorts.csv.on "data", (csvText) =>
      csv().from.string(csvText, @parseOptions)
      .to.array (parsedRowArrays) =>
        @outPorts.out.send parsedRowArrays
      .on "error", (error) =>
        @outPorts.error.send { csvText: csvText, error: error.message }

exports.getComponent = -> new ConvertCsvToMatrix()