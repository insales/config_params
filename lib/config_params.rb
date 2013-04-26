module ConfigParams
  private
    def config_param(setter, *args) # getter = setter, options = {}
      options = args.last.is_a?(::Hash) ? args.pop : {}
      getter  = args[0] || setter
      setter_visibility = options[:setter_visibility] || :private
      getter_visibility = options[:getter_visibility] || :private
      instance_eval <<-RUBY, __FILE__, __LINE__ + 1
        #{setter_visibility}                                                          # private
          def #{setter}(*args, &block)                                                #   def layout(*args, &block)
            _define_config_getter :#{getter}, :#{getter_visibility}, *args, &block    #     _define_config_getter :_layout, :private, *args, &block
          end                                                                         #   end
      RUBY
      send setter, nil
    end

    def _define_config_getter(name, visibility, *args, &block)
      arg = block_given? ? block : args[0]
      method_body = case arg
      when Proc
        arg
      when Symbol
        eval "-> { #{arg} }"
      else
        -> { arg }
      end
      define_method name, method_body
      class_eval "#{visibility} :#{name}"
    end
end
