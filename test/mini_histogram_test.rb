require "test_helper"

class MiniHistogramTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniHistogram::VERSION
  end

  def test_thing
    a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    edges = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
    actual = MiniHistogram.new(a).counts_from_edges(edges: edges)
    expected = [3, 0, 4, 0, 0, 3]
    assert_equal expected, actual
  end

  def test_it_does_something_useful
    a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    actual = MiniHistogram.new(a).sturges
    assert_equal 5, actual

    actual = MiniHistogram.new(a).edges

    expected = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
    assert_equal expected, actual

    b = [7, 7, 7, 12, 12, 12, 12, 20, 20, 20]
    actual = MiniHistogram.new(b).edges
    expected = [5.0, 10.0, 15.0, 20.0, 25.0]
  end
end
