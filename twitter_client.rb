require "twitter"

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def get_image_from_twitter(maides_list)
    begin
      maides_list.each do |maid|
        get_all_tweets(maid[:twitter_account]).each do |tweet|
          print_tweet(maid, tweet)
        end
      end
    rescue => e
      p e
    end
  end

  private
  def get_all_tweets(user)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: true}
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(user, options)
    end
  end

  def print_tweet(maid, tweet)
    p "#{maid[:name]}: #{tweet.text}"
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end
end
