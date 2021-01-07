# frozen_string_literal: true

require "associated_scope/version"

module AssociatedScope
  module RelationExtension
    def load(&block)
      if loaded?
        super
      else
        myblock1 = myblock

        super(&myblock1)
      end
    end
  end

  def self.included(base)
    base.extend ParentClassMethods1
  end

  module ParentClassMethods1
    def extended(base)
      klass = base.respond_to?(:klass) ? base.klass : base.class
      associated_scope_args2 = associated_scope_args
      associated_scope_args.each do |name, args|
        source = args[:source]
        reflection = klass._reflect_on_association(source)
        raise AssociationNotFoundError.new(self, source) unless reflection

        reflection = reflection.dup
        parent_scope = reflection.scope
        associated_scope_arg = args[:scope]
        myscope = proc do
          instance_exec(&parent_scope).merge!(instance_exec(&associated_scope_arg))
        end
        reflection.define_singleton_method(:name) do
          name
        end
        reflection.define_singleton_method(:scope) do
          myscope
        end

        associated_scope_args[name].merge! reflection: reflection
      end

      associated_methods = @associated_methods
      myblock = proc do |record|
        record.define_singleton_method(:association) do |name|
          association = association_instance_get(name)
          return association unless association.nil?

          args = associated_scope_args2[name]
          return super(name) unless args

          reflection = args[:reflection]
          association = reflection.association_class.new(self, reflection)

          association_instance_set(name, association)
          association.association_scope
          association
        end

        associated_scope_args2.keys.each do |name|
          record.define_singleton_method(name) do
            association(name).reader
          end
        end

        record.instance_eval(&associated_methods)
      end

      if base.is_a?(ActiveRecord::Base)
        myblock.call(base)
      else
        base.extend RelationExtension
        base.define_singleton_method(:myblock) { myblock }
      end
    end

    def associated_scope_args
      @associated_scope_args ||= {}
    end

    def associated_scope(name, scope, source:)
      associated_scope_args[name] = { scope: scope, source: source }
    end

    def associated_methods(&block)
      @associated_methods = block
    end

    def associated_scope1(name, scope, source:)
      reflection = _reflect_on_association(source)
      raise AssociationNotFoundError.new(self, source) unless reflection

      reflection = reflection.dup
      parent_scope = reflection.scope
      myscope = proc { instance_exec(&parent_scope).merge!(instance_exec(&scope)) }
      reflection.define_singleton_method(:name) do
        name
      end
      reflection.define_singleton_method(:scope) do
        myscope
      end

      associated_scope_args[name] = { scope: scope, reflection: reflection }
      define_method(name) do
        association(name).reader
      end
    end
  end
end
