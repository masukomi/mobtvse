require 'test_helper'

class PostTest < ActiveSupport::TestCase
	# test "the truth" do
	#	 assert true
	# end
	def setup
		CONFIG['post_url_style'] = '/%Y/%m/%d/:slug'
	end
	def teardown
		Post.all.each.destroy();
	end
	test "saving" do 
		p = Post.new()
		assert ! p.save(), "was able to save without a title" #shouldn't be able to save without a title
		p.title = 'my title'
		assert p.save!, "unable to save with just a title" # should be able to save with only a title
		assert_not_nil p.slug, "slug was nil after save with title" 
		assert p.draft, "post wasn't a draft by default" # it should default to being a draft.
		assert_nil p.posted_on, "post had a posted on by default" 
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
		now = Date.new(2001,2,3)
		Timecop.freeze(now) do
			p.draft=false
			p.save()
			assert_equal p.posted_on, now
			assert_equal "/2001/02/03/this-is-a-title", p.url, "unexpected url"
		end
		p.draft = false
	end
end
