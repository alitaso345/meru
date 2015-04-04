# メイドさんのお給仕情報の画像を保存するためのスクリプト
require "twitter"
require 'dotenv'
require 'open-uri'
require "rmagick"
require_relative "docomo_api"
include Magick

Dotenv.load
CONS_KEY = ENV['TWITTER_CONSUMER_KEY']
CONS_SEC = ENV['TWITTER_CONSUMER_SECRET']
ACCS_KEY = ENV['TWITTER_ACCESS_TOKEN']
ACCS_SEC = ENV['TWITTER_ACCESS_SECRET']

class GetShift
  @@client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONS_KEY
      config.consumer_secret     = CONS_SEC
      config.access_token        = ACCS_KEY
      config.access_token_secret = ACCS_SEC
    end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  # userのすべてのツイートを取得
  def @@client.get_all_tweets(user)
    collect_with_max_id do |max_id|
      options = {count: 200,            #最大取得数
                 include_rts: false,    #リツイートを含めない
                 include_entities: true #URL情報を取得
      }
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(user, options)
    end
  end

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
        if src==white # 白の場合は何もしない
        elsif !((rg<10*256)&&(gb<10*256)&&(br<10*256)) # グレースケール以外の場合、白で塗りつぶす
          img.pixel_color(x,y,white)
        end
      end
    end
      img.write file
  end

  #userの"お給仕予定"が含まれたツイートの画像を取得
  def get_shift_img(user)
    @@client.get_all_tweets(user).each do |tweet|
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
end
