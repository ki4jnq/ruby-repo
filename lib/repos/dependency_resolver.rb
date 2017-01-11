module Repos
  class DependencyResolver
    def initialize(map:)
      # TODO: Infer this from the query.
      self.map = map
      self.objects = {}
      self.dependencies = {}

      #resolve initial
    end

    def resolved
      self.objects
    end

    #protected
    attr_accessor :objects, :dependencies, :map

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

      puts "Tables to be queried"
      p tables

      # Step #2, build all of the objects

      # Push everything into the 'objects' array and record
      # the dependencies as we go.
      initial.each do |row|
        in_row = []

        # Read a single row and store the results, by table, in `in_row`.
        table_fields.each do |tname, fields|
          data = data_in row, fields: table_fields[tname]
          key = key_for data, table: tname
          entity = entity_for data, table: tname

          objects[key] ||= entity
          in_row << [key, entity]
        end

        puts "Data in row"
        p in_row

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

    private

    def check_deps(lkey, left, rkey, right)
      lname, rname = [lkey, rkey].map { |key| key.split('/').first }
      rel = Schema.relations.fetch(lname.to_sym, {})[rname.to_sym]

      puts "No relation for #{lname}-#{rname}" unless rel
      return unless rel

      if rel == :belongs_to
        # If the left side belongs to the right side.
        dependencies[rkey][lname] = objects[lkey]
        assign objects[lkey], to: objects[rkey], as: lname, singular: true
      elsif rel == :has_many
        # if the right side belongs to the left side.
        assign objects[rkey], to: objects[lkey], as: rname
      elsif rel == :has_one
        # if the right side belongs to the left side.
        # TODO
      else
        # wth?
        raise "Unrecognized relation ship \"#{rel}\" for #{lname}-#{rname}"
      end
    end

    def assign(object, to:, as:, singular: false)
      existing = to.send(as)
      if rel == :has_many
        to.send("#{as}=", []) if exising.nil?
        to.send(as) << object
      elsif rel == :has_one
        to.send("#{as}=", object)
      elsif rel == :belongs_to
      end
    end

    def key_for(data, table:)
      # If the PK field is not present, assume every record to be unique.
      # TODO: Should assume the PK field to be 'id'
      table.to_s + '/' + data.fetch("#{table}_id".to_sym, rand(1_000_000_000_000)).to_s
    end

    def entity_for(data, table:)
      map[table].new data
    end

    def data_in(row, fields:)
      fields.inject({}) do |m, k|
        v = row[k]
        m[k] = v if v
        m
      end
    end

    def tables
      map.keys
    end
  end
end

