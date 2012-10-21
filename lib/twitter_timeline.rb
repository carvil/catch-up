class TwitterTimeline

  attr_accessor :user, :since_id, :client, :tweets

  def self.fetch_timeline(user, since_id = nil)
    tt = TwitterTimeline.new
    tt.user = user
    tt.since_id = since_id if since_id
    tt
  end

  def client
    @client ||= client = Twitter::Client.new(
      oauth_token: user.token,
      oauth_token_secret: user.secret
    )
  end

  def opts
    opts = { count: 200 }
    opts[:since_id] = since_id if since_id
    opts
  end

  def tweets
    @tweets ||= client.home_timeline( opts )
  end

  def fetch_link_data
    Rails.logger.info "#{DateTime.now} - Downloaded #{tweets.count} tweets"
    first = true
    tweets.reduce([]) {|acc, tweet|
      if first
        @since_id = tweet.id
        first = false
      end
      data = {}
      data["created_at"] = tweet.created_at.to_i
      data["user_screen_name"] = tweet.user.screen_name
      data["url"] = tweet.urls.map{ |url| url[:expanded_url] }.first
      acc << data unless data["url"].nil?
      acc
    }
  end

end
