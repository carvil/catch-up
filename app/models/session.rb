require 'ripple'

class Session
  include Ripple::Document

  property :uuid, String, presence: true
  property :screen_name, String

  def key
    @key ||= uuid
  end

  def self.create_with_uuid_and_name(uuid, name)
    create! do |s|
      s.uuid = uuid
      s.screen_name = name
    end
  end

end

