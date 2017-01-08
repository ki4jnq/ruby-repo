module Repos
  class DependencyResolver
    def initialize(tables, initial)
      # TODO: Infer this from the query.
      self.tables = tables
      self.objects = {}
      self.dependencies = {}

      resolve initial
    end

    def tree
      [self.objects, self.dependencies]
    end

    def resolve_for(table:, map:)
      p objects
      p map
      p dependencies
      objects.fetch(table) do
        raise "Couldn't find table \"#{table}\" in object list"
      end.map do |key, val|
        klass = map[key]
        entity = klass.new val
        other_klass = map[key]
        add_dependencies! key, entity, map
      end
    end

    protected
    attr_accessor :objects, :dependencies, :tables

    private
    def add_dependencies!(key, entity, klass)
      dependencies.fetch(key, {}).each do |dep_table, deps|
        deps.each do |dep_key|
          entity.public_send "#{dep_table}=", 'notdoneyet'
        end
      end
    end

    def resolve(initial)
      # Step #1, parse the input.

      # Returns an object who's keys are table names and whos
      # values are are empty arrays.
      table_fields = tables.inject({}) { |memo, tname| memo[tname] = []; memo }

      # Fill in the the empty arrays with field names by table.
      initial.first.each do |key, val|
        tables.each do |tname|
          # TODO: This is looping too many times.
          next unless key.to_s.start_with? tname.to_s
          table_fields[tname] << key
        end
      end

      # Step #2, build all of the objects

      # Push everything into the 'objects' array and record
      # the dependencies as we go.
      initial.each do |row|
        in_row = []

        # Read a single row and store the results, by table, in `in_row`.
        table_fields.each do |tname, fields|
          data = data_in row, fields: table_fields[tname]
          key = key_for data, table: tname
          #entity = entity_for data, table: tname

          save_object key, data
          in_row << [key, data]
        end

        # Record the dependencies for all items in this row of data.
        in_row.each_with_index do |pair, idx|
          key, val = *pair

          in_row[idx..-1].each do |other_key, other_val|
            # Wire the dependencies both ways.
            check_deps key, val, other_key, other_val
            check_deps other_key, other_val, key, val
          end
        end
      end
    end

    def check_deps(lkey, left, rkey, right)
      lname, rname = [lkey, rkey].map { |key| key.first }
      rel = Schema.relations.fetch(lname.to_sym, {})[rname.to_sym]

      puts "No relation for #{lname}-#{rname}" unless rel
      return unless rel

      if rel == :belongs_to
        # If the left side belongs to the right side.
        dependencies[rkey][lname] = lkey
      elsif rel == :has_many
        # if the right side belongs to the left side.
        dependencies[lkey] ||= {}
        dependencies[lkey][rname] ||= []
        dependencies[lkey][rname] << rkey
      elsif rel == :has_one
        # if the right side belongs to the left side.
        # TODO
      else
        raise "Unrecognized relationship \"#{rel}\" for #{lname}-#{rname}"
      end
    end

    def key_for(data, table:)
      # If the PK field is not present, assume every record to be unique.
      # TODO: Shouldn't assume the PK field to be 'id'
      p data
      [table.to_s, data.fetch("#{table}_id".to_sym, rand(1_000_000_000_000)).to_s]
    end

    def entity_for(data, table:)
      # TODO: Return an entity object (?)
      data
    end

    def data_in(row, fields:)
      p row
      fields.inject({}) do |m, k|
        v = row[k]
        m[k] = v if v
        m
      end
    end

    def lookup(key)
      objects.fetch(key.first, {})[key.last]
    end

    def save_object(key, data)
      objects[key.first] ||= {}
      objects[key.first][key.last] = data
    end
  end
end

