require 'securerandom'
require 'pismo'

class Metadata

  attr_accessor :pismo, :diffbot_conn

  def self.fetch_metadata(urls_list)
    metadata = Metadata.new
    metadata.fetch_metadata(urls_list)
  end

  def diffbot_conn
    @diffbot_conn = Faraday.new(:url => 'http://www.diffbot.com/') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter :net_http
      faraday.response :json, :content_type => /\bjson$/
    end
  end

  def valid_pismo?(doc)
    summary = doc.lede || doc.description
    !doc.title.empty? and !summary.empty? and summary.size > 20
  end

  def unique_id
    SecureRandom.uuid.gsub("-", "").hex
  end

  def default_image
    "/assets/games_placeholder.png"
  end

  def get_diffbot_metadata(url)
    doc = diffbot_conn.get '/api/article', { token: DIFFBOT_TOKEN, url: url } do |req|
      req.options[:timeout] = 10 if Rails.env.development?
    end
    if error = doc.body["error"]
      Rails.logger.error "Diffbot - Unable to process #{url} - #{error}"
      nil
    else
      text = doc.body["text"]
      Rails.logger.info "Document retrieved by diffbot for #{url}"
      summary = text.slice(0,300) if text
      {
        "id" => unique_id,
        "title" => doc.body["title"],
        "summary" => summary,
        "thumbnail_url" => doc.body["icon"] || default_image
      }
    end
  rescue Exception => e
    Rails.logger.error e
    Rails.logger.error "Diffbot - Unable to process #{url}"
    nil
  end

  def get_metadata_for(url)
    begin
      doc = Pismo::Document.new(url)
      if valid_pismo?(doc)
        Rails.logger.info "Document retrieved by pismo for #{url}"
        summary = doc.lede.size < doc.description.size ? doc.description : doc.lede
        {
          "id" => unique_id,
          "title" => doc.title,
          "summary" => summary.slice(0,300),
          "thumbnail_url" => doc.images.try(:first) || default_image
        }
      else
        get_diffbot_metadata(url)
      end
    rescue
      get_diffbot_metadata(url)
    end
  end

  def fetch_metadata(urls)
    urls.reduce([]) {|acc, url_data|
      url = url_data['url']
      current_link = TwitterLink.find(url)
      if current_link
        acc << current_link
      else
        Rails.logger.info "Processing #{url}"
        meta = get_metadata_for(url)
        unless meta.nil?
          meta = url_data.merge(meta)
          tl = TwitterLink.new(meta)
          tl.save
          acc << tl
        end
      end
      acc
    }
  end

end
