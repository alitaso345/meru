require "twitter"
require 'dotenv'
require 'open-uri'
require 'tesseract-ocr'

Dotenv.load
CONS_KEY = ENV['TWITTER_CONSUMER_KEY']
CONS_SEC = ENV['TWITTER_CONSUMER_SECRET']
ACCS_KEY = ENV['TWITTER_ACCESS_TOKEN']
ACCS_SEC = ENV['TWITTER_ACCESS_SECRET']

client = Twitter::REST::Client.new do |config|
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
def client.get_all_tweets(user)
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

#めるさんのお給仕情報を文字化
client.get_all_tweets("mmmlln").each do |tweet|
  if tweet.text.index("お給仕予定")
    tweet.media.each do |media|
      @path=media.media_url.to_s          # @path=画像URL
      save_file(@path)                    # その画像をjpgで保存
      fileName = File.basename(@path)     # fileName="XXXX.jpg"

      open(fileName, 'wb') do |output|    # 保存した画像をOCR 
        open(@path) do |data|
          output.write(data.read)
        end
      end

      engine = Tesseract::Engine.new{ |engine|　#tessetactの設定？
        engine.language = :jpn
      }

      puts engine.text_for(fileName)
      p "--------------------------------------------------"

    end
  end
end
