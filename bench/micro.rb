#!/usr/bin/env ruby

require 'measured'

require 'benchmark/ips'

# Microbenchmarks extracted from the macrobenchmark - not much to stop these
# optimising away so be careful.

Benchmark.ips do |x|

  x.iterations = 3

  # These are the top-level operations we use.

  x.report('new') do
    Measured::Length.new(14, 'meter')
  end

  meters = Measured::Length.new(14, 'meter')

  x.report('convert_to') do
    meters.convert_to('foot')
  end

  x.report('to_s') do
    meters.to_s
  end

  # Some other interesting operations not in the macrobenchmark.

  feet = Measured::Length.new(2, 'feet')

  x.report('sum') do
    meters + feet
  end

  # These don't involve measurement, but lets include them to separate them
  # from everything else in the macrobenchmark.
  
  template = ERB.new <<~ERB
    <html>
    <head>
      <title>Conversion</title>
    </head>
    <body>
      <table>
        <tr>
          <td><%= a %></td>
          <td><%= b %></td>
        </tr>
        <tr>
          <td><%= b %></td>
          <td><%= a %></td>
        </tr>
      <table>
    </body>
    </html>
  ERB

  a = 'a'
  b = 'b'

  x.report('erb') do
    template.result(binding)
  end

  null = File.open('/dev/null', 'w')
  result = template.result(binding)

  x.report('write') do
    null.write result
  end

end
