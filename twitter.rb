require 'twitter'
require 'csv'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

def fetch_faves(client, last_id = nil)
  params = {count: 100}
  params.merge!(max_id: last_id) if last_id

  client.favorites(params)
end

faves   = []
last_id = nil

begin
  res = fetch_faves(client, last_id)
  faves << res
  faves.flatten!
  last_id = res.last.id
  p last_id
end until res.count < 100

CSV.open('twitter_faves.csv', 'wb') do |csv|
  csv << ["Date", "Url", "Username", "Tweet", "External Links"]

  faves.each do |tweet|
    csv << [tweet.created_at, tweet.url.to_s, tweet.user.screen_name, tweet.text, tweet.uris.map{|uri| uri.url.to_s}]
  end
end
