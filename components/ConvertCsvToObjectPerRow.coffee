
noflo = require "noflo"
csv = require "csv"
_ = require "underscore"

# This component converts CSV text from the CSV port into an array of arrays on the OUT port.  The input will be parsed and
# a JavaScript object will be sent to the OUT port for each row parsed successfully.  If a parse error occurs, an error
# message will be sent on the ERROR port and no further rows in the faulty input will be attempted.
# 1 message on the CSV port results in 1 or more messages on either the out or error ports.
#<pre>
#             +--------------------------+
# ----CSV---->|                          |----OUT---->
#             | ConvertCsvToObjectPerRow |
# --CONFIG--->|                          |---ERROR--->
#             +--------------------------+
#</pre>
class ConvertCsvToObjectPerRow extends noflo.Component
  constructor: ->
    @parseOptions = comment: '#', delimiter: ',', escape: '"'

    @inPorts =
      # CSV in port receives text data to be parsed.
      # Example data might look like this:
      # > &#35;This is a comment
      # > "1","2","3","4"
      # > "a","b","c","d"
      csv: new noflo.Port()
      # CONFIG in port receives a JavaScript object which configures how to parse the text data received on the CSV port.
      # See the default parse options above for an example of what might be sent.  You don't need to send a config message
      # if the default options are acceptable.
      config: new noflo.Port()
    @outPorts =
      # OUT out port sends a JavaScript object representing a row of the CSV data that was parsed.  The object keys will
      # be the column headers from the first row of data.
      out: new noflo.Port()
      # ERROR out port sends any error messages from parsing the text CSV data.
      error: new noflo.Port()

    @inPorts.config.on "data", (newOptions) =>
      @parseOptions = newOptions

    @inPorts.csv.on "data", (csvText) =>
      header = null

      csv().from.string(csvText, @parseOptions)
      .transform (parsedRow) =>
        if header
          @outPorts.out.send _.object(header, parsedRow)
        else
          header = parsedRow
          @outPorts.out.beginGroup { startTime: new Date(), headers: header }
      .on 'error', (error) =>
        @outPorts.error.send { csvText: csvText, error: error.message }
      .on "end", =>
        @outPorts.out.endGroup()

exports.getComponent = -> new ConvertCsvToObjectPerRow()
