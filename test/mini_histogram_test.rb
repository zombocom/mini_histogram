require "test_helper"
# require "enumerable/statistics"

class MiniHistogramTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MiniHistogram::VERSION
  end

  def test_corner_cases
    expected_edge = [0.0]
    expected_weights = []

    a = MiniHistogram.new []
    assert_equal expected_edge, a.edges
    assert_equal expected_weights, a.weights

    MiniHistogram.set_average_edges!(a, a)
    assert_equal expected_edge, a.edges
    assert_equal expected_weights, a.weights

    expected_edge = [1.1, 2.1]
    expected_weights = [1]

    a = MiniHistogram.new [1.1]
    assert_equal expected_edge, a.edges
    assert_equal expected_weights, a.weights

    MiniHistogram.set_average_edges!(a, a)
    assert_equal expected_edge, a.edges
    assert_equal expected_weights, a.weights
  end

  def test_averaging_edges_has_the_same_weight_and_edge_length
    a = MiniHistogram.new [11.205184, 11.223665, 11.228286, 11.23219, 11.233325, 11.234516, 11.245781, 11.248441, 11.250758, 11.255686, 11.265876, 11.26641, 11.279456, 11.281067, 11.284281, 11.287656, 11.289316, 11.289682, 11.292289, 11.294518, 11.296454, 11.299277, 11.305801, 11.306602, 11.309311, 11.318465, 11.318477, 11.322258, 11.328267, 11.334188, 11.339722, 11.340585, 11.346084, 11.346197, 11.351863, 11.35982, 11.362358, 11.364476, 11.365743, 11.368492, 11.368566, 11.36869, 11.37268, 11.374204, 11.374217, 11.374955, 11.376422, 11.377989, 11.383357, 11.383593, 11.385184, 11.394766, 11.395829, 11.398455, 11.399739, 11.401304, 11.411387, 11.411978, 11.413585, 11.413659, 11.418504, 11.419194, 11.419415, 11.421374, 11.4261, 11.427901, 11.429651, 11.434272, 11.435012, 11.440848, 11.447495, 11.456107, 11.457434, 11.467112, 11.471005, 11.473235, 11.485025, 11.485852, 11.488256, 11.488275, 11.499545, 11.509588, 11.51378, 11.51544, 11.520783, 11.52246, 11.522855, 11.5322, 11.533764, 11.544047, 11.552597, 11.558062, 11.567239, 11.569749, 11.575796, 11.588014, 11.614032, 11.615062, 11.618194, 11.635267]
    b = MiniHistogram.new [11.233813, 11.240717, 11.254617, 11.282013, 11.290658, 11.303213, 11.305237, 11.305299, 11.306397, 11.313867, 11.31397, 11.314444, 11.318032, 11.328111, 11.330127, 11.333235, 11.33678, 11.337799, 11.343758, 11.347798, 11.347915, 11.349594, 11.358198, 11.358507, 11.3628, 11.366111, 11.374993, 11.378195, 11.38166, 11.384867, 11.385235, 11.395825, 11.404434, 11.406065, 11.406677, 11.410244, 11.414527, 11.421267, 11.424535, 11.427231, 11.427869, 11.428548, 11.432594, 11.433524, 11.434903, 11.437769, 11.439761, 11.443437, 11.443846, 11.451106, 11.458503, 11.462256, 11.462324, 11.464342, 11.464716, 11.46477, 11.465271, 11.466843, 11.468789, 11.475492, 11.488113, 11.489616, 11.493736, 11.496842, 11.502074, 11.511367, 11.512634, 11.515562, 11.525771, 11.531415, 11.535379, 11.53966, 11.540969, 11.541265, 11.541978, 11.545301, 11.545533, 11.545701, 11.572584, 11.578881, 11.580701, 11.580922, 11.588731, 11.594082, 11.595915, 11.613622, 11.619884, 11.632889, 11.64377, 11.645225, 11.647167, 11.648257, 11.667158, 11.670378, 11.681261, 11.734586, 11.747066, 11.792425, 11.808377, 11.812346]

    MiniHistogram.set_average_edges!(a, b)

    assert_equal a.edges.length, b.edges.length
    assert_equal a.weights.length, b.weights.length
  end

  def test_average_edges
    a = MiniHistogram.new [1,1,1, 5, 5, 5, 5, 10, 10, 10]
    b = MiniHistogram.new [7, 7, 7, 12, 12, 12, 12, 20, 20, 20]

    MiniHistogram.set_average_edges!(a, b)

    expected = [0.0, 3.5, 7.0, 10.5, 14.0, 17.5, 21.0, 24.5, 28.0]
    assert_equal expected, a.edges
    assert_equal expected, b.edges
    assert_equal expected, b.edge
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
