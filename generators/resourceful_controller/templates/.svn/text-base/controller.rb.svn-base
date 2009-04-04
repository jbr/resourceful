class <%=class_name%>Controller < ApplicationController
  load_resource :<%=file_name.singularize%>, :by => :id
  
  def index
    @<%=file_name%> = <%=class_name.singularize%>.all
  end
  
  def show
  end
  
  def new
    @<%=file_name.singularize%> = <%=class_name.singularize%>.new
  end
  
  def edit
  end
  
  def update
    @success = @<%=file_name.singularize%>.update_attributes params[:<%=file_name.singularize%>]
    
    if @success
      redirect_to @<%=file_name.singularize%>
    else
      render :action => :edit
    end
  end
  
  def create
    @<%=file_name.singularize%> = <%=class_name.singularize%>.new params[:<%=file_name.singularize%>]
    @success = @<%=file_name.singularize%>.save
    
    if @success
      redirect_to @<%=file_name.singularize%>
    else
      render :action => :new
    end
  end
  
  def destroy
    @<%=file_name.singularize%>.destroy
    redirect_to <%=file_name%>_url
  end
end