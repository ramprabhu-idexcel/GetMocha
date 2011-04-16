class ChatsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @projects=Project.user_active_projects(current_user.id)
  end
end
