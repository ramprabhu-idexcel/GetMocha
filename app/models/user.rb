class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
<<<<<<< HEAD
         :recoverable, :rememberable, :validatable, :confirmable
         #~ :trackable,
=======
         :recoverable, :rememberable 
         #~ :trackable, :validatable
>>>>>>> 42acfc72f650d3420a33e5778abc4907a625ac2a

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :projects
  has_one :project
  has_many :project_users
  has_many :guest_users
  has_many :chats
  has_many :messages
  #~ has_many
end
