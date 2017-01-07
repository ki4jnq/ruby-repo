class QueryDsl
  attr_accessor :set

  def initialize(connection)
    self.set = connection
  end

  def select(*tables) # TODO: Should be fields, not tables.
    self.set = set.select do
      Schema.tables
        .select { |k, v| tables.include? k }
        .map { |name, physical| physical.scoped_attrs_with_alias }
        .inject(:|)
    end
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
    puts final
    self.set = set.where final
  end
  alias and where

  [:left_join, :join].each do |method_name|
    define_method method_name do |*args|
      self.set = set.public_send method_name, *args
    end
  end
end