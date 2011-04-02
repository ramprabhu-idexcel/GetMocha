module ApplicationHelper

 def time_zone_select
    @time_zone=["(GMT-11:00) Midway","(GMT-10:00) Hawaii Standard Time","(GMT-09:30) Marquesas","(GMT-09:00) Alaska Standard Time","(GMT-09:00) Alaska Daylight Time","(GMT-08:00) Pacific Standard Time","(GMT-07:00) Pacific Daylight Time","(GMT-07:00) Mountain Standard Time","(GMT-06:00) Mountain Daylight Time","(GMT-06:00) Belize","(GMT-06:00) Costa Rica","(GMT-06:00) Central Standard Time","(GMT-05:00) Central Daylight Time","(GMT-05:00) Eastern Standard Time","(GMT-04:00) Eastern Daylight Time","(GMT-04:00) Aruba","(GMT-04:00) Atlantic Time - Halifax","(GMT-04:00) La Paz","(GMT-04:00) Bermuda"," (GMT-03:30) Newfoundland Time - St. Johns","(GMT-03:00) Buenos Aires"," (GMT-03:00) Sao Paulo"," (GMT-02:00) South Georgia"," (GMT-01:00) Azores","(GMT+00:00) Reykjavik"," (GMT+00:00) Dublin"," (GMT+00:00) Lisbon","(GMT+00:00) London","(GMT+01:00) Amsterdam" ,"(GMT+01:00) Andorra" ,"(GMT+01:00) Central European Time - Belgrade" ,"(GMT+01:00) Berlin" ,"(GMT+01:00) Brussels" ,"(GMT+01:00) Budapest" ,"(GMT+01:00) Copenhagen" ,"(GMT+01:00) Luxembourg" ,"(GMT+01:00) Madrid" ,"(GMT+01:00) Monaco","(GMT+01:00) Oslo","(GMT+01:00) Paris" ,"(GMT+01:00) Central European Time - Prague" ,"(GMT+01:00) Rome" ,"(GMT+01:00) Stockholm" ,"(GMT+01:00) Vienna","(GMT+01:00) Warsaw","(GMT+01:00) Zurich" ,"(GMT+02:00) Cairo" ,"(GMT+02:00) Johannesburg","(GMT+02:00) Jerusalem","(GMT+02:00) Athens",
"(GMT+02:00) Helsinki","(GMT+02:00) Istanbul","(GMT+02:00) Kiev","(GMT+03:00) Nairobi","(GMT+03:00) Baghdad" ,"(GMT+03:00) Kuwait","(GMT+03:00) Qatar" ,"(GMT+03:00) Riyadh","(GMT+03:00) Moscow+00","(GMT+03:30) Tehran","(GMT+04:00) Dubai","(GMT+04:30) Kabul","(GMT+05:00) Maldives " ,"(GMT+05:30) India Standard Time " ,"(GMT+05:45) Katmandu" ,
"(GMT+06:00) Moscow+03 - Omsk, Novosibirsk ","(GMT+06:30) Rangoon","(GMT+07:00) Bangkok","(GMT+07:00) Jakarta" ,"(GMT+08:00) Hong Kong " ,"(GMT+08:00) Manila ","(GMT+08:00) China Time - Beijing" ,"(GMT+08:00) Singapore " ,"(GMT+08:00) Taipei","(GMT+08:00) Western Time - Perth","(GMT+09:00) Seoul","(GMT+09:00) Tokyo","(GMT+09:30) Central Time - Adelaide" ,"(GMT+10:00) Eastern Time - Brisbane","(GMT+10:00) Eastern Time - Melbourne, Sydney","(GMT+11:00) Noumea " ,"(GMT+11:30) Norfolk   ","(GMT+12:00) Auckland","(GMT+12:00) Fiji ","(GMT+13:00) Enderbury" ]		
	end
  def comment_button
    content_tag(:div, :class=>"comment-buttons") do
      link_to(content_tag(:span,"Add Comment"),"#",:class=>"blue-33 add_comment")+link_to("cancel","#",:class=>"cancel_comment")
    end
  end
  def clear_fix
    content_tag(:div,'',:class=>"clear-fix")
  end
  def find_elapsed_time(time)
		diff=Time.now-time
		case diff
			when 0..59
				"#{pluralize(diff.to_i,"second")} ago"
			when 60..3599
				"#{pluralize((diff/60).to_i,"minute")} ago"
			when 3600..86399
				"#{pluralize((diff/3600).to_i,"hour")} ago"
		else
			time_zone=find_time_zone
			t=(time+find_current_zone_difference(time_zone)).strftime("%l:%M %p")
		end
	end
	def title(cn,an)

		if cn=="messages" && an=="index"
			return "Messages | Mocha"
		elsif cn=="home" && an=="index"
			return "Home | Mocha"
		elsif cn=="home" && an=="faq"
			return "Frequently Asked Questions | Mocha"
		elsif cn=="registrations" && an=="new"
			return "Signup | Mocha"
		elsif cn=="sessions" && an=="new"
			return "Login | Mocha"
		elsif cn=="home" && an=="terms"
			return "Terms of Use | Mocha"
		elsif cn=="home" && an=="privacy"
			return "Privacy Policy | Mocha"
		elsif cn=="home" && an=="help"
			return "Help | Mocha"
		elsif cn=="home" && an=="email"
			return "Email | Mocha"
		end
	end
end