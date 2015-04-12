# メイドさんのお給仕情報の画像を保存するためのスクリプト
require "twitter"
require 'dotenv'
require 'open-uri'
require "rmagick"
require_relative "docomo_api"
require_relative "twitter_client"
include Magick

class Picture
  def initialize
    @client = TwitterClient.new
  end

  #userの"お給仕予定"が含まれたツイートの画像を取得
  def get_shift_img(user)
    @client.get_all_tweets(user).each do |tweet|
      if tweet.text.index("お給仕予定")
        tweet.media.each do |media|
          path = media.media_url.to_s        # @path=画像URL
          save_file(path)                    # その画像をjpgで保存
          filename = File.basename(path)     # fileName="XXXX.jpg"
          grayscale(filename)                # グレースケール部分のみ取得
          ocr = DocomoAPI.new                # そのままDocomoAPIでocr
          ocr.req_ocr(filename)
          ocr.get_ocr
        end
      end
    end
  end

  private
  # URLから画像ファイルを取得
  def save_file(url)
    filename = File.basename(url)
    open(filename,'wb') do |file|
      open(url) do |data|
        file.write(data.read)
      end
    end
  end

  # RMagickで画像のうちグレースケール部分のみ取得
  def grayscale(file)
    img = ImageList.new(file)
    white = Magick::Pixel.new(255*256,255*256,255*256) # この色で塗りつぶす
    for y in 0...img.rows
      for x in 0...img.columns
        src = img.pixel_color(x, y) # 元画像のピクセルを取得
        rg = (src.red - src.green).abs
        gb = (src.green - src.blue).abs
        br = (src.blue - src.red).abs
        img.pixel_color(x,y,white) unless grayscale?(rg,gb,br)  # グレースケール以外の場合、白で塗りつぶす
      end
    end
      img.write file
  end
 
  def grayscale?(rg,gb,br)
    if ((rg<10*256)&&(gb<10*256)&&(br<10*256))
      return true
    else
      return false
    end
  end
end
