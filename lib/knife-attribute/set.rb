module KnifeAttribute
  module Set
    def self.included(base)
      base.class_eval do
        include KnifeAttribute::CommonOptions

        def run
          check_arguments

          if config[:attribute_type]
            set_attribute(entity.send(attribute_type_map[config[:attribute_type].to_sym]))
          else
            set_attribute(entity.send(attribute_type_map[default_attribute_type]))
          end
        end

        private
          def check_arguments
            if entity_name.nil?
              show_usage
              ui.fatal("You must specify a #{entity_type.to_s} name")
              exit 1
            end

            if attribute.nil?
              show_usage
              ui.fatal('You must specify an attribute')
              exit 1
            end

            if value.nil?
              show_usage
              ui.fatal('You must specify a value')
              exit 1
            end

            check_type
          end

          def set_attribute(target)
            begin
              new_value = Chef::JSONCompat.from_json(value)
            rescue
              new_value = value
            end
            new_attribute = attribute.split('.').reverse.inject(new_value) { |result, key| { key => result } }
            Chef::Mixin::DeepMerge.hash_only_merge!(target, new_attribute)

            if entity.save
              ui.info("Successfully set #{entity_type.to_s} #{ui.color(entity_name, :cyan)} attribute #{ui.color(attribute, :cyan)} to: #{ui.color(new_value.inspect, :green)}")
            else
              ui.fatal("Failed updating #{entity_type.to_s} #{ui.color(entity_name, :magenta)} attribute #{ui.color(new_attribute, :magenta)}")
              exit 1
            end
          end
      end
    end
  end
end
