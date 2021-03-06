class LinksController < ApplicationController
  before_action :set_link, only: [:show, :edit, :update, :destroy,
                                  :upvote, :downvote]
  include ApplicationHelper
  include UrlHelper

  # GET /links
  # GET /links.json
  def index
    #sort links according to their vote tally, big to small
    @links = Link.all.sort_by{ |link| -1 * link.vote_tally }
  end

  # GET /links/1
  # GET /links/1.json
  def show
    @comment = @link.comments.build
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = current_user.links.build(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to links_path, notice: 'Link was successfully created.' }
        format.json { render :index, status: :created, location: @link }
      else
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to @link, notice: 'Link was successfully updated.' }
        format.json { render :show, status: :ok, location: @link }
      else
        format.html { render :edit }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #PUT /links/:id/upvote
  def upvote
    if user_signed_in?
      @link.liked_by current_user
      redirect_to :back
    else
      redirect_to :back, alert: "Please sign in to upvote a link"
    end
  end


  #PUT /links/:id/downvote
  def downvote
    if user_signed_in?
      @link.disliked_by current_user
      redirect_to :back
    else
      redirect_to :back, alert: "Please sign in to upvote a link"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params.require(:link).permit(:title, :address, :description, :user_id)
    end
end
