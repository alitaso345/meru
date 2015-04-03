require 'rest_client'
require 'json'

API_KEY = ENV['DOCOMO_API_KEY']

uri = 'https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/scene?APIKEY=' + API_KEY

response = RestClient.post(
  uri,
  {:image => File.open('shift_kozue.jpg'),
   :lang => 'jpn'
  },
  :content_type => 'multipart/form-data'
)

json=JSON.parser.new(response)
hash=json.parse()
p hash
