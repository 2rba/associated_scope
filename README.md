# AssociatedScope

This gem allows to define ActiveRecord scope (relation) what can be eager loaded like model association

###WHY
To solve N+1 query issues.
Solving N+1 queries for custom relations might be a complicated task

###WHAT
Associated scope allow to define ActiveRecord associations as extention for an existing model associations.

```ruby
class Post < ApplicationRecord
  has_many :comments
end

module TopComments
  include AssociatedScope
  
  associated_scope :top_comments, -> { order('score DESC') }, source: :comments
end

# home.html.erb
<% Post.preload(:top_comments).extending(TopComments).each do |post| %>
  <% post.top_comments.each {...} %>
<% end %>
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'associated_scope'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install associated_scope

## Usage
define a module as:
```ruby
class TopComments
  include AssociatedScope
  
  associated_scope :top_comments, -> { order('score DESC') }, source: :comments
end
```

`associated_scope <new association name>, <scope as lambda>, source: <base association>`

extend relation with `.extending(<module>)`

#### Helper methods

Methods can be added to the target model as:
```ruby
class TopComments
  include AssociatedScope
  
  associated_scope :top_comments, -> { rated.order('score DESC') }, source: :comments
  
  associated_methods do
    def full_name
      "#{comment_author.first_name} #{comment_author.last_name}"
    end
  end
end

full_name = Post.recent.preload(:top_comments).extending(TopComments).first.full_name
```

Model instance can be extendend as well:
```ruby
post = Post.last
post.extend(TopComments)
full_name = post.full_name
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/2rba/associated_scope

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
