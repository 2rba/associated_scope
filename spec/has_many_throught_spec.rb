# frozen_string_literal: true

RSpec.describe 'scope for has_many' do
  subject(:first_category) { Category.all.extend(good_comments_module).first }

  let(:good_comments_module) do
    Module.new do
      include AssociatedScope

      associated_scope :good_comments, -> { where(body: 'good') }, source: :comments
      associated_scope :good_approved_comments, -> { where(body: 'good') }, source: :approved_comments
    end
  end

  let(:category) { create(:category) }
  let(:post) { create(:post, category: category) }
  let(:good_comment) { create(:comment, post: post, body: 'good') }
  let(:bad_comment) { create(:comment, post: post, body: 'bad') }

  before do
    good_comment
    bad_comment
  end

  it 'filter using associated scope' do
    expect(first_category.good_comments).to match([good_comment])
    expect(Category.first.comments).to match([good_comment, bad_comment])
  end

  context 'with preload' do
    subject(:first_category) { Category.all.extend(good_comments_module).preload(:good_comments).first }

    it 'filter using associated scope' do
      expect(first_category.good_comments).to be_loaded
      expect(first_category.good_comments).to match([good_comment])
    end
  end


  context 'when association scope present' do
    # subject(:good_approved_comments) do
    #   # Post.all.extend(good_comments_module).preload(:good_admin_comments).first.good_admin_comments
    #   first_category.approved_comments
    # end

    subject(:first_category) { Category.all.extend(good_comments_module).first }

    let(:good_approved_comment) { create(:comment, post: post, approved: true, body: 'good') }
    let(:bad_approved_comment) { create(:comment, post: post, approved: true, body: 'bad') }

    before do
      good_approved_comment
      bad_approved_comment
    end

    it 'preserves scope from model' do
      expect(first_category.good_approved_comments).not_to be_loaded
      expect(first_category.good_approved_comments).to match([good_approved_comment])
      expect(first_category.approved_comments).to match([good_approved_comment, bad_approved_comment])
      expect(Category.first.approved_comments).to match([good_approved_comment, bad_approved_comment])
    end

    context 'with preload' do
      subject(:first_category) { Category.all.extend(good_comments_module).preload(:good_approved_comments).first } # .extend(good_comments_module)

      it 'filter using associated scope with preload' do
        expect(first_category.good_approved_comments).to be_loaded
        expect(first_category.good_approved_comments).to match([good_approved_comment])
      end
    end

    # context 'with model instance' do
    #   it 'has associated scopes' do
    #     post.extend(good_comments_module)
    #
    #     expect(good_comments.size).to eq(2)
    #     expect(good_comments).to match([good_comment, good_admin_comment])
    #
    #     expect(post.good_admin_comments.size).to eq(1)
    #     expect(post.good_admin_comments.first).to eq(good_admin_comment)
    #   end
    # end
  end
end
