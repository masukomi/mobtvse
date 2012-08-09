require './test/test_helper'

class GridTest < Test::Unit::TestCase

  context "GridFS: " do
    setup do
      @conn   = stub()
      @conn.stubs(:safe)
      @conn.stubs(:read_preference)
      @db     = DB.new("testing", @conn)
      @files  = mock()
      @chunks = mock()

      @db.expects(:[]).with('fs.files').returns(@files)
      @db.expects(:[]).with('fs.chunks').returns(@chunks)
      @db.stubs(:safe)
      @db.stubs(:read_preference)
    end

    context "Grid classe with standard connections" do
      setup do
        @conn.expects(:class).returns(Connection)
        @conn.expects(:read_primary?).returns(true)
      end

      should "create indexes for Grid" do
        @chunks.expects(:create_index)
        Grid.new(@db)
      end

      should "create indexes for GridFileSystem" do
        @files.expects(:create_index)
        @chunks.expects(:create_index)
        GridFileSystem.new(@db)
      end
    end

    context "Grid classes with slave connection" do
      setup do
        @conn.expects(:class).twice.returns(Connection)
        @conn.expects(:read_primary?).returns(false)
      end

      should "not create indexes for Grid" do
        Grid.new(@db)
      end

      should "not create indexes for GridFileSystem" do
        GridFileSystem.new(@db)
      end
    end
  end
end
