require_relative "picture"
require_relative "docomo_api"

#picture = Picture.new
#picture.get_shift_img("mmmlln")

api = DocomoAPI.new
file = File.open("./image/servise-time.jpg")

result = api.req_face_detection(file)
if result[:status] == "ok"
  p "認証に成功しました"
  p result[:data]['detectionFaceNumber']
elsif result[:status] == "no_face"
  p "人物画像ではありません"
else
  p "認証に失敗しました"
  p result[:status]
end
