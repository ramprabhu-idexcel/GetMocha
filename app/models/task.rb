class Task < ActiveRecord::Base
	belongs_to :user
	has_many :activities, :as => :resource, :dependent=>:destroy
	has_many :comments, :dependent=>:destroy
	belongs_to :task_list
		belongs_to :project
	belongs_to :guest
	attr_accessible :name,:notify,:due_date,:recipient,:description,:project_id,:user_id,:task_list_id
                    #:length     => { :within => 6..250 }
	validates :description , :length => { :within => 6..250 },
									:presence => true
validates :name, :presence   => true, :uniqueness =>true

def add_in_activity(to_users,assign,user)
	    to_users=to_users.split(',') unless to_users.is_a?(Array)
			assign=assign.split(',')
			p to_users
     # self.project.users.each do |user|
		# assign=
      activity=self.activities.create!(:user=>user, :is_subscribed=>true)
      #activity.update_attributes(:is_assigned=>(user.email==assign),:is_subscribed=>true) if user.id==self.user_id || to_users.include?(user.email)
    to_users.each do |email|
			email=email.lstrip
      if email.nil?
				p email
        u=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>email}],:include=>:secondary_emails)
        u= User.create(:email=>email,:is_guest=>true, :password=>Encrypt.default_password) unless u
				p u.inspect
        self.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>u.id) if self.project.is_member?(u.id) && u && u.id
				activity.update_attributes(:is_assigned=>true) if user.email==assign
        ProjectGuest.create(:guest_id=>u.id,:project_id=>self.project_id) if u && u.id && !self.project.project_member?(u.id)
      end
    end
  end
	
	def self.send_task_notification_to_team_members(user,to_users,task)
		@user=user
		@task=task
		to_users.each do |to_user|
			@to_user=to_user
		ProjectMailer.delay.task_notification(@user,@to_user,@task)
		end
	end
	
end
