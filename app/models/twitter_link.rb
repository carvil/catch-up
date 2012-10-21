require 'ripple'

class TwitterLink
  include Ripple::Document

  property :url, String, presence: true
  property :id, Integer
  property :title, String
  property :summary, String
  property :thumbnail_url, String
  property :created_at, Integer, default: proc { DateTime.now.to_i }, presence: true
  property :user_screen_name, String

  def key
    @key ||= url
  end

  def active_model_serializer
    TwitterLinkSerializer
  end

end
