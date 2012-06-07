require 'test_helper'

class MonthTest < ActiveSupport::TestCase
	# test "the truth" do
	#   assert true
	# end

	def setup
		CONFIG['post_url_style'] = '/%Y/%m/%d/:slug'
		Post.all.each.destroy()
	end
	def teardown
		Post.all.each.destroy()
	end

	test "range" do
		
		test_time = DateTime.new(2001,2,3,1,2,3, '-05:00')
		Timecop.freeze(test_time) do
			before_date = DateTime.new(2001,1,3,1,2,3, '-05:00')
			before = Post.new(:title=>'before', :draft=>false, :posted_at=>before_date)
					# Jan 3
			before.save!
			after_date =DateTime.new(2001,3,3,1,2,3, '-05:00')
			after = Post.new(:title=>'after', :draft=>false, :posted_at=>after_date)
					# Mar 3
			after.save!
			during_date = DateTime.new(2001,2,3,1,2,3, '-05:00')
			during = Post.new(:title=>'during', :draft=>false, :posted_at=>during_date)
					# Feb 3
			during.save!

			m = Month.new(test_time)
			posts = m.posts()
			#KNOWN BUG... include_drafts parameter doesn't work correctly
			# not testing
			assert_equal 1, posts.size(), "unexpected posts in month#posts: \n\t#{posts.collect{|p|p.to_s}.join("\n\t")}"
			assert_equal 'during', posts[0].title, "wrong post in month#posts"
		end

	end

	test "kudos_count" do # also tests include_future option in .posts(...)
		test_time = DateTime.new(2001,2,3,1,2,3, '-05:00')
		Timecop.freeze(test_time) do
			during_date = DateTime.new(2001,2,3,1,2,3, '-05:00')
			during = Post.new(:title=>'during', :draft=>false, :posted_at=>during_date, :kudos=> 1)
					# Feb 3
			during.save!
			during2_date = DateTime.new(2001,2,1,1,2,3, '-05:00')
			during2 = Post.new(:title=>'during2', :draft=>false, :posted_at=>during2_date, :kudos=> 1)
					# Feb 1
			during2.save!
			
			# this post is IN the month but scheduled for a date in the future (past test_time)
			future_date = DateTime.new(2001,2,4,1,2,3, '-05:00')
			future = Post.new(:title=>'future', :draft=>false, :posted_at=>future_date, :kudos=> 2)
					# Feb 4
			future.save!
			
			m = Month.new(test_time)
			assert_equal 2, m.kudos_count, "unexpected number of kudos: #{m.kudos_count}"
		end
	end

	test "previous" do 
		test_time = DateTime.new(2001,2,3,1,2,3, '-05:00')
		m = Month.new(test_time)
		p = m.previous()
		assert_equal 1, p.start.month, "previous month was unexpected: #{p.start.month}"
	end

	test "next" do 
		test_time = DateTime.new(2001,2,3,1,2,3, '-05:00')
		m = Month.new(test_time)
		n = m.next()
		assert_equal 3, n.start.month, "next month was unexpected: #{n.start.month}"
	end

end
