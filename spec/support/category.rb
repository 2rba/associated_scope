# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :categories do |t|
    t.string :name
  end
end

class Category < ActiveRecord::Base
  has_many :posts
  has_many :comments, through: :posts
  has_many :approved_comments, ->{ where(approved: true) }, through: :posts, source: :comments
  # has_many :users, through: :comments
end

FactoryBot.define do
  factory :category do
    name { "Category" }
  end
end
