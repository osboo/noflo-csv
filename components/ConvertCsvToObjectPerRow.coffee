
noflo = require "noflo"
csv = require "csv"
_ = require "underscore"

class ConvertCsvToObjectPerRow extends noflo.Component
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
      header = null

      csv().from.string(csvText, @parseOptions)
      .transform (parsedRow) =>
        if header
          @outPorts.out.send _.object(header, parsedRow)
        else
          header = parsedRow
          @outPorts.out.beginGroup { startTime: new Date(), headers: header }
      .on 'error', (error) =>
        @outPorts.error.send { csvText: csvText, error: error }
      .on "end", =>
        @outPorts.out.endGroup()

exports.getComponent = -> new ConvertCsvToObjectPerRow()
