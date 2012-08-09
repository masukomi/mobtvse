# Month isn't actually stored in the database
# It's just a useful way for interacting with 
# things that happen in a month
class Month < Timespan
  #include Mongoid::Document
  attr_reader :start, :end
  def initialize(day_in_month)
    #TODO consider using Chronic 
    # https://github.com/mojombo/chronic
    # so that people can pass in just the month and year or something similar
    @start = day_in_month.at_beginning_of_month.at_beginning_of_day
    @end = day_in_month.at_end_of_month.end_of_day
  end

  def previous()
    return Month.new(@start.ago(1.month))
  end

  def next()
    return Month.new(@start + 1.month)
  end

  # SEE timespan.rb for the inherited methods


  def to_s
    return "#<Month :start=>#{@start}, :end=>#{@end}>"
  end

end
