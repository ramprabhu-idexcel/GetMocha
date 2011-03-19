class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    values.select{ | v | v.is_a?( Hash ) }.each{ | h | h.recursive_symbolize_keys! }
    self
  end
end

class Time
  def self.find_elapsed_time(time)
		diff=Time.now-time
		case diff
			when 0..59
				"#{pluralize(diff.to_i,"second")} ago"
			when 60..3599
				"#{pluralize((diff/60).to_i,"minute")} ago"  
			when 3600..86399
				"#{pluralize((diff/3600).to_i,"hour")} ago" 
      when 3600..86399
				"#{pluralize((diff/3600).to_i,"hour")} ago" 
      when 3600..86399
				"#{pluralize((diff/3600).to_i,"hour")} ago" 
      when 3600..86399
				"#{pluralize((diff/3600).to_i,"hour")} ago" 
		else
			time.strftime("%l:%M %p")
		end
	end
end
