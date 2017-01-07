class DependencyResolver
  def initialize(repo, tables, initial)
    self.repo = repo
    self.tables = tables
    self.objects = {}
    self.dependencies = {}

    resolve initial
  end

  def resolved
  end

  protected
  attr_accessor :objects, :dependencies

  private

  def resolve(initial)
    # Step #1, parse the input.
    fields_by_table = tables.inject({}) do |memo, tname|
      memo[tname] = []
    end

    initial.first.each do |key, val|
      tables.each do |tname|
        next unless key.to_s.start_with? tname
        fields_by_table[tname] << key
      end
    end

    # Step #2, push everything into the 'objects' array and record
    # the dependencies as we go.
    initial.each do |row|
      fields_by_table.each do |tname, fields|
        objects[tname + fields[repo.send(:class_sym)]]
      end
    end
  end
end
