class FetchTimeline
  @queue = :existing_users_processing

  def self.perform(screen_name, since_id)
    Rails.logger.info "Fetch Tweets Since #{since_id}"

    Rails.logger.info "Fetch the user"
    user = User.find(screen_name)

    Rails.logger.info "Fetch tweets from home_timeline and fetch URLs from tweets"
    tt = TwitterTimeline.fetch_timeline(user, since_id)
    tweet_urls = tt.fetch_link_data

    Rails.logger.info "Fetch metadata from URLs"
    metadata = Metadata.fetch_metadata(tweet_urls)

    Rails.logger.info "Set metadata in riak"
    metadata.each do |meta|
      begin
        new_link = Riak::Link.new("twitter_links", meta.url, "twitter_links")
        user.robject.links.add(new_link)
        user.save
        Rails.logger.info "Saved TwitterLink: #{meta.inspect}"
      rescue Exception => e
        Rails.logger.info "Error in TwitterLink: #{meta.inspect}"
        Rails.logger.error "Unable to process metadata for link"
        Rails.logger.error e
      end
    end

    # Auto-schedule FetchTimeline for screen_name and new since_id
    Resque.enqueue(FetchTimeline, screen_name, tt.since_id)
  end
end

