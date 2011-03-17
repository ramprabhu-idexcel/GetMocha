module MessagesHelper

	def unread_message_count()
		current_user.activities.find(:all,:conditions=>['is_read = 0']).count
	end
	
	def starred_message_count()
		current_user.activities.find(:all,:conditions=>['is_starred = 1']).count
	end
	
	def unread_project_message_count(project)
		project=Project.find_by_id(project)
		messages=project.messages
		unread=[]
		messages.each do |message|
			unread << message.activities.find(:first,:conditions=>['user_id=1 && is_read=0'])
		end
		unread.count
	end
	


end
