Mongoid-ancestry
================

Mongoid-ancestry is a gem/plugin that allows the records of a Ruby on Rails Mongoid model to be organised as a tree structure (or hierarchy). It uses a single, intuitively formatted database column, using a variation on the materialised path pattern. It exposes all the standard tree structure relations (ancestors, parent, root, children, siblings, descendants) and all of them can be fetched in a single query. Additional features are STI support, scopes, depth caching, depth constraints, easy migration from older plugins/gems, integrity checking, integrity restoration, arrangement of (sub)tree into hashes and different strategies for dealing with orphaned records.

## Installation

### It's Rails 3 only.

To apply Mongoid-ancestry to any Mongoid model, follow these simple steps:

1. Install

  * Add to Gemfile: `gem 'mongoid-ancestry'`
  * Install required gems: `bundle install`

2. Add ancestry to your model

        include Mongoid::Ancestry
        has_ancestry

Your model is now a tree!

## Organising records into a tree
You can use the parent attribute to organise your records into a tree. If you have the id of the record you want
to use as a parent and don't want to fetch it, you can also use parent_id. Like any virtual model attributes,
parent and parent_id can be set using parent= and parent_id= on a record or by including them in the hash passed
to new, create, create!, update_attributes and update_attributes!. For example:

    TreeNode.create :name => 'Stinky', :parent => TreeNode.create(:name => 'Squeeky')

or

    TreeNode.create :name => 'Stinky', :parent_id => TreeNode.create(:name => 'Squeeky').id

#### Note: It doesn't work with `.create!` at the moment(mongoid bug? needs more investigation). But it absolutely will be fixed.


You can also create children through the children relation on a node:

    node.children.create :name => 'Stinky'

## Navigating your tree

To navigate an Ancestry model, use the following methods on any instance / record:

    parent           Returns the parent of the record, nil for a root node
    parent_id        Returns the id of the parent of the record, nil for a root node
    root             Returns the root of the tree the record is in, self for a root node
    root_id          Returns the id of the root of the tree the record is in
    is_root?         Returns true if the record is a root node, false otherwise
    ancestor_ids     Returns a list of ancestor ids, starting with the root id and ending with the parent id
    ancestors        Scopes the model on ancestors of the record
    path_ids         Returns a list the path ids, starting with the root id and ending with the node's own id
    path             Scopes model on path records of the record
    children         Scopes the model on children of the record
    child_ids        Returns a list of child ids
    has_children?    Returns true if the record has any children, false otherwise
    is_childless?    Returns true is the record has no childen, false otherwise
    siblings         Scopes the model on siblings of the record, the record itself is included
    sibling_ids      Returns a list of sibling ids
    has_siblings?    Returns true if the record's parent has more than one child
    is_only_child?   Returns true if the record is the only child of its parent
    descendants      Scopes the model on direct and indirect children of the record
    descendant_ids   Returns a list of a descendant ids
    subtree          Scopes the model on descendants and itself
    subtree_ids      Returns a list of all ids in the record's subtree
    depth            Return the depth of the node, root nodes are at depth 0

## Options for has_ancestry

The has_ancestry methods supports the following options:

    :ancestry_field        Pass in a symbol to store ancestry in a different field
    :orphan_strategy       Instruct Ancestry what to do with children of a node that is destroyed:
                           :destroy   All children are destroyed as well (default)
                           :rootify   The children of the destroyed node become root nodes
                           :restrict  An Error is raised if any children exist
    :cache_depth           Cache the depth of each node in the 'ancestry_depth' field (default: false)
                           If you turn depth_caching on for an existing model:
                           - Build cache: TreeNode.rebuild_depth_cache!
    :depth_cache_field     Pass in a symbol to store depth cache in a different field

## Scopes

Where possible, the navigation methods return scopes instead of records, this means additional ordering, conditions, limits, etc. can be applied and that the result can be either retrieved, counted or checked for existence. For example:

    node.children.where(:name => 'Mary')
    node.subtree.order_by([:name, :desc]).limit(10).each do; ...; end
    node.descendants.count

For convenience, a couple of named scopes are included at the class level:

    roots                   Root nodes
    ancestors_of(node)      Ancestors of node, node can be either a record or an id
    children_of(node)       Children of node, node can be either a record or an id
    descendants_of(node)    Descendants of node, node can be either a record or an id
    subtree_of(node)        Subtree of node, node can be either a record or an id
    siblings_of(node)       Siblings of node, node can be either a record or an id

Thanks to some convenient rails magic, it is even possible to create nodes through the children and siblings scopes:

    node.children.create
    node.siblings.create
    TestNode.children_of(node_id).build
    TestNode.siblings_of(node_id).create

## Selecting nodes by depth

When depth caching is enabled (see has_ancestry options), five more named scopes can be used to select nodes on their depth:

    before_depth(depth)     Return nodes that are less deep than depth (node.depth < depth)
    to_depth(depth)         Return nodes up to a certain depth (node.depth <= depth)
    at_depth(depth)         Return nodes that are at depth (node.depth == depth)
    from_depth(depth)       Return nodes starting from a certain depth (node.depth >= depth)
    after_depth(depth)      Return nodes that are deeper than depth (node.depth > depth)

The depth scopes are also available through calls to descendants, descendant_ids, subtree, subtree_ids, path and ancestors. In this case, depth values are interpreted relatively. Some examples:

    node.subtree(:to_depth => 2)      Subtree of node, to a depth of node.depth + 2 (self, children and grandchildren)
    node.subtree.to_depth(5)          Subtree of node to an absolute depth of 5
    node.descendants(:at_depth => 2)  Descendant of node, at depth node.depth + 2 (grandchildren)
    node.descendants.at_depth(10)     Descendants of node at an absolute depth of 10
    node.ancestors.to_depth(3)        The oldest 4 ancestors of node (its root and 3 more)
    node.path(:from_depth => -2)      The node's grandparent, parent and the node itself

    node.ancestors(:from_depth => -6, :to_depth => -4)
    node.path.from_depth(3).to_depth(4)
    node.descendants(:from_depth => 2, :to_depth => 4)
    node.subtree.from_depth(10).to_depth(12)

Please note that depth constraints cannot be passed to ancestor_ids and path_ids. The reason for this is that both these relations can be fetched directly from the ancestry column without performing a database query. It would require an entirely different method of applying the depth constraints which isn't worth the effort of implementing. You can use ancestors(depth_options).map(&:id) or ancestor_ids.slice(min_depth..max_depth) instead.

## STI support

Ancestry works fine with STI. Just create a STI inheritance hierarchy and build an Ancestry tree from the different classes/models. All Ancestry relations that where described above will return nodes of any model type. If you do only want nodes of a specific subclass you'll have to add a condition on type for that.

## Arrangement

Ancestry can arrange an entire subtree into nested hashes for easy navigation after retrieval from the database.  TreeNode.arrange could for example return:

    { #<TreeNode id: 100018, name: "Stinky", ancestry: nil>
      => { #<TreeNode id: 100019, name: "Crunchy", ancestry: "100018">
        => { #<TreeNode id: 100020, name: "Squeeky", ancestry: "100018/100019">
          => {}
        }
      }
    }

The arrange method also works on a scoped class, for example:

    TreeNode.where(:name => 'Crunchy').first.subtree.arrange

The arrange method takes Mongoid find options. If you want your hashes to be ordered, you should pass the order to the arrange method instead of to the scope. This only works for Ruby 1.9 and later since before that hashes weren't ordered. For example:

    TreeNode.where(:name => 'Crunchy').subtree.arrange(:order => [:name, :asc])

## Migrating from plugin that uses parent_id column

With Mongoid-ancestry its easy to migrate from any of these plugins, to do so, use the build_ancestry_from_parent_ids! method on your model. These steps provide a more detailed explanation:

1. Remove old tree plugin or gem and add in Mongoid-ancestry
  * See 'Installation' for more info on installing and configuring gem
  * Add to app/models/[model].rb:

            include Mongoid::Ancestry
            has_ancestry

  * Create indexes

2. Change your code
Most tree calls will probably work fine with ancestry
Others must be changed or proxied
Check if all your data is intact and all tests pass

3. Drop parent_id field

## Integrity checking and restoration

I don't see any way Mongoid-ancestry tree integrity could get compromised without explicitly setting cyclic parents or invalid ancestry and circumventing validation with update_attribute, if you do, please let me know.

Mongoid-ancestry includes some methods for detecting integrity problems and restoring integrity just to be sure. To check integrity use: [Model].check_ancestry_integrity!. An Mongoid::Ancestry::Error will be raised if there are any problems. You can also specify :report => :list to return an array of exceptions or :report => :echo to echo any error messages. To restore integrity use: [Model].restore_ancestry_integrity!.

For example, from IRB:

    >> stinky = TreeNode.create :name => 'Stinky'
    $  #<TreeNode id: 1, name: "Stinky", ancestry: nil>
    >> squeeky = TreeNode.create :name => 'Squeeky', :parent => stinky
    $  #<TreeNode id: 2, name: "Squeeky", ancestry: "1">
    >> stinky.update_attribute :parent, squeeky
    $  true
    >> TreeNode.all
    $  [#<TreeNode id: 1, name: "Stinky", ancestry: "1/2">, #<TreeNode id: 2, name: "Squeeky", ancestry: "1/2/1">]
    >> TreeNode.check_ancestry_integrity!
    !! Ancestry::AncestryIntegrityException: Conflicting parent id in node 1: 2 for node 1, expecting nil
    >> TreeNode.restore_ancestry_integrity!
    $  [#<TreeNode id: 1, name: "Stinky", ancestry: 2>, #<TreeNode id: 2, name: "Squeeky", ancestry: nil>]

Additionally, if you think something is wrong with your depth cache:

    >> TreeNode.rebuild_depth_cache!

## Tests

The Mongoid-ancestry gem comes with rspec and guard(for automatically specs running) suite consisting of about 40 specs. It takes about 10 seconds to run. To run it yourself check out the repository from GitHub, run `bundle install`, run `guard` and press `Ctrl+\` or just `rake spec`.

## Internals

As can be seen in the previous section, Mongoid-ancestry stores a path from the root to the parent for every node. This is a variation on the materialised path database pattern. It allows to fetch any relation (siblings, descendants, etc.) in a single query without the complicated algorithms and incomprehensibility associated with left and right values. Additionally, any inserts, deletes and updates only affect nodes within the affected node's own subtree.

The materialised path pattern requires Mongoid-ancestry to use a 'regexp' condition in order to fetch descendants. This should not be particularly slow however since the the condition never starts with a wildcard which allows the DBMS to use the column index. If you have any data on performance with a large number of records, please drop me line.

## Contact and copyright

It's a fork of [original ancestry](https://github.com/stefankroes/ancestry) gem but adopted to work with Mongoid.

All thanks should goes to Stefan Kroes for his great work.

Bug report? Faulty/incomplete documentation? Feature request? Please post an issue on [issues tracker](http://github.com/skyeagle/mongoid-ancestry/issues).

Copyright (c) 2009 Stefan Kroes, released under the MIT license
