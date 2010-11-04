module ResourcefulLoader
  mattr_accessor :default_finder
  def self.included(klass)
    klass.module_eval do
      extend ClassMethods
    end
  end

  def element_id
    [self.class.name.underscore, to_param.blank?? "new" : to_param].join '_'
  end

  module ClassMethods
    def load_resource(resource_name, options = {})
      options.symbolize_keys!

      resource_name = resource_name.to_s.underscore.singularize
      param_name = options.delete(:by) || resource_name.foreign_key

      finder_method = options.delete(:method) ||
        ResourcefulLoader.default_finder ||
        :find_by_id
      
      if_nil = options.delete :if_nil

      method_name = "load_#{resource_name}"

      ivar_name = (options.delete(:as) || resource_name).to_s
      attr_accessor ivar_name

      while private_instance_methods.include? method_name
        method_name.sub! /(?:_([0-9]+))?$/ do |f|
          "_#{ f.blank? ? 1 : f.to_i + 1 }"
        end
      end

      define_method method_name do
        resource =
          if foreign_key = params[param_name]
            if block_given?
              yield foreign_key
            else
              resource_name.classify.constantize.
                send finder_method, foreign_key
            end
          end

        if resource.nil? && if_nil && !if_nil.to_proc.call(self)
          return false
        end

        send("#{ivar_name}=", resource) unless send(ivar_name)
      end

      private method_name

      before_filter method_name, options

    end
  end
end
