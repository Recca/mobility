# frozen_string_literal: true
module Mobility
  module Plugins
=begin

@see {Mobility::Plugins::ActiveRecord::Query}

=end
    module Query
      class << self
        def apply(attributes, option)
          if option
            include_query_module(attributes)
          end
        end

        private

        def include_query_module(attributes)
          if Loaded::ActiveRecord && attributes.model_class < ::ActiveRecord::Base
            require "mobility/plugins/active_record/query"
            ActiveRecord::Query.apply(attributes)
          elsif Loaded::Sequel && attributes.model_class < ::Sequel::Model
            require "mobility/plugins/sequel/query"
            Sequel::Query.apply(attributes)
          end
        end
      end
    end
  end
end
