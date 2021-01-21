# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.string :title
    t.integer :user_id
    t.integer :category_id
  end
end

class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_many :comments
  has_many :admin_comments, ->{ joins(:user).where(users: {name: 'admin'}) }, class_name: '::Comment'
end

FactoryBot.define do
  factory :post do
    title { "Title" }
    user
    category
  end
end
