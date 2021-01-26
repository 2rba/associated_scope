# frozen_string_literal: true

RSpec.describe 'scope for has_many' do
  context 'when relation does not exist' do
    subject(:good_comments) do
      Post.all.extend(bad_comments_module).first.good_comments
    end

    let(:bad_comments_module) do
      Module.new do
        include AssociatedScope

        associated_scope :good_comments, -> { where(body: 'good') }, source: :bad_comments
      end
    end

    it '' do
      expect { good_comments }.to raise_error(
        ActiveRecord::AssociationNotFoundError,
        "Association named 'bad_comments' was not found on Module; perhaps you misspelled it?"
      )
    end
  end
end
