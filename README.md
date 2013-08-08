NoFlo CSV
=========

NoFlo components to convert CSV data to JavaScript objects.  When time permits, I'll add components that
express JavaScript objects as CSV, although this mapping may be less straightforward.

Components
----------

1. [ConvertCsvToMatrix](http://noflojs.org/component/noflo-csv-ConvertCsvToMatrix/) has a CSV in port that accepts text data and an OUT port that sends a JavaScript array of arrays representing the parsed data.
2. [ConvertCsvToObjectPerRow](http://noflojs.org/component/noflo-csv-ConvertCsvToObjectPerRow/) has a CSV in port that also accepts text data and an OUT port that sends a Javascript object for each row of the output.  The first line of the CSV data is considered to be the header and the column headings will be used for the object keys.

Please take a look at the docco examples for these components on the [NoFlo web site](http://noflojs.org).
