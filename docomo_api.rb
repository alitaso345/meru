require 'rest_client'

API_KEY = ENV['DOCOMO_API_KEY']

uri = 'https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/scene?APIKEY=' + API_KEY

response = RestClient.post(
  uri,
  {:image => File.open('shift_kozue.jpg'),
   :lang => 'jpn'
  },
  :content_type => 'multipart/form-data'
)

p response
