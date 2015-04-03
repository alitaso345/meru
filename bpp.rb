require_relative "docomo_api"
require_relative "get_shift"

image=GetShift.new
ocr=DocomoAPI.new

image.get_shift_img("mmmlln")
ocr.get_ocr

