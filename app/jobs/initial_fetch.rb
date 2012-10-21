require "cgi"

class InitialFetch
  @queue = :new_users_processing

  def self.perform(screen_name)
    Rails.logger.info "Fetch the user"
    user = User.find(screen_name)

    Rails.logger.info "Fetch tweets from home_timeline and fetch URLs from tweets"
    tt = TwitterTimeline.fetch_timeline(user)
    tweet_urls = tt.fetch_link_data

    Rails.logger.info "Fetch metadata from URLs"
    metadata = Metadata.fetch_metadata(tweet_urls)

    Rails.logger.info "Set metadata in riak"
    metadata.each do |meta|
      Rails.logger.info "Meta: #{meta.inspect}"
      Rails.logger.info "URL: #{CGI.escape(meta.url)}"
      begin
        new_link = Riak::Link.new("/riak/twitter_links/#{CGI.escape(meta.url)}", "twitter_links")
        Rails.logger.info "The link: #{new_link.inspect}"
        user.robject.links.add(new_link)
        user.save
        Rails.logger.info "Saved TwitterLink: #{meta.inspect}"
      rescue Exception => e
        Rails.logger.info "Error in TwitterLink: #{meta.inspect}"
        Rails.logger.error "Unable to process metadata for link"
        Rails.logger.error e
      end
    end

    Rails.logger.info "Delete user from cache"
    Rails.cache.delete(screen_name)

    Rails.logger.info "Schedule FetchTimeline for screen_name and since_id"
    Resque.enqueue(FetchTimeline, screen_name, tt.since_id)

    Rails.logger.info "DMs the user"
    client = Twitter::Client.new(
      oauth_token: TWITTER['access_token'],
      oauth_token_secret: TWITTER['access_token_secret']
    )
    client.direct_message_create(screen_name,"Thanks for your patience, @#{screen_name}! CatchUp has now content for you, check it out here: http://catchup.r12.railsrumble.com/")
  end
end
