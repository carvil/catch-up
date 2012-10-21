class TwitterLinkSerializer < ActiveModel::Serializer
  attributes :id, :title, :summary, :url, :thumbnail_url, :created_at, :user_screen_name
end
