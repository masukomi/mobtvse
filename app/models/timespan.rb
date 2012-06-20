# Timespan is an abstract class that should 
# never be implemented directly
class Timespan
  #include Mongoid::Document

  class << self
    def for_post(post)
      if post.posted_at
        return self.new(post.posted_at)
      else
        return nil
      end
    end
  end

  def posts(include_drafts = false, include_future=false, reverse_chron=true)
    crit = posts_criteria(include_drafts, @start, @end)
    crit = crit.order(:posted_at=>(reverse_chron ? :desc : :asc))
    entries = crit.entries
    entries.reject!{|p| p.future?} unless include_future
    return entries
  end
  def posts_by_love(include_drafts = false, include_future=false)
    crit = posts_criteria(include_drafts, @start, @end).where(:kudos.gt=>0).order(:kudos=>:desc)
    entries = crit.entries
    entries.collect!{|p| p unless p.future?} unless include_future
    return entries
  end

  def images
    # we don't care if an images is from the future
    # not that there's any non-hacky way for that to happen
    # and there's no such thing as a draft image
    crit = images_criteria(@start, @end)
    return crit.entries
  end

  # Returns the number of kudos for posts in this timespan
  # NOTE this is NOT kudos GIVEN in this timespan. 
  def kudos_count(include_drafts = false, include_future=false)
    total = 0
    posts(include_drafts, include_future).each do |p|
      total += p.kudos
    end
    return total
    # TODO figure out why the following doesn't work
    # posts(include_drafts).inject{|sum, post| sum + (post.kudos)}
  end

  protected
  def posts_criteria(include_drafts, start_time, end_time)
      #BUG include_drafts requires searching on created_at
      # because they don't have a posted_at
      crit = Post.where(:posted_at.gte => start_time, :posted_at.lte => end_time)
      #TODO .and(:posted_at.lte=>DateTime.now) just gets EVERYTHING before now
      # it doesn't seem to and correctly with the above
      if (not include_drafts)
        crit = crit.where(:draft => false)
      end
      return crit
  end

  def images_criteria(start_time, end_time)
    crit = Image.where(:uploaded_on.gte => start_time, :uploaded_on.lte => end_time)
    return crit
  end

end
