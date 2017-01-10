module Repos
  class QueryDsl
    attr_accessor :set

    def initialize(connection, tables)
      self.set = connection

      if tables.length > 1
        # If we are loading data from multiple tables, then we
        # need to scope the fields by there table names.
        self.set = set.select do
          Schema.scoped_fields_for tables: tables
        end
      end
    end

    def select(*tables) # TODO: Should be fields, not tables.
    end

    def where(conditions)
      final = {}
      conditions.each do |table_name, table_conditions|
        physical = Schema.tables[table_name]
        raise "No Physical model called #{table_name}" unless physical

        table_conditions.each do |field, condition|
          final[physical.scope_attr(field)] = condition
        end
      end
      self.set = set.where final
    end
    alias and where

    [:left_join, :join].each do |method_name|
      define_method method_name do |*args|
        self.set = set.public_send method_name, *args
      end
    end
  end
end
