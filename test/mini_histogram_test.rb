require "test_helper"

class MiniHistogramTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniHistogram::VERSION
  end

  def test_average_edges
    a = MiniHistogram.new [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    b = MiniHistogram.new [7, 7, 7, 12, 12, 12, 12, 20, 20, 20]

    MiniHistogram.set_average_edges!(a, b)

    expected = [0.0, 3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0]
    assert_equal expected, a.edges
    assert_equal expected, b.edges
  end

  def test_weights
    a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    edges = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
    actual = MiniHistogram.new(a, edges: edges).weights
    expected = [3, 0, 4, 0, 0, 3]
    assert_equal expected, actual

    actual = MiniHistogram.new(a).weights
    assert_equal expected, actual
  end

  def test_find_edges
    a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    actual = MiniHistogram.new(a).sturges
    assert_equal 5, actual

    actual = MiniHistogram.new(a).edges
    expected = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
    assert_equal expected, actual

    b = [7, 7, 7, 12, 12, 12, 12, 20, 20, 20]
    actual = MiniHistogram.new(b).edges
    expected = [5.0, 10.0, 15.0, 20.0, 25.0]
    assert_equal expected, actual
  end
end
