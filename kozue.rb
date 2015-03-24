require "twitter"
require 'dotenv'
Dotenv.load
CONS_KEY = ENV['YOUR_CONSUMER_KEY']
CONS_SEC = ENV['YOUR_CONSUMER_SECRET']
ACCS_KEY = ENV['YOUR_ACCESS_TOKEN']
ACCS_SEC = ENV['YOUR_ACCESS_SECRET']

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

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

client.get_all_tweets("kozupi10akay").each do |tweet|
   p tweet.text if tweet.text.index("お給仕")
end
   # twitter gemのsearchの使い方わからなかったから、
   # rubyのindexメソッドを使いました・・・なんか綺麗じゃない
