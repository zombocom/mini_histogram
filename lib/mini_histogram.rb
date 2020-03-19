require "mini_histogram/version"
require 'math'

module MiniHistogram
 class Error < StandardError; end

  extend Math # log2, log10

  # Weird name, right? There are multiple ways to
  # calculate the number of "bins" a histogram should have, one
  # of the most common is the "sturges" method
  #
  # Here are some alternatives from numpy:
  # https://github.com/numpy/numpy/blob/d9b1e32cb8ef90d6b4a47853241db2a28146a57d/numpy/lib/histograms.py#L489-L521
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
    lo = edges.first
    step = edges[1] - edges[0]

    max_index = ((array.max  - lo) / step).floor
    bins = Array.new(max_index + 1, 0)

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
end
