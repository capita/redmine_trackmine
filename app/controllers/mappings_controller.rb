class MappingsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :set_token
  before_filter :set_mapping, only: [:edit, :update, :destroy]

  def index
    @mappings = Mapping.all
  end

  def new
    @mapping = Mapping.new
    @mapping.estimations = { 1 => 1, 2 => 4, 3 => 10 }
    @mapping.story_types = { 'feature' => 'Feature', 'bug' => 'Bug', 'chore' => 'Support' }
    @projects = Project.all
    @tracker_projects = Trackmine.projects
    @labels = [['..choose..','']]
  end

  def edit
  end

  def create
    @mapping = Mapping.new(mapping_params)

    @mapping.tracker_project_id = tracker_project_id
    @mapping.tracker_project_name = PivotalTracker::Project.find(tracker_project_id.to_i).name
    if @mapping.save
      flash[:notice] = 'Mapping was successfully added.'
      redirect_to action: 'index'
    else
      flash[:error] = "Can't map these projects. #{error_message}"
      redirect_to action: 'new'
    end
  end

  def update
    if @mapping.update_attributes(estimations: params[:estimations], story_types: params[:story_types])
      flash[:notice] = 'Updated successfully.'
      redirect_to action: 'index'
    else
      flash[:error] = "Can't save that configuration. #{error_message}"
      redirect_to action: 'new'
    end
  end

  def destroy
    if @mapping.destroy
      flash[:notice] = 'Mapping removed.'
    else
      flash[:error] = 'Mapping could not be removed.'
    end
    redirect_to action: 'index', project_id: @project
  end

  def update_labels
  	@labels = Trackmine.project_labels(tracker_project_id.to_i)
    respond_to do |format|
      format.json { render json: @labels }
    end
  end

  private

  def set_token
    Trackmine::Authentication.set_token(User.current.mail)
  end

  def mapping_params
    params.require(:mapping).merge(estimations: params[:estimations], story_types: params[:story_types])
  end

  def tracker_project_id
    params.require(:tracker_project_id)
  end

  def set_mapping
    @mapping = Mapping.find(params[:id])
  end

  def error_message
    @mapping.errors.full_messages.to_sentence
  end

 end
