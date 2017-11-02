require 'test_helper'
require 'populate'

class PopulateTest < ActiveSupport::TestCase

  # Setup dummy Post and Comment resources (before every test)
  # TODO: extract to test/setup_dummy_models_helper.rb ??
  setup do
    ActiveRecord::Schema.define do
      create_table :dummy_posts do |t|
        t.string :title
        t.text :content
        t.timestamps
      end

      create_table :dummy_comments do |t|
        t.string :content
        t.belongs_to :dummy_post
      end

      create_table :dummy_authors do |t|
        t.string :name
        t.belongs_to :dummy_post
      end
    end

    class ::DummyPost < ApplicationRecord
      has_many :dummy_comments
      has_one :dummy_author
    end

    class ::DummyComment < ApplicationRecord
      belongs_to :dummy_post, optional: true
    end

    class ::DummyAuthor < ApplicationRecord
      belongs_to :dummy_post, optional: true
      validates :name, presence: true
    end
  end

  # Cleanup dummy Post and Comment resources (after every test)
  teardown do
    ActiveRecord::Base.connection.drop_table :dummy_posts
    ActiveRecord::Base.connection.drop_table :dummy_comments
    Object.send :remove_const, :DummyPost
    Object.send :remove_const, :DummyComment
  end

  test "create model from attributes" do
    post_attributes = [
      { title: 'First Post', content: 'First' },
      { title: 'Second Post', content: 'Second' }
    ]

    post_attributes.each do |post_params|
      model = Populate.update_or_create DummyPost, post_params, by: :title
      assert model.persisted?
    end
  end

  test "update model from attributes" do
    p1 = { title: 'Post!', content: 'First' }
    p2 = { title: 'Post!', content: 'Second' }

    [p1, p2].each do |post_params|
      model = Populate.update_or_create DummyPost, post_params, by: :title
      assert model.persisted?
    end

    assert_equal 1, DummyPost.count
    assert_nil DummyPost.find_by content: p1[:content]
    assert_equal p2[:content], DummyPost.find_by(title: p1[:title]).content
  end

  test "create model with associated :belongs_to" do
    # Create a post
    post_params = { title: 'First Post', content: 'First content' }
    post = Populate.update_or_create DummyPost, post_params
    assert post.persisted?

    # Associate with Post by params
    comment_params = { content: 'First comment on first post', dummy_post: post_params.slice(:title) }
    comment = Populate.update_or_create DummyComment, comment_params, by: :title
    assert comment.persisted?

    # Associate with Post by :title String
    comment_params = { content: 'First comment on first post', dummy_post: post_params[:title] }
    comment = Populate.update_or_create DummyComment, comment_params, by: :title
    assert comment.persisted?

    assert_equal 1, DummyComment.count
    assert_equal 1, DummyPost.count
  end

  test "create model with associated :has_one" do
    # Create Associated model
    author_params = { name: 'R.A. Heinlein' }
    author = Populate.update_or_create DummyAuthor, author_params
    assert author.persisted?

    # Associate with Author by params
    post_params = { title: 'Post with Author', dummy_author: author_params }
    post = Populate.update_or_create DummyPost, post_params
    assert post.persisted?

    # Associate with Author by :name String
    post_params = { title: 'Post with Author', dummy_author: author_params[:name] }
    post = Populate.update_or_create DummyPost, post_params
    assert post.persisted?

    assert_equal 1, DummyAuthor.count
    assert_equal 1, DummyPost.count
  end

  # TODO: can we create the associated comments when creating the post?
  test "create model with associated :has_many" do
    # Create Associated models
    comment_params = [
      { content: 'First comment' },
      { content: 'Second comment' }
    ]
    comment_params.each do |params|
      comment = Populate.update_or_create DummyComment, params, by: :content
      assert comment.persisted?
    end

    # Associate with Comment by params
    post_params = {
      title: 'First Post',
      content: 'First content',
      dummy_comments: comment_params
    }
    model = Populate.update_or_create DummyPost, post_params, by: :title
    assert model.persisted?

    assert_equal 1, DummyPost.count
    assert_equal 2, DummyComment.count
  end

  # test "create model with associated :has_and_belongs_to_many" do
  # end

  test "outputs error message for invalid object" do
    assert_output(/Unable to create DummyAuthor/) do
      comment = Populate.update_or_create DummyAuthor, name: ''
      assert_not comment.persisted?
      assert comment.errors.any?
    end
  end

  test "outputs error message for missing associated object" do
    assert_output(/Unable to find DummyAuthor/) do
      post_params = { title: 'Post', dummy_author: 'George P. Burdell' }
      Populate.update_or_create DummyPost, post_params, by: :content
    end
  end
end
