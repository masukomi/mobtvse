class CalculateWordCounts < Mongoid::Migration
  def self.up
    Post.all.entries.each do |p|
      p.save()
    end
  end

  def self.down
  end
end
