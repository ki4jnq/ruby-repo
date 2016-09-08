module Schema
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    attr_accessor :table_name

    def define_table(name, &block)
      self.table_name = name
      Dsl.new(self).instance_eval &block
    end

    def attrs
      @_schema_attrs
    end

    def scoped_attrs
      @scoped_attrs ||= attrs.map { |e| "#{table_name}__#{e}___#{alias_for(e)}".to_sym }
    end

    def alias_for(attr)
      "#{table_name}_#{attr}"
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
      schema_attrs = klass.instance_variable_get :@_schema_attrs
      if schema_attrs.nil?
        schema_attrs = klass.instance_variable_set :@_schema_attrs, Set.new
      end
      schema_attrs
    end
  end

  class Dsl
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
