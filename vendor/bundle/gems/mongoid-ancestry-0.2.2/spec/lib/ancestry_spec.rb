require 'spec_helper'

require 'mongoid-ancestry/exceptions'


describe MongoidAncestry do

  subject { MongoidAncestry }

  it "should have ancestry fields" do
    subject.with_model do |model|
      model.fields['ancestry'].options[:type].should eql(String)
    end
  end

  it "should have non default ancestry field" do
    subject.with_model :ancestry_field => :alternative_ancestry do |model|
      model.ancestry_field.should eql(:alternative_ancestry)
    end
  end

  it "should set ancestry field" do
    subject.with_model do |model|
      model.ancestry_field = :ancestors
      model.ancestry_field.should eql(:ancestors)
      model.ancestry_field = :ancestry
      model.ancestry_field.should eql(:ancestry)
    end
  end

  it "should have default orphan strategy" do
    subject.with_model do |model|
      model.orphan_strategy.should eql(:destroy)
    end
  end

  it "should have non default orphan strategy" do
    subject.with_model :orphan_strategy => :rootify do |model|
      model.orphan_strategy.should eql(:rootify)
    end
  end

  it "should set orphan strategy" do
    subject.with_model do |model|
      model.orphan_strategy = :rootify
      model.orphan_strategy.should eql(:rootify)
      model.orphan_strategy = :destroy
      model.orphan_strategy.should eql(:destroy)
    end
  end

  it "should not set invalid orphan strategy" do
    subject.with_model do |model|
      expect {
        model.orphan_strategy = :non_existent_orphan_strategy
      }.to raise_error Mongoid::Ancestry::Error
    end
  end

  it "should setup test nodes" do
    subject.with_model :depth => 3, :width => 3 do |model, roots|
      roots.class.should eql(Array)
      roots.length.should eql(3)
      roots.each do |node, children|
        node.class.should eql(model)
        children.class.should eql(Array)
        children.length.should eql(3)
        children.each do |node, children|
          node.class.should eql(model)
          children.class.should eql(Array)
          children.length.should eql(3)
          children.each do |node, children|
            node.class.should eql(model)
            children.class.should eql(Array)
            children.length.should eql(0)
          end
        end
      end
    end
  end

  it "should have STI support" do
    subject.with_model :extra_columns => {:type => :string} do |model|
      subclass1 = Object.const_set 'Subclass1', Class.new(model)
      (class << subclass1; self; end).send(:define_method, :model_name) do
      Struct.new(:human, :underscore).new 'Subclass1', 'subclass1'
      end
      subclass2 = Object.const_set 'Subclass2', Class.new(model)
      (class << subclass2; self; end).send(:define_method, :model_name) do
      Struct.new(:human, :underscore).new 'Subclass1', 'subclass1'
      end

      node1 = subclass1.create
      node2 = subclass2.create :parent => node1
      node3 = subclass1.create :parent => node2
      node4 = subclass2.create :parent => node3
      node5 = subclass1.create :parent => node4

      model.all.each do |node|
        [subclass1, subclass2].include?(node.class).should be_true
      end

      node1.descendants.map(&:id).should eql([node2.id, node3.id, node4.id, node5.id])
      node1.subtree.map(&:id).should eql([node1.id, node2.id, node3.id, node4.id, node5.id])
      node5.ancestors.map(&:id).should eql([node1.id, node2.id, node3.id, node4.id])
      node5.path.map(&:id).should eql([node1.id, node2.id, node3.id, node4.id, node5.id])
    end
  end

end
