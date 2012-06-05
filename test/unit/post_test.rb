require 'test_helper'

class PostTest < ActiveSupport::TestCase
	# test "the truth" do
	#	 assert true
	# end
	def setup
		CONFIG['post_url_style'] = '/%Y/%m/%d/:slug'
		Post.all.each.destroy()
	end
	def teardown
		Post.all.each.destroy()
	end
	test "saving" do 
		p = Post.new()
		assert ! p.save(), "was able to save without a title" #shouldn't be able to save without a title
		p.title = 'my title'
		assert p.save!, "unable to save with just a title" # should be able to save with only a title
		assert_not_nil p.slug, "slug was nil after save with title" 
		assert p.draft, "post wasn't a draft by default" # it should default to being a draft.
		assert_nil p.posted_at, "post had a posted on by default" 
		assert_not_nil p.created_at
		assert_not_nil p.kudos
		assert_equal 0, p.kudos, "post did not start out with 0 kudos"
	end
	test "url creation" do
		p = Post.new({:title => 'this is a title'})
		assert_nil p.url # sanity check
		assert p.save!, "save failed with title"
		assert_nil p.url, "url was unexpectedly populated"
		assert_equal 'this-is-a-title', p.slug, "Slug wasn't correctly generated" 
		test_time = DateTime.new(2001,2,3,1,2,3)
		Timecop.freeze(test_time) do
			p.draft=false
			p.save()
			#assert_equal p.posted_at, test_time
			assert_equal p.posted_at.to_date, test_time.to_date
			# Unfortunately there's a bug in timecop
			# that doesn't seem to have been completely fixed
			# https://github.com/jtrupiano/timecop/issues/3
			# so we can't test the actual posted_at DateTime because it's sometimes an hour off.
			assert_equal "/2001/02/03/this-is-a-title", p.url, "unexpected url"
		end
		p.draft = false
	end
	test "get_boolean_fields" do 
		boolean_fields = Post.get_boolean_fields()
		%w(draft aside comments_enabled ).each do | field | 
		  assert boolean_fields.include? field
		end
	end
	test "previous next" do
		previous_date = DateTime.new(2001,2,3,1,2,3)
		p = Post.new({:title=>'previous', :draft=>false})
		p.save!
		p.posted_at = previous_date
		p.save

		assert_nil p.previous()
		assert_nil p.next()

		next_date = DateTime.new(2002,2,3,1,2,3)
		n = Post.new({:title=>'next', :draft=>false})
		n.save!
		n.posted_at = next_date
		n.save
		assert_not_nil n.previous()
		assert_equal 'previous', n.previous.title
		assert_nil n.next()
		assert_not_nil p.next()
		assert_equal 'next', p.next.title
		assert_nil p.previous()
		assert_equal p, p.next.previous, "the previous of next was not the same as the starting item"
		assert_equal n, n.previous.next, "the next of previous was not the same as the starting item"
	end
	test "external" do 
		#TODO when we enable future posting we need to make sure
		# that the post's date is <= now
		p = Post.new({:title => 'this is a title'})
		assert_equal false, p.external?, "draft post with no url returned true for external?"
		p.url = 'http://www.example.com/some/post'
		assert_equal false, p.external?, "draft post returned true for external?"
		p.draft = false
		assert_equal true, p.external?, "a viable post returned false for external?"
	end
	test "future" do 
		p = Post.new({:title => 'this is a title'})
		assert_equal false, p.future?, "A post with no posted_at was incorrectly marked as future" 
		p.posted_at = 1.day.ago
		assert_equal false, p.future?, "A post with a past posted_at was incorrectly marked as future" 
		p.posted_at = 1.day.from_now
		assert_equal true, p.future?, "A draft post with a valid posted_at was not marked as future" 
		p.draft = false
		assert_equal true, p.future?, "A published post with a valid posted_at was not marked as future" 
		
		# make sure unpublishing doesn't screw posted_at
		p.draft = true
		assert_equal true, p.future?, "A published post with a valid posted_at was not marked as future" 

	end

	test "permalinkable?" do
		# You can generate a permalink to a post even if it is a draft
		# Deciding if a user is allowed to view that post is another matter entirely
		p = Post.new({:title => 'this is a title'})
		assert_equal false, p.permalinkable?, "post without posted_at was permalinkable"
		p.posted_at = 1.day.from_now
		assert_equal true, p.permalinkable?, "draft post with future posted_at wasn't permalinkable"
		p.posted_at = 1.day.ago
		assert_equal true, p.permalinkable?, "draft post with posted_at wasn't permalinkable"
		p.draft = false
		assert_equal true, p.permalinkable?, "published post with posted_at wasn't permalinkable"
	end
end
