class KudosController < ApplicationController

  def count
    ids = params[:id].split(/\s*,\s*/)
    post_ids_hash = Hash[*Post.only(:kudos).in(_id: ids).entries.map{|p| [p._id.to_s, p.kudos]}.flatten]
    respond_to do |format|
      format.json { render :json => post_ids_hash }
    end
  end
end
