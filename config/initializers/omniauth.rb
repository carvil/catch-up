OmniAuth.config.logger = Rails.logger

TWITTER_CFG = YAML.load_file("#{Rails.root}/config/twitter.yml")[Rails.env]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER_CFG["key"], TWITTER_CFG["secret"]
end
