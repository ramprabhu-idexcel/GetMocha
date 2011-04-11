class Project < ActiveRecord::Base
	Message_email="@#{APP_CONFIG[:message_email]}"
	Task_email="@#{APP_CONFIG[:task_email]}"
  has_many :task_lists
	has_many :tasks, :through=>:task_lists
	has_many :project_users
	has_many :project_guests
	has_many :users, :through=> :project_users
  has_many :guests,:through=>:project_guests,:source => :user
	has_many :activities, :through => :messages, :dependent=>:destroy
	has_many :messages
	has_many :comments#, :through=>:activities
	has_many :custom_emails
	has_many :chats
	has_many :invitations
  belongs_to :owner,:class_name=>"User"
	attr_accessible :name,:status,:message_email_id,:task_email_id,:is_public,:user_id
	validates :name, :presence   => true
	validates :name, :length     => { :within => 4..40, :message=>"Please enter a project name with more than 3 characters and less than 20 characters" }
	after_create :create_email_ids
  #~ named_scope :verify_project,:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users

  def self.user_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND project_users.status=?',user_id,true],:include=>:project_users)
  end
	
	def self.user_active_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND projects.status!=? AND project_users.status=?',user_id,3,true],:include=>:project_users)
  end
	
	def self.user_completed_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND projects.status=? AND project_users.status=?',user_id,3,true],:include=>:project_users)
  end
  def  create_email_ids
		self.update_attributes(:status=>ProjectStatus::ACTIVE, :message_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Message_email, :task_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Task_email)
	end
	def is_member?(user_id)
		project_users.is_project_member?(user_id)
	end
		def has_custom_message_id?
		custom_emails.find_by_custom_type("Message").present?
	end
	
	def has_custom_task_id?
		custom_emails.find_by_custom_type("Task").present?
	end

  def project_unread_message(user_id)
    activities.where('activities.user_id=? AND is_read=? AND is_delete=?',user_id,false,false)
  end

  def project_unread_message_count(user_id)
    project_unread_message(user_id).count
  end
	def project_member?(user_id)
    project_guests.find_by_guest_id_and_status(user_id,true).present? || project_users.find_by_user_id_and_status(user_id,true).present?
  end
	def is_a_guest?(user_id)
    guest_object(user_id).present?
  end
	def guest_object(user_id)
    project_guests.find_by_guest_id(user_id)
  end
	def all_active_projects
    find(:all,:conditions=>['projects.status!=? AND project_users.status=?',ProjectStatus::COMPLETED,true],:include=>:project_users)
  end
  def all_completed_projects
    find(:all,:conditions=>['projects.status=? AND project_users.status=?',ProjectStatus::COMPLETED,true],:include=>:project_users)
  end
		def invite_people_settings
		@invite=Invitation.new(:project_id=>params[:project_id], :name=>params[:name], :email=>params[:email], :message=>params[:message])
		@invite.save
		@project=Project.find(params[:project_id])
		if @invite.valid?
			ProjectMailer.delay.invite_people(current_user,@invite)
			render :nothing=>true
		else
			errors=[]
			if params[:email].blank?
				errors<<"Please enter email address"
			elsif	@invite.errors[:email][0]=="is too short (minimum is 6 characters)"
				errors<<"Please enter email minimum 6 characters"
			elsif @invite.errors[:email][0]=="is invalid"
				errors<<"Please enter valid email address"
			end
			render :update do |page|
				page.alert errors
			end
		end
	end
  def join_project
		@invite=Invitation.find_by_invitation_code(params[:invitation_code])
		@user=User.find_by_email(@invite.email)
    project=@invite.project
		if @user && @user.is_guest == false
      project.guest_object(@user.id).delete if project.is_a_guest?(@user.id)
			#~ @project_user=ProjectUser.new(:project_id=>@invite.project_id, :user_id=>@user.id, :status=>true)
			#~ @project_user.save
      @user.guest_update_message(@invite.project_id)
			@invite.update_attributes(:invitation_code=>nil, :status=>true)
			redirect_to "/"
		else
			
      project.guest_object(@user.id).delete if project.is_a_guest?(@user.id)
			@user.guest_update_message(@invite.project_id)
			@invite.update_attributes(:invitation_code=>nil)
			redirect_to new_user_registration_path
		end
  end
	def find_project_name
    @project=Project.find_by_id(params[:project_id]) if params[:project_id]
    session[:project_name]=@project.name if @project
    session[:project_selected]=@project.id if @project
  end
	def file_download_from_email
		attachment=Attachment.find(params[:id])
		if RAILS_ENV=="development"
		send_file "#{RAILS_ROOT}/public"+attachment.public_filename
		else
			s3_connect
			s3_file=S3Object.find(attachment.public_filename.split("/#{S3_CONFIG[:bucket_name]}/")[1],"#{S3_CONFIG[:bucket_name]}")
			send_data(s3_file.value,:url_based_filename=>true,:filename=>attachment.filename,:type=>attachment.content_type)			
		end		
	end
	def self.verify_project(current_user)
		find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
	end	
  def all_task_ids
    tasks.map(&:id)
  end
  def team_members
    User.project_team_members(self.id)
  end
  def members_list
    users=[]
    team_members.collect{|user| users<<{:id=>user.id,:name=>user.full_name}}
    users
  end
	def self.p_count_active
		find(:all, :conditions=>['status=?',true])
  end
	def self.p_count_completed
		find(:all, :conditions=>['status=?',false])
	end	
	def self.check_project_users(current_user)
		find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
	end	
end
