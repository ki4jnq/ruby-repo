module Repos
  class Base
    def self.entity_class_for(sym)
      ["Entities", sym.to_s].join('::').constantize
    end

    def initialize
    end

    def all
      to_array conn.all
    end

    def persist(resource)
      if resource.id
        conn.where(id: resource.id).update(resource.attributes)
      else
        conn.insert resource.attributes
      end
    end

    private
    def conn
      @conn ||= Sequel::Model.db[class_sym]
    end

    def query(*tables, &block)
      return conn if block.nil?
      tables = tables.empty? ? [table_name] : tables

      dsl = QueryDsl.new conn, tables
      dsl.instance_eval &block
      return dsl.set if tables.length > 1

      return to_array dsl.set if tables.length == 1

      dr = DependencyResolver.new map: tables.inject({}) { |m, table|
        m[table_name] = self.class.entity_class_for table_name.to_s.capitalize.singularize
        m
      }
      dr.resolve dsl.set
    end

    # def to_singular(dataset)
    #   entity_class.new dataset
    # end

    def to_array(dataset)
      dataset.map do |row|
        entity_class.new row
      end
    end

    def table_name
      class_sym
    end

    def class_sym
      @class_sym ||= class_name.downcase.pluralize.to_sym
    end

    def class_name
      @class_name ||= self.class.to_s.split('::').last
    end

    def entity_class
      # This should be set once per application run.
      @entity_class ||= self.class.entity_class_for class_name
    end
  end
end
