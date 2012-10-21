class LinksController < ApplicationController

  respond_to :json

  def index
    status = 200
    links = []
    s = Session.find(params[:uuid])
    if s and user = User.find(s.screen_name)
      links = user.twitter_links.sort{|x,y| y.created_at <=> x.created_at}
      status = 200
    else
      status = 202
    end
    render json: links, status: status
  end

end
