require "test_helper"

class MiniHistogramTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniHistogram::VERSION
  end

  def test_it_does_something_useful
    a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    actual = MiniHistogram.sturges(a)
    assert_equal 5, actual

    actual = MiniHistogram.edges(a)

    expected = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
    assert_equal expected, actual

    b = [7, 7, 7, 12, 12, 12, 12, 20, 20, 20]
    actual = MiniHistogram.edges(b)
    expected = [5.0, 10.0, 15.0, 20.0, 25.0]
  end
end
