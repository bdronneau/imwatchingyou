# http://stackoverflow.com/questions/9008847/what-is-difference-between-p-and-pp
require 'pp'
require 'logger'
require 'nokogiri'
require 'rss'
require 'open-uri'

class GifMe
  def lesjoiesdusysadmin
    post = []
    random_post = Net::HTTP.get_response("lesjoiesdusysadmin.tumblr.com","/random")
    link_url = random_post.header['location'][/(.*)\#/].gsub('#','')
    feed = RSS::Parser.parse(
      Net::HTTP.get_response(
        URI.parse(URI.encode("#{link_url}/rss"))
      ).body
    )

    item = feed.items.sample
    post.push(item.title)
    # Regex url img/gif
    post.push(item.description[%r{http(|s)\:\/\/(.*)\.(png|jpg|jpeg|gif)}])

    post
  end
end
