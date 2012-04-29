class MongoidAncestry

  def self.with_model options = {}
    depth         = options.delete(:depth) || 0
    width         = options.delete(:width) || 0
    extra_columns = options.delete(:extra_columns)
    skip_ancestry = options.delete(:skip_ancestry)

    begin
      model = Class.new
      (class << model; self; end).send :define_method, :model_name do; Struct.new(:human, :underscore, :i18n_key).new 'TestNode', 'test_node', 'key'; end
      const_set 'TestNode', model
      TestNode.send(:include, Mongoid::Document)
      TestNode.send(:include, Mongoid::Ancestry) unless skip_ancestry

      extra_columns.each do |name, type|
        TestNode.send :field, name, :type => type.to_s.capitalize.constantize
      end unless extra_columns.nil?

      TestNode.has_ancestry options unless skip_ancestry

      if depth > 0
        yield TestNode, create_test_nodes(TestNode, depth, width)
      else
        yield TestNode
      end
    ensure
      remove_const "TestNode"
    end
  end

  def self.create_test_nodes model, depth, width, parent = nil
    unless depth == 0
      Array.new width do
        node = model.create!(:parent => parent)
        [node, create_test_nodes(model, depth - 1, width, node)]
      end
    else; []; end
  end
end
