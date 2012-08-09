class SetPageFlag < Mongoid::Migration
  def self.up
    Post.all.each do |p|
      unless p.page #just in case they've mucked with it manually
        p.page = false;
        p.save()
      end
    end
  end

  def self.down
    #no down. we wouldn't want to make them all true
  end
end
