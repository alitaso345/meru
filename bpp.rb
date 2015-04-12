require_relative "picture"
require_relative "docomo_api"

#picture = Picture.new
#picture.get_shift_img("mmmlln")

api = DocomoAPI.new
api.req_face_detection(File.open("./image/other.jpg"))
