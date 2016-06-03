require 'test_helper'

# Should not be an Action Controller test, but a Unit Test instead.
class RailsExtentionsTest < ActionController::TestCase

  def setup
    @a_hash = {a: 1, some_str: "a string", inner_hash: { 'b' => 2, c: 3 } }
  end

  test "any Object should respond to :allow" do
    assert_equal nil,       nil.allow(nil)
    assert_equal nil,       nil.allow(1)
    assert_equal nil,       nil.allow(:a)
    assert_equal nil,       nil.allow([])
    assert_equal nil,       nil.allow([:a, :b])
    assert_equal nil,       :c.allow(:a)
    assert_equal :a,        :a.allow(:a)
    assert_equal nil,       :c.allow([:a, :b])
    assert_equal :a,        :a.allow([:a, :b])
    assert_equal nil,       [:a, :b].allow([:a, :b])
    assert_equal [:a, :b],  [:a, :b].allow([[:a, :b]])
    assert_equal nil,       'a'.allow([:a, :b])
    assert_equal 'a',       'a'.allow([:a, :b, 'a'])
    assert_equal 'a',       'a'.allow(Set[:a, :b, 'a'])
    assert_equal nil,       ['a'].allow(Set[:a, :b, 'a'])
    assert_equal ['a'],     ['a'].allow(Set[:a, :b, 'a', ['a']])
  end

  test "should get index" do
    # NOTE: Please note the differences between ruby's :dig and our :get.
    assert_equal nil,                       {}.get(:a)
    assert_equal nil,                       @a_hash.get(:a, :b)
    assert_raise                          { @a_hash.dig(:a, :b) }
    assert_equal "a string",                @a_hash.get(:some_str)
    assert_equal @a_hash.dig(:some_str),    @a_hash.get(:some_str)
    assert_equal nil,                       @a_hash.get(:some_str, :not_found)
    assert_raise                          { @a_hash.dig(:some_str, :not_found) }
    assert_equal nil,                       @a_hash.get(:a, :b, :c)
    assert_equal 1,                         @a_hash.get(:a)
    assert_equal @a_hash[:inner_hash],      @a_hash.get(:inner_hash)
    assert_equal 2,                         @a_hash.get(:inner_hash, 'b')
    assert_equal @a_hash.dig(:inner_hash, 'b'),
                                            @a_hash.get(:inner_hash, 'b')
    assert_equal 3,                         @a_hash.get(:inner_hash, :c)
    assert_equal nil,                       @a_hash.get(:inner_hash, :d)
  end

  test "should pop hash value" do
    h = @a_hash.dup
    # NOTE: If the hash is the first value, the parenthesis are needed.
    # SOURCE: http://stackoverflow.com/a/5657827
    assert_equal({ 'b' => 2, c: 3 },                      h.pop(:inner_hash))
    assert_equal({ a: 1, some_str: "a string" } ,         h)
    assert_equal({a: 1, some_str: "a string", inner_hash: { 'b' => 2, c: 3 } },
                                                          @a_hash)
    assert_equal(nil,                                     h.pop(:inner_hash))
    assert_equal({ a: 1, some_str: "a string" } ,         h)
    assert_equal(nil,                                     h.pop(nil))
    assert_equal({ a: 1, some_str: "a string" } ,         h)
  end

  test "should be able to merge hashes with + operator" do
    h = {a: 1, b: 2}
    # NOTE: If the hash is the first value, the parenthesis are needed.
    # SOURCE: http://stackoverflow.com/a/5657827
    assert_equal({ a: 1, b: 2, c: 3 }, h + {c: 3})
    assert_equal({ a: 1, b: 3 }, h + {b: 3})
    assert_equal({ a: 1, b: 2 }, h + {})
    assert_equal({ a: 1, b: 2 }, h + nil)
    assert_raise { h + 1 }
  end

  test "should be able to update hash values" do
    assert_equal({:a=>2, :b=>1},    {a: 1, b: 0}.update_vals(:inc))
    assert_equal({:a=>11, :b=>10},  {a: 1, b: 0}.update_vals { |v| v + 10} )
  end

  test "should be able to merge hashes by adding its values" do
    assert_equal({a: 6, b: 0, c: 10},  {a: 1, b: 0}.merge_by_add({a: 5, c: 10}))
    assert_equal({a: 5, c: 10},        {}.merge_by_add({a: 5, c: 10}))
    assert_equal({a: 5, c: 10},        {a: 5, c: 10}.merge_by_add({}))
  end

  test "should be able to merge array of hash by adding its values" do
    assert_equal({a: 6, b: 0, c: 10},
                [{a: 1, b: 0}, {a: 5, c: 10}].reduce_by_add)
    assert_equal({a: 5, c: 10},        [{}, {a: 5, c: 10}].reduce_by_add)
    assert_equal({a: 5, c: 10},        [{a: 5, c: 10}, {}].reduce_by_add)
  end

  test "should be able to group array of hash by hash key" do
    assert_equal({1=>[{a: 1, b: 2}, {a: 1}], 2=>[{a: 2}]},
                     [{a: 1, b:2}, {a: 1}, {a: 2}].group_by_key(:a))
    assert_equal({1=>[{:a => 1, :b => 2}, {:a=>1}, {:a=>1}]},
                     [{a: 1, b:2}, {a: 1}, {a: 1}].group_by_key(:a))

    assert_equal({1=> [{b: 2}, {}], 2=>[{}]},
                 [{a: 1, b:2}, {a: 1}, {a: 2}].group_by_key(:a, pop_key: true))
    assert_equal({1=> [{b: 2}, {}, {}]},
                 [{a: 1, b:2}, {a: 1}, {a: 1}].group_by_key(:a, pop_key: true))
  end

  test "should be able to get a non blank string" do
    assert_equal nil, ''.not_blank
    assert_equal nil, ' '.not_blank
    assert_equal nil, '  '.not_blank # non-breaking spaces
    assert_equal nil, "\t".not_blank
    assert_equal nil, nil.not_blank

    assert_equal 'a', 'a'.not_blank
    assert_equal 'a ', 'a '.not_blank
    assert_equal ' a ', ' a '.not_blank # non-breaking spaces
    assert_equal "a\t", "a\t".not_blank
  end

  test "should be able to remove all whitespace chars from a string" do
    assert_equal '', "".remove_whitespace
    assert_equal '', "  ".remove_whitespace
    assert_equal '', "  ".remove_whitespace # non-breaking space, i.e. ALT+SPACE
    assert_equal '', "\t".remove_whitespace
    assert_equal 'foo', " f oo ".remove_whitespace
    assert_equal 'foo', " f oo ".remove_whitespace # non-breaking space
    assert_equal 'foo', "\tf\too\t".remove_whitespace
    assert_equal 'foo', " f\too ".remove_whitespace
  end

  test "should be able to recognize a swiss phone number string" do
    assert_equal true,  '+41123456789'.swiss_phone_number?
    assert_equal false, '+4112345678'.swiss_phone_number?
    assert_equal false, '+411234567890'.swiss_phone_number?
    assert_equal false, '+411'.swiss_phone_number?
    assert_equal false, '+41'.swiss_phone_number?
    assert_equal false, '+4'.swiss_phone_number?
    assert_equal false, '+'.swiss_phone_number?
    assert_equal false, ''.swiss_phone_number?
  end

  test "should be able call match? on a string" do
    assert_equal true,  "a".match?(/a/)
    assert_equal false, "b".match?(/a/)
    assert_equal true,  "hello, world".match?(/l{2}/)
  end

  test "should be able call strip_up_to on a string" do
    assert_equal "string",      "some string".strip_up_to("string")
    assert_equal "some string", "some string".strip_up_to("s")
    assert_equal "ing",         "some string".strip_up_to("i")
    assert_equal "ing",         "some string".strip_up_to("ing")
    assert_equal "some string", "some string".strip_up_to("not_found")
    assert_equal "some string", "some string".strip_up_to("")
    assert_raise { "some string".strip_up_to(nil) }
    assert_raise { "some string".strip_up_to() }
    assert_raise { "some string".strip_up_to(1) }
  end

  test "should be able to ensure that a string ends with a given string" do
    assert_equal "asdf", "asdf".ensure_end("df")
    assert_equal "asdf", "as".ensure_end("df")
    # TODO: Fix the following case if need be ;)
    assert_equal "asddf", "asd".ensure_end("df")
  end

  test "should be able to merge symbols with + operator" do
    sym = :some_symbol
    assert_equal :some_symbol, sym + nil
    assert_equal :some_symbol_suffix, sym + :_suffix
    assert_raise { sym + "_suffix" }
    assert_equal :prefix_some_symbol, :prefix_ + sym
    assert_raise { "prefix_" + sym }
    assert_raise { sym + 1 }
  end

  test "should be able to transform keyword into class" do
    assert_equal String, :string.to_class
    assert_equal ActiveRecord, :active_record.to_class
    assert_raise { :non_existent_class.to_class }
  end

  test "ActiveRecord as input for String formating should behave like a hash" do
    u = users(:admin)
    assert_equal "Hello User Example! Your email is one@example.com",
                 "Hello %{first_name} %{last_name}! Your email is %{email}" % u
    # With '%s' you must explicitly convert it to a String:
    assert_equal "User 1: \"User Example\" <one@example.com> (ADMIN)",
                 "%s" % u.to_s
    # The standard behavior of String#% should not be broken:
    # DOC: http://ruby-doc.org/core-2.3.1/String.html#method-i-25
    assert_equal "foo = bar",       "foo = %{foo}" % { :foo => 'bar' }
    assert_equal "00123",           "%05d" % 123
    assert_equal "ID   : 0000007b", "%-5s: %08x" % [ "ID", 123 ]
  end

  test "to_i_min should be available for String and Nil" do
    assert_equal 0, nil.to_i
    assert_equal 0, "".to_i
    assert_equal 0, "0".to_i
    assert_equal 1, "1".to_i
    assert_equal 1, nil.to_i_min(1)
    assert_equal 1, "".to_i_min(1)
    assert_equal 1, "0".to_i_min(1)
    assert_equal 1, "1".to_i_min(1)
  end

  test "inc and dec should be available for Fixnum" do
    assert_equal 1, 0.inc
    assert_equal 1, 2.dec
    assert_equal 1, 1.dec.inc
  end

  test "should get correct relative date in words" do
    travel_to Time.new(2010, 12, 31, 14, 35, 45) do
      assert_equal "vor etwa 2 Wochen",    Time.new(2010, 12, 14, 11,  0,  0).relative_in_words # Sunday
      assert_equal "vor etwa einer Woche", Time.new(2010, 12, 18, 11,  0,  0).relative_in_words # Saturday
      assert_equal "letzte Woche",         Time.new(2010, 12, 20, 11,  0,  0).relative_in_words # Monday
      assert_equal "letzte Woche",         Time.new(2010, 12, 26, 11,  0,  0).relative_in_words # Sunday
      assert_equal "vor etwa 2 Tagen",     Time.new(2010, 12, 29, 11,  0,  0).relative_in_words # Wednesday
      assert_equal "vor etwa einem Tag",   Time.new(2010, 12, 29, 20,  0,  0).relative_in_words
      assert_equal "gestern",              Time.new(2010, 12, 30,  6,  0,  0).relative_in_words # Thursday
      assert_equal "gestern",              Time.new(2010, 12, 30, 23,  0,  0).relative_in_words
      assert_equal "vor etwa 7 Stunden",   Time.new(2010, 12, 31,  7,  0,  0).relative_in_words # Friday
      assert_equal "vor 11 Minuten",       Time.new(2010, 12, 31, 14, 24, 30).relative_in_words
      assert_equal "vor 3 Sekunden",       Time.new(2010, 12, 31, 14, 35, 42).relative_in_words
      assert_equal "jetzt",                Time.new(2010, 12, 31, 14, 35, 45).relative_in_words
      assert_equal "in 4 Sekunden",        Time.new(2010, 12, 31, 14, 35, 49).relative_in_words
      assert_equal "in 7 Minuten",         Time.new(2010, 12, 31, 14, 43,  5).relative_in_words
      assert_equal "in etwa 9 Stunden",    Time.new(2010, 12, 31, 23, 45,  0).relative_in_words
      assert_equal "morgen",               Time.new(2011,  1,  1,  9,  0,  0).relative_in_words # Saturday
      assert_equal "morgen",               Time.new(2011,  1,  1, 18, 35, 45).relative_in_words
      assert_equal "in etwa einem Tag",    Time.new(2011,  1,  2,  9, 35, 45).relative_in_words # Sunday
      assert_equal "in etwa 2 Tagen",      Time.new(2011,  1,  2, 18, 35, 45).relative_in_words
      assert_equal "nächste Woche",        Time.new(2011,  1,  3,  9,  0,  0).relative_in_words # Monday
      assert_equal "nächste Woche",        Time.new(2011,  1,  9,  9,  0,  0).relative_in_words # Sunday
      assert_equal "in etwa einer Woche",  Time.new(2011,  1, 10,  9,  0,  0).relative_in_words # Monday
      assert_equal "in etwa 2 Wochen",     Time.new(2011,  1, 16,  9,  0,  0).relative_in_words # Sunday
    end
  end

  test "BigDecimal should be properly formatted" do

    # Note the differences between the Rails' .to_s and our .to_s_significant.

    assert_equal '1.0003', BigDecimal.new('1.0003').to_s
    assert_equal '1.0', BigDecimal.new('1').to_s
    assert_equal '1.0', BigDecimal.new('1.0').to_s
    assert_equal '100.3', BigDecimal.new('100.3').to_s
    assert_equal '100.3', BigDecimal.new('100.300').to_s
    assert_equal '100.301', BigDecimal.new('100.301').to_s
    assert_equal '100.31', BigDecimal.new('100.31').to_s

    assert_equal '1', BigDecimal.new('1.0003').to_s_significant
    assert_equal '1', BigDecimal.new('1.0003').to_s_significant(decimals: 2)
    assert_equal '1.0003', BigDecimal.new('1.0003').to_s_significant(decimals: 4)
    assert_equal '1', BigDecimal.new('1').to_s_significant
    assert_equal '1', BigDecimal.new('1.0').to_s_significant
    assert_equal '100.3', BigDecimal.new('100.3').to_s_significant
    assert_equal '100.3', BigDecimal.new('100.300').to_s_significant
    assert_equal '100.3', BigDecimal.new('100.3001').to_s_significant
    assert_equal '100.301', BigDecimal.new('100.301').to_s_significant

    assert_equal 'CHF 1.00', BigDecimal.new('1.0003').to_s_currency
    assert_equal '1,00 €', BigDecimal.new('1.0003').to_s_currency(locale: :fr)
    assert_equal 'CHF 1', BigDecimal.new('1.0003').to_s_currency(decimals: 0)
    assert_equal 'CHF 1.0003', BigDecimal.new('1.0003').to_s_currency(decimals: 4)
    assert_equal 'CHF 1.00', BigDecimal.new('1').to_s_currency
    assert_equal 'CHF 1.00', BigDecimal.new('1.0').to_s_currency
    assert_equal 'CHF 100.30', BigDecimal.new('100.3').to_s_currency
    assert_equal 'CHF 100.30', BigDecimal.new('100.300').to_s_currency
    assert_equal 'CHF 100.30', BigDecimal.new('100.3001').to_s_currency
    assert_equal 'CHF 100.301', BigDecimal.new('100.301').to_s_currency(decimals: 3)
  end

  test "numbers should have pos? and neg? predicates" do
    assert_equal true,  1.pos?
    assert_equal false, 1.neg?
    assert_equal true,  0.1.pos?
    assert_equal false, 0.1.neg?
    assert_equal true,  BigDecimal('1').pos?
    assert_equal false, BigDecimal('1').neg?
    assert_equal true,  (100**100).pos?
    assert_equal false, (100**100).neg?

    assert_equal false, 0.pos?
    assert_equal false, 0.neg?
    assert_equal false, 0.0.pos?
    assert_equal false, 0.0.neg?
    assert_equal false, BigDecimal('0').pos?
    assert_equal false, BigDecimal('0').neg?

    assert_equal false, -1.pos?
    assert_equal true,  -1.neg?
    assert_equal false, -0.1.pos?
    assert_equal true,  -0.1.neg?
    assert_equal false, BigDecimal('-1').pos?
    assert_equal true,  BigDecimal('-1').neg?
    assert_equal false, (-1 * 100**100).pos?
    assert_equal true,  (-1 * 100**100).neg?
  end

  test "truncate strings at a natural point" do
    lorem = 'Lorem ipsum dolor sit amet, consetetur. Sadipscing elit, sed diam.'
    assert_equal 'Lorem ipsum dolor sit amet, consetetur...',
                  lorem.truncate_naturally
    assert_equal 'Lorem...',
                  lorem.truncate_naturally(at: 10)
    assert_equal 'Lorem...',
                  lorem.truncate_naturally(at: 13)
    assert_equal 'Lorem ipsum...',
                  lorem.truncate_naturally(at: 14)
    assert_equal 'Lorem ipsum dolor sit...',
                  lorem.truncate_naturally(at: 26)
    assert_equal 'Lorem ipsum dolor sit amet...',
                  lorem.truncate_naturally(at: 29)
    assert_equal 'Lorem ipsum dolor sit amet...',
                  lorem.truncate_naturally(at: 32)
  end
end
