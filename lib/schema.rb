module Schema
  class << self
    attr_reader :tables

    def tables
      @tables ||= {}
    end

    def included(base)
      base.send :extend, ClassMethods
    end
  end

  module ClassMethods
    attr_accessor :table_name

    def define_table(name, &block)
      Schema.tables[name] = self

      self.table_name = name
      SchemaDsl.new(self).instance_eval &block
    end

    def attributes
      @schema_attrs
    end

    def scoped_attrs_with_alias
      @scoped_attrs_with_alias ||= attributes.map { |e| scope_attr_with_alias e }
    end

    def scope_attr_with_alias(attr)
      "#{scope_attr(attr)}___#{alias_for(attr)}".to_sym
    end

    def scope_attr(attr)
      "#{table_name}__#{attr}".to_sym
    end

    protected
    def alias_for(attr)
      "#{table_name}_#{attr}".to_sym
    end

    def class_sym
      @_class_sym ||= self.to_s.split('::').last.downcase.to_sym
    end
  end

  module Util
    def def_attr(klass, name, foreign_key: nil)
      attrs = get_attrs_for klass
      if attrs.include? name
        raise ArgumentError, "That attribute is already defined! #{name} for #{klass}"
      end

      attrs.add name
    end

    def get_attrs_for(klass)
      schema_attrs = klass.instance_variable_get :@schema_attrs
      if schema_attrs.nil?
        schema_attrs = klass.instance_variable_set :@schema_attrs, Set.new
      end
      schema_attrs
    end
  end

  class SchemaDsl
    include Util

    def initialize(klass)
      @klass = klass
    end

    def integer(name, opts={})
      def_attr @klass, name
    end

    def string(name, opts={})
      def_attr @klass, name
    end

    def boolean(name, opts={})
      def_attr @klass, name
    end

    def text(name, opts={})
      def_attr @klass, name
    end
  end
end
