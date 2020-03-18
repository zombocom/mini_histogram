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
