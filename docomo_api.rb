require 'rest_client'
require 'json'

API_KEY = ENV['DOCOMO_API_KEY']

###   情景画像認識要求   ###
uri = URI('https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/scene')
uri.query = 'APIKEY=' + API_KEY

response = RestClient.post(
  uri.to_s,
  {:image => File.open('shift_kozue.jpg'),
   :lang => 'jpn'
  },
  :content_type => 'multipart/form-data'
)

###   情景画像認識結果取得   ###
json = JSON.parser.new(response)
hash = json.parse()

parsed = hash['job']
id = parsed['@id']
uri.path += "/" +  id
loop do
  result = RestClient.get(uri.to_s)
  json2 = JSON.parser.new(result)
  $hash2 = json2.parse()
  break if $hash2['job']['@status']=="success"
end

p $hash2
