require "twitter"
require 'dotenv'

class Kozue
  def initialize
    Dotenv.load
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['YOUR_CONSUMER_KEY'] 
      config.consumer_secret     = ENV['YOUR_CONSUMER_SECRET'] 
      config.access_token        = ENV['YOUR_ACCESS_TOKEN'] 
      config.access_token_secret = ENV['YOUR_ACCESS_SECRET'] 
    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def get_all_tweets(user)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: true}
      options[:max_id] = max_id unless max_id.nil?
      user_timeline(user, options)
    end
  end
end

Kozue.new.get_all_tweets("kozupi10akay").each do |tweet|
   p tweet.text if tweet.text.index("お給仕")
end
# twitter gemのsearchの使い方わからなかったから、
# rubyのindexメソッドを使いました・・・なんか綺麗じゃない
