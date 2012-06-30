class AddKudosToPosts < Mongoid::Migration
  def self.up
    Post.all.each do |p|
      if p.kudos.nil?
        p.kudos =0
        p.save()
      end
    end
  end

  def self.down
  end
end
