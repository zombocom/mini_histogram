require "mini_histogram/version"
require 'math'

module MiniHistogram
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
  class Error < StandardError; end

  extend Math # log2, log10

  def self.sturges(ary)
    len = ary.length
    return 1.0 if len == 0

    # return (long)(ceil(log2(n)) + 1);
    return log2(len).ceil + 1
  end

  def self.counts_from_edges(array, edges:, left_p: false)
    bins = []
    edges = edges.dup
    last = edges.shift
    while edges.any?
      bins << BinaryBinTree.new(lo: last, hi: edges.first)
      last = edges.shift
    end

    root = BinaryBinTree.sorted_array_to_bst(bins, 0, bins.length - 1)

    array.each do |x|
      root.insert(x)
    end

    return bins.map(&:count)
  end

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
