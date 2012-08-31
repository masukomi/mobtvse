# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    module Internal #:nodoc:

      # Defines the behaviour for BSON::ObjectId fields.
      class ObjectId
        include Serializable

        # Special case to serialize the object.
        #
        # @example Convert to a selection.
        #   field.selection(object)
        #
        # @param [ Object ] The object to convert.
        #
        # @return [ Object ] The converted object.
        #
        # @since 2.4.0
        def selection(object)
          return object if object.is_a?(::Hash)
          serialize(object)
        end

        # Serialize the object from the type defined in the model to a MongoDB
        # compatible object to store.
        #
        # @example Serialize the field.
        #   field.serialize(object)
        #
        # @param [ Object ] object The object to cast.
        #
        # @return [ BSON::ObjectId ] The converted object id.
        #
        # @since 2.1.0
        def serialize(object)
          if object.is_a?(::String)
            BSON::ObjectId.from_string(object) unless object.blank?
          else
            object
          end
        end
      end
    end
  end
end
