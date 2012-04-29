require 'spec_helper'

describe MongoidAncestry do

  subject { MongoidAncestry }

  it "should have tree navigation" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      roots.each do |lvl0_node, lvl0_children|
        # Ancestors assertions
        lvl0_node.ancestor_ids.should eql([])
        lvl0_node.ancestors.to_a.should eql([])
        lvl0_node.path_ids.should eql([lvl0_node.id])
        lvl0_node.path.to_a.should eql([lvl0_node])
        lvl0_node.depth.should eql(0)
        # Parent assertions
        lvl0_node.parent_id.should be_nil
        lvl0_node.parent.should be_nil
        # Root assertions
        lvl0_node.root_id.should eql(lvl0_node.id)
        lvl0_node.root.should eql(lvl0_node)
        lvl0_node.is_root?.should be_true
        # Children assertions
        lvl0_node.child_ids.should eql(lvl0_children.map(&:first).map(&:id))
        lvl0_node.children.to_a.should eql(lvl0_children.map(&:first))
        lvl0_node.has_children?.should be_true
        lvl0_node.is_childless?.should be_false
        # Siblings assertions
        lvl0_node.sibling_ids.should eql(roots.map(&:first).map(&:id))
        lvl0_node.siblings.to_a.should eql(roots.map(&:first))
        lvl0_node.has_siblings?.should be_true
        lvl0_node.is_only_child?.should be_false
        # Descendants assertions
        descendants = model.all.find_all do |node|
          node.ancestor_ids.include?(lvl0_node.id)
        end
        lvl0_node.descendant_ids.should eql(descendants.map(&:id))
        lvl0_node.descendants.to_a.should eql(descendants)
        lvl0_node.subtree.to_a.should eql([lvl0_node] + descendants)

        lvl0_children.each do |lvl1_node, lvl1_children|
          # Ancestors assertions
          lvl1_node.ancestor_ids.should eql([lvl0_node.id])
          lvl1_node.ancestors.to_a.should eql([lvl0_node])
          lvl1_node.path_ids.should eql([lvl0_node.id, lvl1_node.id])
          lvl1_node.path.to_a.should eql([lvl0_node, lvl1_node])
          lvl1_node.depth.should eql(1)
          # Parent assertions
          lvl1_node.parent_id.should eql(lvl0_node.id)
          lvl1_node.parent.should eql(lvl0_node)
          # Root assertions
          lvl1_node.root_id.should eql(lvl0_node.id)
          lvl1_node.root.should eql(lvl0_node)
          lvl1_node.is_root?.should be_false
          # Children assertions
          lvl1_node.child_ids.should eql(lvl1_children.map(&:first).map(&:id))
          lvl1_node.children.to_a.should eql(lvl1_children.map(&:first))
          lvl1_node.has_children?.should be_true
          lvl1_node.is_childless?.should be_false
          # Siblings assertions
          lvl1_node.sibling_ids.should eql(lvl0_children.map(&:first).map(&:id))
          lvl1_node.siblings.to_a.should eql(lvl0_children.map(&:first))
          lvl1_node.has_siblings?.should be_true
          lvl1_node.is_only_child?.should be_false
          # Descendants assertions
          descendants = model.all.find_all do |node|
            node.ancestor_ids.include? lvl1_node.id
          end

          lvl1_node.descendant_ids.should eql(descendants.map(&:id))
          lvl1_node.descendants.to_a.should eql(descendants)
          lvl1_node.subtree.to_a.should eql([lvl1_node] + descendants)

          lvl1_children.each do |lvl2_node, lvl2_children|
            # Ancestors assertions
            lvl2_node.ancestor_ids.should eql([lvl0_node.id, lvl1_node.id])
            lvl2_node.ancestors.to_a.should eql([lvl0_node, lvl1_node])
            lvl2_node.path_ids.should eql([lvl0_node.id, lvl1_node.id, lvl2_node.id])
            lvl2_node.path.to_a.should eql([lvl0_node, lvl1_node, lvl2_node])
            lvl2_node.depth.should eql(2)
            # Parent assertions
            lvl2_node.parent_id.should eql(lvl1_node.id)
            lvl2_node.parent.should eql(lvl1_node)
            # Root assertions
            lvl2_node.root_id.should eql(lvl0_node.id)
            lvl2_node.root.should eql(lvl0_node)
            lvl2_node.is_root?.should be_false
            # Children assertions
            lvl2_node.child_ids.should eql([])
            lvl2_node.children.to_a.should eql([])
            lvl2_node.has_children?.should be_false
            lvl2_node.is_childless?.should be_true
            # Siblings assertions
            lvl2_node.sibling_ids.should eql(lvl1_children.map(&:first).map(&:id))
            lvl2_node.siblings.to_a.should eql(lvl1_children.map(&:first))
            lvl2_node.has_siblings?.should be_true
            lvl2_node.is_only_child?.should be_false
            # Descendants assertions
            descendants = model.all.find_all do |node|
              node.ancestor_ids.include? lvl2_node.id
            end
            lvl2_node.descendant_ids.should eql(descendants.map(&:id))
            lvl2_node.descendants.to_a.should eql(descendants)
            lvl2_node.subtree.to_a.should eql([lvl2_node] + descendants)
          end
        end
      end
    end
  end

  it "should validate ancestry field" do
    subject.with_model do |model|
      node = model.create
      ['3', '10/2', '1/4/30', nil].each do |value|
        node.send :write_attribute, model.ancestry_field, value
        node.should be_valid
        node.errors[model.ancestry_field].blank?.should be_true
      end
      ['1/3/', '/2/3', 'A/b', '-34', '/54'].each do |value|
        node.send :write_attribute, model.ancestry_field, value
        node.should_not be_valid
        node.errors[model.ancestry_field].blank?.should be_false
      end
    end
  end

  it "should move descendants with node" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      root1, root2, root3 = roots.map(&:first)

      descendants = root1.descendants.asc(:_id).map(&:to_param)
      expect {
        root1.parent = root2
        root1.save!
        root1.descendants.asc(:_id).map(&:to_param).should eql(descendants)
      }.to change(root2.descendants, 'size').by(root1.subtree.size)

      descendants = root2.descendants.asc(:_id).map(&:to_param)
      expect {
        root2.parent = root3
        root2.save!
        root2.descendants.asc(:_id).map(&:to_param).should eql(descendants)
      }.to change(root3.descendants, 'size').by(root2.subtree.size)

      descendants = root1.descendants.asc(:_id).map(&:to_param)
      expect {
        expect {
          root1.parent = nil
          root1.save!
          root1.descendants.asc(:_id).map(&:to_param).should eql(descendants)
        }.to change(root3.descendants, 'size').by(-root1.subtree.size)
      }.to change(root2.descendants, 'size').by(-root1.subtree.size)
    end
  end

  it "should validate ancestry exclude self" do
    subject.with_model do |model|
      parent = model.create!
      child = parent.children.create
      expect { parent.update_attributes! :parent => child }.to raise_error(Mongoid::Errors::Validations)
    end
  end

  it "should have depth caching" do 
    subject.with_model :depth => 3, :width => 3, :cache_depth => true, :depth_cache_field => :depth_cache do |model, roots|
      roots.each do |lvl0_node, lvl0_children|
        lvl0_node.depth_cache.should eql(0)
        lvl0_children.each do |lvl1_node, lvl1_children|
          lvl1_node.depth_cache.should eql(1)
          lvl1_children.each do |lvl2_node, lvl2_children|
            lvl2_node.depth_cache.should eql(2)
          end
        end
      end
    end
  end

  it "should have descendants with depth constraints" do
    subject.with_model :depth => 4, :width => 4, :cache_depth => true do |model, roots|
      model.roots.first.descendants(:before_depth => 2).count.should eql(4)
      model.roots.first.descendants(:to_depth => 2).count.should eql(20)
      model.roots.first.descendants(:at_depth => 2).count.should eql(16)
      model.roots.first.descendants(:from_depth => 2).count.should eql(80)
      model.roots.first.descendants(:after_depth => 2).count.should eql(64)
    end
  end

  it "should have subtree with depth constraints" do
    subject.with_model :depth => 4, :width => 4, :cache_depth => true do |model, roots|
      model.roots.first.subtree(:before_depth => 2).count.should eql(5)
      model.roots.first.subtree(:to_depth => 2).count.should eql(21)
      model.roots.first.subtree(:at_depth => 2).count.should eql(16)
      model.roots.first.subtree(:from_depth => 2).count.should eql(80)
      model.roots.first.subtree(:after_depth => 2).count.should eql(64)
    end
  end

  it "should have ancestors with depth constraints" do
    subject.with_model :cache_depth => true do |model|
      node1 = model.create!
      node2 = node1.children.create
      node3 = node2.children.create
      node4 = node3.children.create
      node5 = node4.children.create
      leaf  = node5.children.create

      leaf.ancestors(:before_depth => -2).to_a.should eql([node1, node2, node3])
      leaf.ancestors(:to_depth => -2).to_a.should eql([node1, node2, node3, node4])
      leaf.ancestors(:at_depth => -2).to_a.should eql([node4])
      leaf.ancestors(:from_depth => -2).to_a.should eql([node4, node5])
      leaf.ancestors(:after_depth => -2).to_a.should eql([node5])
    end
  end

  it "should have path with depth constraints" do
    subject.with_model :cache_depth => true do |model|
      node1 = model.create!
      node2 = node1.children.create
      node3 = node2.children.create
      node4 = node3.children.create
      node5 = node4.children.create
      leaf  = node5.children.create

      leaf.path(:before_depth => -2).to_a.should eql([node1, node2, node3])
      leaf.path(:to_depth => -2).to_a.should eql([node1, node2, node3, node4])
      leaf.path(:at_depth => -2).to_a.should eql([node4])
      leaf.path(:from_depth => -2).to_a.should eql([node4, node5, leaf])
      leaf.path(:after_depth => -2).to_a.should eql([node5, leaf])
    end
  end

  it "should raise exception on unknown depth field" do
    subject.with_model :cache_depth => true do |model|
      expect {
        model.create!.subtree(:this_is_not_a_valid_depth_option => 42)
      }.to raise_error(Mongoid::Ancestry::Error)
    end
  end


end
