require 'rest_client'
require 'json'

API_KEY = ENV['DOCOMO_API_KEY']

###   画像認識要求   ###
uri = URI('https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/document')
uri.query = 'APIKEY=' + API_KEY

response = RestClient.post(
  uri.to_s,
  {:image => File.open('shift_kozue.jpg'),
   :lang => 'jpn'
  },
  :content_type => 'multipart/form-data'
)

###   画像認識結果取得   ###
json = JSON.parser.new(response)
hash = json.parse()

id = hash['job']['@id']
uri.path += "/" +  id

loop do
  result = RestClient.get(uri.to_s)
  json2 = JSON.parser.new(result)
  $hash2 = json2.parse()
  if $hash2['job']['@status']=="success"
    break
  elsif $hash2['job']['@status']!="process"
    p "失敗もしくは削除済みです"
    exit
  end
end

text =  $hash2['lines']['line']
text.each do |text|
  p text['@text'] rescue nil
end
