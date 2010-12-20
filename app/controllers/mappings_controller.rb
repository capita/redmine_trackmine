class MappingsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :set_token

  def index
    @mappings = Mapping.all
  end

  def new
    @mapping = Mapping.new :estimations => { 1 => 1, 2 => 4, 3 => 10 },
                           :story_types => { 'feature' => 'Feature', 'bug' => 'Bug', 'chore' => 'Support' }
                                  
    @projects = Project.all
    @tracker_projects = Trackmine.projects
    @labels = [['..choose..','']]
  end
  
  def edit
    @mapping = Mapping.find params[:id]   
  end

  def create
    @mapping = Mapping.new params[:mapping].merge :estimations => params[:estimations],
                                                  :story_types => params[:story_types]
    
    @mapping.tracker_project_id = params[:tracker_project_id]
    @mapping.tracker_project_name = PivotalTracker::Project.find(params[:tracker_project_id].to_i).name 
    if @mapping.save
      flash[:notice] = 'Mapping was successfully added.'
      redirect_to :action => "index"
    else
      flash[:error] = "Can't map these projects."
      redirect_to :action => "new"
    end
  end
  
  def update
    @mapping = Mapping.find params[:id]
    if @mapping.update_attributes :estimations => params[:estimations],
                                  :story_types => params[:story_types]

      flash[:notice] = 'Updated successfully.'
      redirect_to :action => "index"
    else
      flash[:error] = "Can't save that configuration."
      redirect_to :action => "new"
    end
  end

  def destroy
    @mapping = Mapping.find params[:id]
    if @mapping.destroy
      flash[:notice] = 'Mapping removed.'
    else
      flash[:error] = "Mapping could not be removed."
    end
    redirect_to :action => "index", :project_id => @project    
  end

  def xhr_labels
  	@labels = Trackmine.project_labels(params[:id].to_i)
  	render :partial => 'xhr_labels', :layout => false
  end

  private

  def set_token
    Trackmine.set_token(User.current.mail)
  end
 end
