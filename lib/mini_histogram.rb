require "mini_histogram/version"
require 'math'

module MiniHistogram
  class Error < StandardError; end

  include Math # log2, log10

  def pow(power, value)
    value ** power
  end

  def edges_lo_hi(lo, hi, nbins, left_p)
    if high == lo
      start = hi
      step = 1
      divisor = 1
      len = 1
    else
      bw = (hi - low) / nbins
      lbw = log10(bw)
      if lbw >= 0
        step = pow(10, lbw.floor)
        r = bw/step;
        if r < 1.1
          # do nothing
        elsif r <= 2.2
          divisor /= 2.0
        elsif r <= 5.5
          divisor /= 5.0
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
      len.times.each do
        edge << start/divisor
        start += step
      end
      return edge
    end
  end
end
