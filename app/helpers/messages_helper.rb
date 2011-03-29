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
			unread1=message.activities.find(:first,:conditions=>['user_id=? && is_read=?',current_user.id,false])
			unread<<unread1 if unread1
			end
		unread.count
	end
	


end
