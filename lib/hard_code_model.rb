require "active_record"

def HardCodeModel(*attributes)
  struct = Struct.new(*attributes)
  
  class << struct
    def all
      @all || (create_all; @all)
    end

    def create(*values)
      @all ||= []
      @all << new(*values)
    end

    def find(id)
      find_by_id(id) || raise(ActiveRecord::RecordNotFound)
    end

    def find_by_id(id)
      all.detect { |ct| ct.id == id.to_i }
    end

    def first
      all.first
    end
  end

  struct
end

module ActiveRecord
  class Base
    def self.belongs_to_struct(association, options = {})
      with_id = association.to_s + "_id"
      klass = (options[:class_name] || association.to_s.camelize).constantize

      define_method association do
        id = self.send(with_id)
        id ? klass.find(id) : nil
      end

      define_method association.to_s + "=" do |value|
        self.send(with_id + "=", value && value.id)
      end
    end
  end
end

