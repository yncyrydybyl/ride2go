readFile = (filename) ->
  out = []
  require('fs').readFileSync(filename).toString().split('\n').forEach (line) ->
    out.push line
  out

deTxt = readFile './spec/fixtures/DE.txt'
countryInfoTxt = readFile './spec/fixtures/admin1CodesASCII.txt'

module.exports = {deTxt,countryInfoTxt}
