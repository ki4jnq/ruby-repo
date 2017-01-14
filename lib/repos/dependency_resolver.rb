module Repos
  class DependencyResolver
    def initialize(map:)
      # TODO: Infer this from the query.
      self.map = map
      self.objects = {}

      #resolve initial
    end

    def resolved
      self.objects
    end

    #protected
    attr_accessor :objects, :map

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

        # Set the dependencies for all items in this row.
        in_row.each_with_index do |pair, idx|
          key, val = *pair

          in_row[idx..-1].each do |other_key, other_val|
            # Wire the dependencies both ways.
            next if other_key == key # Don't check for self-relations.
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

      if rel == :belongs_to || rel == :has_one
        assign objects[rkey], to: objects[lkey], as: rname.singularize, singular: true
      elsif rel == :has_many
        assign objects[rkey], to: objects[lkey], as: rname
      end
    end

    def assign(object, to:, as:, singular: false)
      if singular
        to.send "#{as}=", object
      else
        to.send "#{as}=", [] if to.send(as).nil?
        to.send(as) << object
      end
    end

    def key_for(data, table:)
      # If the PK field is not present, assume every record to be unique.
      # TODO: Should assume the PK field to be 'id'
      table.to_s + '/' + data.fetch("#{table}_id".to_sym, rand(1_000_000_000_000)).to_s
    end

    def entity_for(data, table:)
      map[table].new.tap do |entity|
        data.map do |k, v|
          attr = k.to_s.split('_', 2).last + "="
          entity.send attr, v
        end
      end
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

