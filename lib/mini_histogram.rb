require "mini_histogram/version"
require 'math'

module MiniHistogram
 class Error < StandardError; end

  extend Math # log2, log10

  def self.sturges(ary)
    len = ary.length
    return 1.0 if len == 0

    # return (long)(ceil(log2(n)) + 1);
    return log2(len).ceil + 1
  end

  # Given an array of edges and an array we want to generate a histogram from
  # return the counts for each "bin"
  #
  # Example:
  #
  #   a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
  #   edges = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
  #
  #   MiniHistogram.counts_from_edges(a, edges: edges)
  #   # => [3, 0, 4, 0, 0, 3]
  #
  #   This means that the `a` array has 3 values between 0.0 and 2.0
  #   4 values between 4.0 and 6.0 and three values between 10.0 and 12.0
  def self.counts_from_edges(array, edges:, left_p: false)
    bins = Array.new(edges.length - 1, 0)
    lo = edges.first
    step = edges[1] - edges[0]

    array.each do |x|
      index = ((x - lo) / step).floor
      bins[index] += 1
    end

    return bins
  end

  # Finds the "edges" of a given histogram that will mark the boundries
  # for the histogram's "bins"
  #
  # Example:
  #
  #  a = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
  #  MiniHistogram.edges(a)
  #  # => [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
  #
  #  There are multiple ways to find edges, this was taken from
  #  https://github.com/mrkn/enumerable-statistics/issues/24
  #
  #  Another good set of implementations is in numpy
  #  https://github.com/numpy/numpy/blob/d9b1e32cb8ef90d6b4a47853241db2a28146a57d/numpy/lib/histograms.py#L222
  def self.edges(array, left_p: false)
    hi = array.max
    lo = array.min

    nbins = sturges(array) * 1.0

    if hi == lo
      start = hi
      step = 1.0
      divisor = 1.0
      len = 1.0
    else
      bw = (hi - lo) / nbins
      lbw = log10(bw)
      if lbw >= 0
        step = 10 ** lbw.floor * 1.0
        r = bw/step

        if r <= 1.1
          # do nothing
        elsif r <= 2.2
          step *= 2.0
        elsif r <= 5.5
          step *= 5.0
        else
          step *= 10
        end
        divisor = 1.0
        start = step * (lo/step).floor
        len = ((hi - start)/step).ceil
      else
        divisor = 10 ** - lbw.floor
        r = bw * divisor
        if r <= 1.1
          # do nothing
        elsif r <= 2.2
          divisor /= 2.0
        elsif r <= 5.5
          divisor /= 5.0
        else
          divisor /= 10.0
        end
        step = 1.0
        start = (lo * divisor).floor
        len = (hi * divisor - start).ceil
      end

      if left_p
        while (lo < start/divisor)
          start -= step
        end

        while (start + (len - 1)*step)/divisor <= hi
          len += 1
        end
      else
        while lo <= start/divisor
          start -= step
        end
        while (start + (len - 1)*step)/divisor < hi
          len += 1
        end
      end

      edge = []
      len.next.times.each do
        edge << start/divisor
        start += step
      end
      return edge
    end
  end

  # Private class used to insert count values for a histogram
  # each instance represents a node in a tree, each node
  # represents a "bin" in a histogram. Essentially a high value
  # and a low value. When we count elements in our histogram
  # we count them per bin i.e. whether the number fits between
  # the high and low values. Using a tree structure we can
  # build a binary search to figure out which bin a given
  # value would fall into, then once found we increment the count
  #
  # As i'm writing this out, i'm realizing we don't need to search
  # since the step size is normalized, we know the value is between
  # a high and low range and we know the range, we could instead
  # subtract the low value, then divide by the range, floor it and
  # we should have our index. I'm not totally sure if that would
  # work, but it should be faster than a search
  #
  # Annnnnnnnnd it's way faster to not do the search
  #
  # Before:
  #
  #  enumerable stats:     9335.9 i/s
  #  mini histogram  :     3669.4 i/s - 2.54x  slower
  #
  # After:
  #
  #   enumerable stats:     9375.9 i/s
  #   mini histogram  :     7234.9 i/s - 1.30x  slower
  #
  # Thats 1.97x faster. Sure, still not as fast as a C extension
  # but it's quite the improvement
  #
  # This class isn't used currently now
  class BinaryBinTree
    attr_accessor :lo, :hi, :child_lo, :child_hi, :count

    def initialize(lo:, hi:)
      @lo = lo
      @hi = hi
      @child_lo = nil
      @child_hi = nil
      @count = 0
    end

    def to_s
      [@lo, @hi].to_s
    end

    # The meat and potatoes, increments count if
    # the value is between it's high and low, otherwise
    # it traverses down the tree to find a valid node
    #
    # node.hi # => 10
    # node.lo # => 0
    #
    # node.count # => 41
    # node.insert(5)
    # node.count # => 42
    def insert(x)
      if x < hi
        if x >= lo
          @count += 1
        else
          child_lo.insert(x)
        end
      else
        child_hi.insert(x)
      end
    end

    # Builds a binary search tree from a sorted array
    def self.sorted_array_to_bst(array, start_index, end_index)
      return false if start_index > end_index
      mid_index = ((start_index + end_index)/2.0).floor
      root = array[mid_index]
      root.child_hi = sorted_array_to_bst(array, mid_index + 1, end_index)
      root.child_lo = sorted_array_to_bst(array, start_index, mid_index - 1)
      return root
    end
  end
  private_constant :BinaryBinTree

end
