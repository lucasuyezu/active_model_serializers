require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class Hal
        class CollectionTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @author.bio = nil
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')
            @first_post.comments = []
            @second_post.comments = []
            @first_post.blog = @blog
            @second_post.blog = nil
            @first_post.author = @author
            @second_post.author = @author
            @author.posts = [@first_post, @second_post]

            @serializer = ArraySerializer.new([@first_post, @second_post])
            @adapter = ActiveModel::Serializer::Adapter::Hal.new(@serializer)
            ActionController::Base.cache_store.clear
          end

          def test_include_multiple_posts
            expected = {
              _links: {
                self: { href: "/posts" },
                find: { href: "/posts{?id}", templated: true }
              },
              posts: [{
                _links: {
                  self: { href: "/posts/1" },
                  blog: { href: "/blogs/999" },
                  author: { href: "/authors/1" }
                },
                title: "Hello!!",
                body: "Hello, world!!"
              }, {
                _links: {
                  self: { href: "/posts/2" },
                  blog: { href: "/blogs/999" },
                  author: { href: "/authors/1" }
                },
                title: "New Post",
                body: "Body"
              }]
            }

            assert_equal(expected, @adapter.serializable_hash)
          end

          def test_limiting_fields
            @adapter = ActiveModel::Serializer::Adapter::Hal.new(@serializer, fields: ['title'])

            expected = {
              _links: {
                self: { href: "/posts" },
                find: { href: "/posts{?id}", templated: true }
              },
              posts: [{
                _links: {
                  self: { href: "/posts/1" },
                  blog: { href: "/blogs/999" },
                  author: { href: "/authors/1" }
                },
                title: "Hello!!"
              }, {
                _links: {
                  self: { href: "/posts/2" },
                  blog: { href: "/blogs/999" },
                  author: { href: "/authors/1" }
                },
                title: "New Post"
              }]
            }

            assert_equal(expected, @adapter.serializable_hash)
          end
        end
      end
    end
  end
end
