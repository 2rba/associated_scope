# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :comments do |t|
    t.integer :post_id
    t.integer :user_id
    t.string :body
    t.boolean :approved
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post, inverse_of: :comments
  belongs_to :user
end

FactoryBot.define do
  factory :comment do
    body { "heya" }
    user
  end
end
