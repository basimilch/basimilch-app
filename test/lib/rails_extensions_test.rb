require 'test_helper'

# Should not be an Action Controller test, but a Unit Test instead.
class RailsExtentionsTest < ActionController::TestCase

  def setup
    @some_hash = {a: 1, inner_hash: { 'b' => 2, c: 3 } }
  end

  test "should get index" do
    assert_equal nil,                     {}.get(:a)
    assert_equal nil,                     @some_hash.get(:a, :b)
    assert_equal nil,                     @some_hash.get(:a, :b, :c)
    assert_equal 1,                       @some_hash.get(:a)
    assert_equal @some_hash[:inner_hash], @some_hash.get(:inner_hash)
    assert_equal 2,                       @some_hash.get(:inner_hash, 'b')
    assert_equal 3,                       @some_hash.get(:inner_hash, :c)
    assert_equal nil,                     @some_hash.get(:inner_hash, :d)
  end
end
