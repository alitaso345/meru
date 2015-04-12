require_relative "picture"
require_relative "docomo_api"
require "pry"
file = File.open("./image/servise-time.jpg")
api = DocomoAPI.new(file)

result = api.req_face_detection
if result[:status] == "success"
  p "認証に成功しました"
  p result[:data]['detectionFaceNumber']
elsif result[:status] == "no_face"
  p "人物画像ではありません"
  #ここでお給仕予定画像かその他の画像か判定
  api.req_ocr
  data = api.get_ocr
  p data[:data]["lines"]["line"].map{|line| line["@text"]}
else
  p "認証に失敗しました"
  p result[:status]
end
