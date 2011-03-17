module MessagesHelper

	def unread_message_count()
		current_user.activities.find(:all,:conditions=>['is_read = 0']).count
	end
	
	def starred_message_count()
		current_user.activities.find(:all,:conditions=>['is_starred = 1']).count
	end
	


end
