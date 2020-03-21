# MiniHistogram

What's a histogram and why should you care? First read [Lies, Damned Lies, and Averages: Perc50, Perc95 explained for Programmers](https://schneems.com/2020/03/17/lies-damned-lies-and-averages-perc50-perc95-explained-for-programmers/). This library lets you build histograms in pure Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_histogram'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mini_histogram

## Usage

Given an array, this class calculates the "edges" of a histogram these edges mark the boundries for "bins"

```ruby
array = [1,1,1, 5, 5, 5, 5, 10, 10, 10]
histogram = MiniHistogram.new(array)
puts histogram.edges
# => [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0]
```

It also finds the weights (aka count of values) that would go in each bin:

```
puts histogram.weights
# => [3, 0, 4, 0, 0, 3]
```

This means that the `array` here had three items between 0.0 and 2.0, four items between 4.0 and 6.0 and three items between 10.0 and 12.0

Alternatives to this gem include https://github.com/mrkn/enumerable-statistics/. I needed this gem to be able to calculate a "shared" or "average" edge value as seen in this PR https://github.com/mrkn/enumerable-statistics/pull/23. So that I could add histograms to derailed benchmarks: https://github.com/schneems/derailed_benchmarks/pull/169. This gem provides a `MiniHistogram.set_average_edges!` method to help there. Also this gem does not require a native extension compilation (faster to install, but performance is slower), and this gem does not extend or monkeypatch an core classes.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zombocom/mini_histogram. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/zombocom/mini_histogram/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MiniHistogram project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zombocom/mini_histogram/blob/master/CODE_OF_CONDUCT.md).
