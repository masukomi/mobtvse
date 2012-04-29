require 'spec_helper'

describe MongoidAncestry do

  subject { MongoidAncestry }

  it "should have scopes" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      # Roots assertion
      model.roots.all.to_a.should eql(roots.map(&:first))

      model.all.each do |test_node|
        # Assertions for ancestors_of named scope
        model.ancestors_of(test_node).all.should == test_node.ancestors.all
        model.ancestors_of(test_node.id).all.to_a.should eql(test_node.ancestors.all.to_a)
        # Assertions for children_of named scope
        model.children_of(test_node).all.to_a.should eql(test_node.children.all.to_a)
        model.children_of(test_node.id).all.to_a.should eql(test_node.children.all.to_a)
        # Assertions for descendants_of named scope
        model.descendants_of(test_node).all.should == (test_node.descendants.all)
        model.descendants_of(test_node.id).all.to_a.should eql(test_node.descendants.all.to_a)
        # Assertions for subtree_of named scope
        model.subtree_of(test_node).all.to_a.should eql(test_node.subtree.all.to_a)
        model.subtree_of(test_node.id).all.to_a.should eql(test_node.subtree.all.to_a)
        # Assertions for siblings_of named scope
        model.siblings_of(test_node).all.to_a.should eql(test_node.siblings.all.to_a)
        model.siblings_of(test_node.id).all.to_a.should eql(test_node.siblings.all.to_a)
      end
    end
  end

  it "should be arranged" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      id_sorter = Proc.new {|a, b|; a.to_param <=> b.to_param }
      arranged_nodes = model.arrange
      arranged_nodes.size.should eql(3)
      arranged_nodes.each do |node, children|
        children.keys.sort(&id_sorter).should eql(node.children.sort(&id_sorter))
        children.each do |node, children|
          children.keys.sort(&id_sorter).should eql(node.children.sort(&id_sorter))
          children.each do |node, children|
            children.size.should eql(0)
          end
        end
      end
    end
  end

  it "should have arrange order option" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      descending_nodes_lvl0 = model.arrange :order => [:_id, :desc]
      ascending_nodes_lvl0 = model.arrange :order => [:_id, :asc]

      descending_nodes_lvl0.keys.zip(ascending_nodes_lvl0.keys.reverse).each do |descending_node, ascending_node|
        ascending_node.should eql(descending_node)
        descending_nodes_lvl1 = descending_nodes_lvl0[descending_node]
        ascending_nodes_lvl1 = ascending_nodes_lvl0[ascending_node]
        descending_nodes_lvl1.keys.zip(ascending_nodes_lvl1.keys.reverse).each do |descending_node, ascending_node|
          ascending_node.should eql(descending_node)
          descending_nodes_lvl2 = descending_nodes_lvl1[descending_node]
          ascending_nodes_lvl2 = ascending_nodes_lvl1[ascending_node]
          descending_nodes_lvl2.keys.zip(ascending_nodes_lvl2.keys.reverse).each do |descending_node, ascending_node|
            ascending_node.should eql(descending_node)
            descending_nodes_lvl3 = descending_nodes_lvl2[descending_node]
            ascending_nodes_lvl3 = ascending_nodes_lvl2[ascending_node]
            descending_nodes_lvl3.keys.zip(ascending_nodes_lvl3.keys.reverse).each do |descending_node, ascending_node|
              ascending_node.should eql(descending_node)
            end
          end
        end
      end
    end
  end
  
  it "should have valid orphan rootify strategy" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      model.orphan_strategy = :rootify
      root = roots.first.first
      children = root.children.all
      root.destroy
      children.each do |child|
        child.reload
        child.is_root?.should be_true
        child.children.size.should eql(3)
      end
    end
  end

  it "should have valid orphan destroy strategy" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      model.orphan_strategy = :destroy
      root = roots.first.first
      expect { root.destroy }.to change(model, :count).by(-root.subtree.size)
      node = model.roots.first.children.first
      expect { node.destroy }.to change(model, :count).by(-node.subtree.size)
    end
  end

  it "should have valid orphan restrict strategy" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      model.orphan_strategy = :restrict
      root = roots.first.first
      expect { root.destroy }.to raise_error Mongoid::Ancestry::Error
      expect { root.children.first.children.first.destroy }.to_not raise_error Mongoid::Ancestry::Error
    end
  end

  it "should check that there are no errors on a valid tree" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      expect { model.check_ancestry_integrity! }.to_not raise_error(Mongoid::Ancestry::Error)
      model.check_ancestry_integrity!(:report => :list).size.should eql(0)
    end
  end

  it "should check detection of invalid format for ancestry field" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      roots.first.first.update_attribute model.ancestry_field, 'invalid_ancestry'
      expect { model.check_ancestry_integrity! }.to raise_error(Mongoid::Ancestry::IntegrityError)
      model.check_ancestry_integrity!(:report => :list).size.should eql(1)
    end
  end

  it "should check detection of non-existent ancestor" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      node = roots.first.first
      node.without_ancestry_callbacks do
       node.update_attribute model.ancestry_field, 35
      end
      expect { model.check_ancestry_integrity! }.to raise_error(Mongoid::Ancestry::IntegrityError)
      model.check_ancestry_integrity!(:report => :list).size.should eql(1)
    end
  end

  it "should check detection of cyclic ancestry" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      node = roots.first.first
      node.update_attribute model.ancestry_field, node.id
      expect { model.check_ancestry_integrity! }.to raise_error(Mongoid::Ancestry::IntegrityError)
      model.check_ancestry_integrity!(:report => :list).size.should eql(1)
    end
  end

  it "should check detection of conflicting parent id" do
    subject.with_model do |model|
      model.destroy_all
      model.create!(model.ancestry_field => model.create!(model.ancestry_field => model.create!(model.ancestry_field => nil).id).id)
      expect { model.check_ancestry_integrity! }.to raise_error(Mongoid::Ancestry::IntegrityError)
      model.check_ancestry_integrity!(:report => :list).size.should eql(1)
    end
  end

  def assert_integrity_restoration model
    expect { model.check_ancestry_integrity! }.to raise_error(Mongoid::Ancestry::IntegrityError)
    model.restore_ancestry_integrity!
    expect { model.check_ancestry_integrity! }.to_not raise_error(Mongoid::Ancestry::IntegrityError)
  end

  it "should check that integrity is restored for invalid format for ancestry field" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      roots.first.first.update_attribute model.ancestry_field, 'invalid_ancestry'
      assert_integrity_restoration model
    end
  end

  it "should check that integrity is restored for non-existent ancestor" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      roots.first.first.update_attribute model.ancestry_field, 35
      assert_integrity_restoration model
    end
  end

  it "should check that integrity is restored for cyclic ancestry" do
    subject.with_model :width => 3, :depth => 3 do |model, roots|
      node = roots.first.first
      node.update_attribute model.ancestry_field, node.id
      assert_integrity_restoration model
    end
  end

  it "should check that integrity is restored for conflicting parent id" do
    subject.with_model do |model|
      model.destroy_all
      model.create!(model.ancestry_field => model.create!(model.ancestry_field => model.create!(model.ancestry_field => nil).id).id)
      assert_integrity_restoration model
    end
  end

  it "should create node through scope" do
    subject.with_model do |model|
      node = model.create!
      child = node.children.create # doesn't pass with .create!
      child.parent.should eql(node)

      other_child = child.siblings.create # doesn't pass with .create!
      other_child.parent.should eql(node)

      grandchild = model.children_of(child).build # doesn't pass with .new
      grandchild.save
      grandchild.parent.should eql(child)

      other_grandchild = model.siblings_of(grandchild).build # doesn't pass with .new
      other_grandchild.save!
      other_grandchild.parent.should eql(child)
    end
  end

  it "should have depth scopes" do
    subject.with_model :depth => 4, :width => 2, :cache_depth => true do |model, roots|
      model.before_depth(2).all? { |node| node.depth < 2 }.should be_true
      model.to_depth(2).all?     { |node| node.depth <= 2 }.should be_true
      model.at_depth(2).all?     { |node| node.depth == 2 }.should be_true
      model.from_depth(2).all?   { |node| node.depth >= 2 }.should be_true
      model.after_depth(2).all?  { |node| node.depth > 2 }.should be_true
    end
  end

  it "should raise error on invalid scopes" do
    subject.with_model do |model|
      expect { model.before_depth(1) } .to raise_error(Mongoid::Ancestry::Error)
      expect { model.to_depth(1)     } .to raise_error(Mongoid::Ancestry::Error)
      expect { model.at_depth(1)     } .to raise_error(Mongoid::Ancestry::Error)
      expect { model.from_depth(1)   } .to raise_error(Mongoid::Ancestry::Error)
      expect { model.after_depth(1)  } .to raise_error(Mongoid::Ancestry::Error)
    end
  end

  it "should raise error on invalid has_ancestry options" do
    subject.with_model do |model|
      expect { model.has_ancestry :this_option_doesnt_exist => 42 }.to raise_error(Mongoid::Ancestry::Error)
      expect { model.has_ancestry :not_a_hash                     }.to raise_error(Mongoid::Ancestry::Error)
    end
  end

  it "should build ancestry from parent ids" do
    subject.with_model :skip_ancestry => true, :extra_columns => {:parent_id => :integer} do |model|
      [model.create!].each do |parent1|
        (Array.new(5) { model.create :parent_id => parent1.id }).each do |parent2|
          (Array.new(5) { model.create :parent_id => parent2.id }).each do |parent3|
            (Array.new(5) { model.create :parent_id => parent3.id })
          end
        end
      end

      # Assert all nodes where created
      model.count.should eql((0..3).map { |n| 5 ** n }.sum)
    end

    subject.with_model do |model|

      model.build_ancestry_from_parent_ids!

      # Assert ancestry integrity
      model.check_ancestry_integrity!

      roots = model.roots.all
      ## Assert single root node
      roots.size.should eql(1)

      ## Assert it has 5 children
      roots.each do |parent|
        parent.children.count.should eql(5)
        parent.children.each do |parent|
          parent.children.count.should eql(5)
          parent.children.each do |parent|
            parent.children.count.should eql(5)
            parent.children.each do |parent|
              parent.children.count.should eql(0)
            end
          end
        end
      end
    end
  end

  it "should rebuild depth cache" do
    subject.with_model :depth => 3, :width => 3, :cache_depth => true, :depth_cache_field => :depth_cache do |model, roots|
      model.update_all(:depth_cache => nil)

      # Assert cache was emptied correctly
      model.all.each do |test_node|
        test_node.depth_cache.should eql(nil)
      end

      # Rebuild cache
      model.rebuild_depth_cache!

      # Assert cache was rebuild correctly
      model.all.each do |test_node|
        test_node.depth_cache.should eql(test_node.depth)
      end
    end
  end

  it "should raise exception when rebuilding depth cache for model without depth caching" do
    subject.with_model do |model|
      expect { model.rebuild_depth_cache! }.to raise_error(Mongoid::Ancestry::Error)
    end
  end

end
