require_relative "premium_maid"
require_relative "crawler"
require_relative "kozue"

crawler = Crawler.new
kozue = Kozue.new

info = crawler.get_maides_info
kozue.get_image_from_twitter(info)
