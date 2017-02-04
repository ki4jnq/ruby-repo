module Repos
  class Base
    def self.entity_class_for(sym)
      ["Entities", sym.to_s].join('::').constantize
    end

    def initialize
    end

    class << self
      def persisted_attributes(*args)
        unless args.empty?
          @persisted_attributes = args
        else
          @persisted_attributes || []
        end
      end
    end

    def all
      to_array conn.all
    end

    def persist(resource)
      if resource.id
        conn.where(id: resource.id).update(persisted_attrs_for(resource))
      else
        conn.insert persisted_attrs_for(resource)
      end
    end

    protected
    def persisted_attrs_for(resource)
      self.class.persisted_attributes.inject({}) do |attrs, attr|
        attrs[attr] = resource.public_send(attr); attrs
      end
    end

    def query(primary=table_name, *tables, &block)
      return conn if block.nil?

      # Prepend the primary table to the list of tables.
      tables.unshift primary

      # Evaluate the query block in the context of the DSL object.
      dsl = QueryDsl.new conn, tables
      dsl.instance_eval &block

      class_map = entity_map_for tables

      # If only one table is being queried for, do not perform dependency
      # resolution.
      # This may need to be removed to support self-relationships.
      return to_array dsl.set if class_map.length <= 1

      # Walk the result set and wire up the dependencies.
      DependencyResolver.new(get: primary, map: class_map).call(dsl.set)
    end

    private
    def conn
      @conn ||= Sequel::Model.db[class_sym]
    end

    # Builds a hash of table-names => entity-classes.
    def entity_map_for(tables)
      return { table_name => self.class.entity_class } if tables.empty?

      tables.inject({}) { |m, table|
        if table.is_a? Hash
          m.merge table
        elsif [Symbol, String].include? table.class
          m.merge table => self.class.entity_class_for(table.to_s.capitalize.singularize)
        else
          raise InvalidArgument.new "invalid argument to `query`"
        end
      }
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

    def entity_class_sym
      @entity_class_sym ||= class_sym # TODO: This is wrong
    end
  end
end
