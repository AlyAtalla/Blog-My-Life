require 'fileutils'

class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy toggle_visibility ]
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
      # when viewing a specific user's posts, only show private posts to the owner or super-user
      unless current_user && (current_user.id == params[:user_id].to_i || current_user.email == 'aly@gmail.com')
        scope = scope.where(public: true)
      end
    else
      # general feed: show public posts, plus the current user's own posts
      if current_user
        scope = scope.where('posts.public = ? OR posts.user_id = ?', true, current_user.id)
      else
        scope = scope.where(public: true)
      end
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
    # prevent non-authorized viewing of private posts
    unless @post.public? || (current_user && (current_user == @post.user || current_user.email == 'aly@gmail.com'))
      redirect_to posts_path, alert: 'This post is private.' and return
    end
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
    uploaded = params.dig(:post, :image)
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        if uploaded
          dir = Rails.root.join('public', 'uploads', 'posts')
          FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
          filename = "post_#{@post.id}_#{Time.now.to_i}#{File.extname(uploaded.original_filename)}"
          path = dir.join(filename)
          File.open(path, 'wb') { |f| f.write(uploaded.read) }
          @post.update(image_url: "/uploads/posts/#{filename}")
        end

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
    uploaded = params.dig(:post, :image)

    respond_to do |format|
      if @post.update(post_params)
        if uploaded
          dir = Rails.root.join('public', 'uploads', 'posts')
          FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
          filename = "post_#{@post.id}_#{Time.now.to_i}#{File.extname(uploaded.original_filename)}"
          path = dir.join(filename)
          File.open(path, 'wb') { |f| f.write(uploaded.read) }
          @post.update(image_url: "/uploads/posts/#{filename}")
        end

        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /posts/:id/toggle_visibility
  def toggle_visibility
    unless current_user && current_user == @post.user
      redirect_to @post, alert: 'Only the post owner can change visibility.' and return
    end

    @post.update(public: !@post.public?)
    respond_to do |format|
      format.html { redirect_to @post, notice: "Post visibility updated." }
      format.json { render json: { id: @post.id, public: @post.public } }
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
    params.require(:post).permit(:title, :body, :user_id, :image_url, :public)
    end

    def authorize_user!
      # allow the site super-user (aly@gmail.com) to edit/delete any post
      return if current_user && current_user.email == 'aly@gmail.com'
      unless @post.user == current_user
        redirect_to @post, alert: 'You are not authorized to edit this post.'
      end
    end
end
