require 'ripple'

class User
  include Ripple::Document

  property :screen_name, String, presence: true
  property :provider, String
  property :uid, String
  property :ready, Boolean
  property :token, String
  property :secret, String
  many :twitter_links

  def key
    @key ||= screen_name
  end

  def ready
    ready?
  end

  def ready?
    Rails.cache.fetch(screen_name).nil?
  end

  def self.from_omniauth(auth)
    find(auth["info"]["nickname"]) || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    # Create the user record
    user = create! do |u|
      u.screen_name = auth["info"]["nickname"]
      u.provider = auth["provider"]
      u.uid = auth["uid"]
      u.token = auth['credentials']['token']
      u.secret = auth['credentials']['secret']
    end
    prepare_batch(auth["info"]["nickname"])
    user
  end

  def self.prepare_batch(name)
    # Since it is the first time, add 'processing' flag to redis
    # in order to show message in the UI
    Rails.cache.fetch(name) { "processing" }
    # Schedule an initial fetch of the user timeline
    Resque.enqueue(InitialFetch, name)
  end

end
