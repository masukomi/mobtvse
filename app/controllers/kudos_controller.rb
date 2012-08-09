class KudosController < ApplicationController

  def count
    response.headers['Cache-Control'] = 'no-cache'
    #response.headers['Cache-Control'] = 'public, max-age=120'
    #currently not caching this, but we may want to with a limited 
    #timeout on more popular sites. Maybe a site config setting?
    ids = params[:id].split(/\s*,\s*/)
    post_ids_hash = Hash[*Post.only(:kudos).in(_id: ids).entries.map{|p| [p._id.to_s, p.kudos]}.flatten]
    respond_to do |format|
      format.json { render :json => post_ids_hash }
    end
  end
end
