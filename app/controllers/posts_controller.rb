class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_login, except: %i[index show]
  before_action :authorize_user!, only: %i[edit update destroy]

  # GET /posts or /posts.json
  def index
    per_page = 9
    page = params.fetch(:page, 1).to_i
    page = 1 if page < 1

    scope = Post.includes(:user, :likes, :comments).order(created_at: :desc)
    if params[:user_id].present?
      scope = scope.where(user_id: params[:user_id])
    end
    @total_count = scope.count
    @per_page = per_page
    @page = page
    @total_pages = (@total_count.to_f / @per_page).ceil
    @posts = scope.offset((@page - 1) * @per_page).limit(@per_page)
    Rails.logger.debug "[Pagination] page=#{@page} per_page=#{@per_page} total=#{@total_count} offset=#{(@page - 1) * @per_page} loaded_ids=#{@posts.pluck(:id)}"
  end

  # GET /posts/1 or /posts/1.json
  def show
    @comment = Comment.new
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
    @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
    params.require(:post).permit(:title, :body, :user_id, :image_url)
    end

    def authorize_user!
      unless @post.user == current_user
        redirect_to @post, alert: 'You are not authorized to edit this post.'
      end
    end
end
