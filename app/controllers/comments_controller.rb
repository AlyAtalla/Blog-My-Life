class CommentsController < ApplicationController
  before_action :require_login, only: [ :create, :destroy ]
  before_action :set_post
  before_action :set_comment, only: [ :destroy ]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.html { redirect_to @post, notice: "Comment posted." }
        format.json {
          render json: {
            id: @comment.id,
            body: @comment.body,
            user: { id: @comment.user.id, name: @comment.user.name, avatar_url: @comment.user.avatar_url },
            created_at: @comment.created_at,
            comments_count: @post.comments.count,
            recent_actors: @post.recent_interactors(4).map { |u| { id: u.id, name: u.name, avatar_url: u.avatar_url } }
          }, status: :created
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to @post, alert: "Could not post comment." }
        format.json { render json: { error: "Could not post comment" }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @comment.user == current_user || @post.user == current_user
      @comment.destroy
      redirect_to @post, notice: "Comment deleted."
    else
      redirect_to @post, alert: "Not authorized."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
