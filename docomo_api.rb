require 'net/http'
require 'uri'
require 'base64'

API_KEY = ENV['DOCOMO_API_KEY']

binary = Base64.strict_encode64(File.new('./word.png').read)

endpoint = URI.parse('https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/document')
endpoint.query = 'APIKEY=' + API_KEY

request_body = {
  'image' => 'data:image/png;base64,' + binary,
  'lang' => 'jpn'
}

res = Net::HTTP.post_form(endpoint, request_body)

case res
when Net::HTTPSuccess
  p "success!"
  p res
  p res.value
else
  p "failed"
  p res
  p res.value
end
