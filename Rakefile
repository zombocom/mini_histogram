require "bundler/gem_tasks"
require "rake/testtask"

$LOAD_PATH.unshift File.expand_path("./lib", __dir__)

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test


task :bench do
  array = 1000.times.map { rand }

  require 'benchmark/ips'
  require 'enumerable/statistics'
  require 'mini_histogram'

  Benchmark.ips do |x|
    x.report("enumerable stats") { array.histogram }
    x.report("mini histogram  ") {
      edges = MiniHistogram.edges(array)
      MiniHistogram.counts_from_edges(array, edges: edges)
    }
    x.compare!
  end
end
