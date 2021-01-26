# frozen_string_literal: true

RSpec.describe 'scope for has_many' do
  subject(:good_comments) do
    Post.all.extend(good_comments_module).first.good_comments
  end

  let(:good_comments_module) do
    Module.new do
      include AssociatedScope

      associated_scope :good_comments, -> { where(body: 'good') }, source: :comments
      associated_scope :good_admin_comments, -> { where(body: 'good') }, source: :admin_comments
    end
  end

  let(:post) { create(:post) }
  let(:good_comment) { create(:comment, post: post, body: 'good') }
  let(:bad_comment) { create(:comment, post: post, body: 'bad') }

  before do
    good_comment
    bad_comment
  end

  it 'filter using associated scope' do
    expect(Post.first.comments).to match([good_comment, bad_comment])
    # expect(good_comments).to be_loaded
    expect(good_comments.size).to eq(1)
    expect(good_comments.first).to eq(good_comment)
  end

  context 'with preload' do
    subject(:good_comments) do
      Post.all.extend(good_comments_module).preload(:good_comments).first.good_comments
    end

    it 'filter using associated scope' do
      expect(good_comments).to be_loaded
      expect(good_comments.size).to eq(1)
      expect(good_comments.first).to eq(good_comment)
    end
  end

  context 'when association scope present' do
    subject(:good_admin_comments) do
      Post.all.extend(good_comments_module).first.good_admin_comments
    end

    let(:admin) { create(:user, name: 'admin') }
    let(:good_admin_comment) { create(:comment, post: post, user: admin, body: 'good') }
    let(:bad_admin_comment) { create(:comment, post: post, user: admin, body: 'bad') }

    before do
      good_admin_comment
      bad_admin_comment
    end

    it 'preserves scope from model' do
      expect(Post.first.admin_comments).to match([good_admin_comment, bad_admin_comment])
      expect(good_admin_comments.size).to eq(1)
      expect(good_admin_comments.first).to eq(good_admin_comment)
    end

    context 'with preload' do
      subject(:good_admin_comments) do
        Post.all.extend(good_comments_module).preload(:good_admin_comments).first.good_admin_comments
      end

      it 'preserves scope from model' do
        expect(Post.first.admin_comments).to match([good_admin_comment, bad_admin_comment])
        expect(good_admin_comments).to be_loaded
        expect(good_admin_comments.size).to eq(1)
        expect(good_admin_comments.first).to eq(good_admin_comment)
      end
    end

    context 'with model instance' do
      it 'has associated scopes' do
        post.extend(good_comments_module)

        expect(good_comments.size).to eq(2)
        expect(good_comments).to match([good_comment, good_admin_comment])

        expect(post.good_admin_comments.size).to eq(1)
        expect(post.good_admin_comments.first).to eq(good_admin_comment)
      end
    end
  end

end
