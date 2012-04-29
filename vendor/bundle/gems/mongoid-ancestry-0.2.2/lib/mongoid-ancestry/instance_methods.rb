module Mongoid
  module Ancestry
    module InstanceMethods
      # Validate that the ancestors don't include itself
      def ancestry_exclude_self
        if ancestor_ids.include? id
          errors.add(:base, "#{self.class.name.humanize} cannot be a descendant of itself.")
        end
      end

      # Update descendants with new ancestry
      def update_descendants_with_new_ancestry
        # Skip this if callbacks are disabled
        unless ancestry_callbacks_disabled?
          # If node is valid, not a new record and ancestry was updated ...
          if changed.include?(self.base_class.ancestry_field.to_s) && !new_record? && valid?
            # ... for each descendant ...
            descendants.each do |descendant|
              # ... replace old ancestry with new ancestry
              descendant.without_ancestry_callbacks do
                for_replace = \
                  if read_attribute(self.class.ancestry_field).blank?
                    id.to_s
                  else
                    "#{read_attribute self.class.ancestry_field}/#{id}"
                  end
                new_ancestry = descendant.read_attribute(descendant.class.ancestry_field).gsub(/^#{self.child_ancestry}/, for_replace)
                descendant.update_attribute(self.base_class.ancestry_field, new_ancestry)
              end
            end
          end
        end
      end

      # Apply orphan strategy
      def apply_orphan_strategy
        # Skip this if callbacks are disabled
        unless ancestry_callbacks_disabled?
          # If this isn't a new record ...
          unless new_record?
            # ... make al children root if orphan strategy is rootify
            if self.base_class.orphan_strategy == :rootify
              descendants.each do |descendant|
                descendant.without_ancestry_callbacks do
                  val = \
                    unless descendant.ancestry == child_ancestry
                      descendant.read_attribute(descendant.class.ancestry_field).gsub(/^#{child_ancestry}\//, '')
                    end
                  descendant.update_attribute descendant.class.ancestry_field, val
                end
              end
              # ... destroy all descendants if orphan strategy is destroy
            elsif self.base_class.orphan_strategy == :destroy
              descendants.all.each do |descendant|
                descendant.without_ancestry_callbacks { descendant.destroy }
              end
              # ... throw an exception if it has children and orphan strategy is restrict
            elsif self.base_class.orphan_strategy == :restrict
              raise Error.new('Cannot delete record because it has descendants.') unless is_childless?
            end
          end
        end
      end

      # The ancestry value for this record's children
      def child_ancestry
        # New records cannot have children
        raise Error.new('No child ancestry for new record. Save record before performing tree operations.') if new_record?

        if self.send("#{self.base_class.ancestry_field}_was").blank?
          id.to_s
        else
          "#{self.send "#{self.base_class.ancestry_field}_was"}/#{id}"
        end
      end

      # Ancestors
      def ancestor_ids
        read_attribute(self.base_class.ancestry_field).to_s.split('/').map { |id| cast_primary_key(id) }
      end

      def ancestor_conditions
        { :_id.in => ancestor_ids }
      end

      def ancestors depth_options = {}
        self.base_class.scope_depth(depth_options, depth).where(ancestor_conditions)
      end

      def path_ids
        ancestor_ids + [id]
      end

      def path_conditions
        { :_id.in => path_ids }
      end

      def path depth_options = {}
        self.base_class.scope_depth(depth_options, depth).where(path_conditions)
      end

      def depth
        ancestor_ids.size
      end

      def cache_depth
        write_attribute self.base_class.depth_cache_field, depth
      end

      # Parent
      def parent= parent
        write_attribute(self.base_class.ancestry_field, parent.blank? ? nil : parent.child_ancestry)
      end

      def parent_id= parent_id
        self.parent = parent_id.blank? ? nil : self.base_class.find(parent_id)
      end

      def parent_id
        ancestor_ids.empty? ? nil : ancestor_ids.last
      end

      def parent
        parent_id.blank? ? nil : self.base_class.find(parent_id)
      end

      # Root
      def root_id
        ancestor_ids.empty? ? id : ancestor_ids.first
      end

      def root
        (root_id == id) ? self : self.base_class.find(root_id)
      end

      def is_root?
        read_attribute(self.base_class.ancestry_field).blank?
      end

      # Children
      def child_conditions
        {self.base_class.ancestry_field => child_ancestry}
      end

      def children
        self.base_class.where(child_conditions)
      end

      def child_ids
        children.only(:_id).map(&:id)
      end

      def has_children?
        self.children.present?
      end

      def is_childless?
        !has_children?
      end

      # Siblings
      def sibling_conditions
        {self.base_class.ancestry_field => read_attribute(self.base_class.ancestry_field)}
      end

      def siblings
        self.base_class.where sibling_conditions
      end

      def sibling_ids
        siblings.only(:_id).map(&:id)
      end

      def has_siblings?
        self.siblings.count > 1
      end

      def is_only_child?
        !has_siblings?
      end

      # Descendants
      def descendant_conditions
        [
          { self.base_class.ancestry_field => /^#{child_ancestry}\// },
          { self.base_class.ancestry_field => child_ancestry }
        ]
      end

      def descendants depth_options = {}
        self.base_class.scope_depth(depth_options, depth).any_of(descendant_conditions)
      end

      def descendant_ids depth_options = {}
        descendants(depth_options).only(:_id).map(&:id)
      end

      # Subtree
      def subtree_conditions
        [
          { :_id => id },
          { self.base_class.ancestry_field => /^#{child_ancestry}\// },
          { self.base_class.ancestry_field => child_ancestry }
        ]
      end

      def subtree depth_options = {}
        self.base_class.scope_depth(depth_options, depth).any_of(subtree_conditions)
      end

      def subtree_ids depth_options = {}
        subtree(depth_options).only(:_id).map(&:id)
      end

      # Callback disabling
      def without_ancestry_callbacks
        @disable_ancestry_callbacks = true
        yield
        @disable_ancestry_callbacks = false
      end

      def ancestry_callbacks_disabled?
        !!@disable_ancestry_callbacks
      end

      private

      def cast_primary_key(key)
        if primary_key_type == Integer
          key.to_i
        elsif primary_key_type == BSON::ObjectId && key =~ /[a-z0-9]{24}/
          BSON::ObjectId.convert(self, key)
        else
          key
        end
      end

      def primary_key_type
        @primary_key_type ||= self.base_class.fields['_id'].options[:type]
      end
    end
  end
end
