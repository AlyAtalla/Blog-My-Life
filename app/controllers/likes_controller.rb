class LikesController < ApplicationController
  before_action :require_login
  before_action :set_post

  def create
    like = @post.likes.build(user: current_user)
    if like.save
      respond_to do |format|
        format.html { redirect_back fallback_location: @post, notice: 'Liked' }
        format.json { render json: { id: like.id, likes_count: @post.likes.count, recent_actors: @post.recent_interactors(4).map { |u| { id: u.id, name: u.name, avatar_url: u.avatar_url } } }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: @post, alert: 'Unable to like' }
        format.json { render json: { error: 'Unable to like' }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # Allow destroy to work even if the frontend didn't supply a valid like id
    like = @post.likes.find_by(id: params[:id])
    # Fallback: try to find current user's like on this post
    like ||= @post.likes.find_by(user: current_user)

    if like.nil?
      respond_to do |format|
        format.html { redirect_back fallback_location: @post, alert: 'Like not found' }
        format.json { render json: { error: 'Like not found' }, status: :not_found }
      end
      return
    end

    if like.user == current_user
      like.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: @post, notice: 'Unliked' }
        format.json { render json: { likes_count: @post.likes.count, recent_actors: @post.recent_interactors(4).map { |u| { id: u.id, name: u.name, avatar_url: u.avatar_url } } }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: @post, alert: 'Not authorized' }
        format.json { render json: { error: 'Not authorized' }, status: :forbidden }
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
