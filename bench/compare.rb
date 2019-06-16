#!/usr/bin/env ruby

require 'measured'

require 'benchmark/ips'

# Comparing the various ways to create a measurement.

Benchmark.ips do |x|

  x.iterations = 3

  x.report('new(fix, str)') do
    Measured::Length.new(14, 'meter')
  end

  x.report('new(fix, sym)') do
    Measured::Length.new(14, :meter)
  end

  x.report('shortcut') do
    Measured::Length(14, :meter)
  end

  x.report('parse(str)') do
    Measured::Length.parse('14 meter')
  end

  x.compare!

end
