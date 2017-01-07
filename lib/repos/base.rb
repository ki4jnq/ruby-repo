module Repos
  class Base
    def initialize
    end

    def all
      to_array conn.all
    end

    # private
    def conn
      @conn ||= Sequel::Model.db[class_sym]
    end

    def query(&block)
      return conn if block.nil?
      dsl = QueryDsl.new(conn)
      dsl.instance_eval(&block)
      to_array dsl.set
    end

    def to_singular(dataset)
      entity_class.new dataset
    end

    def to_array(dataset)
      dataset.map do |row|
        entity_class.new row
      end
    end

    def class_sym
      class_name.downcase.pluralize.to_sym
    end

    def class_name
      self.class.to_s.split('::').last
    end

    def entity_class
      # This should be set once per application run.
      @entity_class ||= ["Entities", class_name].join('::').constantize
    end
  end
end
