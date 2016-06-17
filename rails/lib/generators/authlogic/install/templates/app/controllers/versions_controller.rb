# Paper Trail versions
class VersionsController < ApplicationController
  before_action :require_user
  before_action :load_parent
  load_and_authorize_resource class: 'PaperTrail::Version'

  # GET /versions
  def index
    @search = VersionSearchForm.new(params[:q])
    @versions = @search.apply(versions: @versions) if @search.valid?

    # TODO: exception when linking to a deleted model
    respond_to do |format|
      format.html { # index.html.erb
        @versions = @versions.sorted.page(params[:page])
      }
      format.json {
        render json: @versions
      }
      format.xls { # index.xls.erb
        set_filename
      }
    end
  end

  # GET /versions/1
  def show
    respond_to do |format|
      format.json {
        render json: @version
      }
    end
  end

  def revert
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => "Undid #{@version.event}. #{redo_link}"
  end

  private

  def redo_link
    link_name = params[:redo] == "true" ? "undo" : "redo"
    view_context.link_to icon('repeat', link_name.titleize),
                         revert_version_path(@version.next, redo: !params[:redo]),
                         method: :post
  end

  # Load just Versions belonging to the routed model
  def load_parent
    @parent = User.friendly.find(params[:user_id]) if params[:user_id]
    @versions = @parent.versions if @parent
  end
end
