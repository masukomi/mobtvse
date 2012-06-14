class Day < Timespan
  #include Mongoid::Document
  attr_reader :start, :end

  # SEE timespan.rb for the inherited methods

  def initialize(date)
    @start = date.at_beginning_of_day
    @end = date.end_of_day
  end

  def previous()
    return Day.new(@start.ago(1.day))
  end

  def next()
    return Day.new(@start + 1.day)
  end


  def to_s
    return "#<Day :start=>#{@start}, :end=>#{@end}>"
  end

end
