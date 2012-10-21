TWITTER = YAML.load_file("#{Rails.root}/config/twitter.yml")[Rails.env]

Twitter.configure do |config|
  config.consumer_key = TWITTER["key"]
  config.consumer_secret = TWITTER["secret"]
end
