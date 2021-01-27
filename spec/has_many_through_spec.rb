# frozen_string_literal: true

RSpec.describe 'scope for has_many through' do
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
    expect(first_category.comments).not_to be_loaded
  end

  context 'with preload' do
    subject(:first_category) { Category.all.extend(good_comments_module).preload(:good_comments).first }

    it 'preload associated scope' do
      expect(first_category.good_comments).to be_loaded
      expect(first_category.good_comments).to match([good_comment])
      expect(first_category.comments).not_to be_loaded
    end
  end


  context 'when parent scope present' do
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
      expect(first_category.approved_comments).not_to be_loaded
      expect(first_category.approved_comments).to match([good_approved_comment, bad_approved_comment])
      expect(Category.first.approved_comments).to match([good_approved_comment, bad_approved_comment])
    end

    context 'with preload' do
      subject(:first_category) { Category.all.extend(good_comments_module).preload(:good_approved_comments).first } # .extend(good_comments_module)

      it 'preload associated scope' do
        expect(first_category.good_approved_comments).to be_loaded
        expect(first_category.good_approved_comments).to match([good_approved_comment])
        expect(first_category.approved_comments).not_to be_loaded
      end
    end
  end
end
