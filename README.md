# AssociatedScope
###Preloadable and reusable ActiveRecord scope

Associated scope allow to define ActiveRecord associations outside models as extention to an existing model associations.

```ruby
class Post < ApplicationRecord
  has_many :comments
end

module TopComments
  include AssociatedScope
  
  associated_scope :top_comments, -> { rated.order('score DESC') }, source: :comments
end

class HomeController < ApplicationController
  def index
    @posts = Post.recent.preload(:top_comments).extending(TopComments)
  end
end

# home.html.erb
<% @posts.each do |post| %>
  <% post.top_comments.each {...} %>
<% end %>
```

#### WHY
Solving N+1 queries for custom scopes might be a complicated task. Same time ActiveRecord has a built in preloader.

#### WHAT
AssociatedScope allow to define preloadable association with a scope.


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
  
  associated_scope :top_comments, -> { rated.order('score DESC') }, source: :comments
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
