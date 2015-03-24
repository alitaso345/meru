require_relative "premium_maid"
require_relative "crawler"

maid = PremiumMaid.new
puts maid.get_json
Crawler.start
