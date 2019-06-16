#!/usr/bin/env ruby

require 'measured'
require 'erb'

require 'benchmark/ips'

# Use measurable to produce an HTML conversion table between meters and feet.
# Write the output to /dev/null so that it cannot be optimised away and we
# simulate actually sending it down an IO connection as it would be in a web
# service.

template = ERB.new <<~ERB
  <html>
  <head>
      <title>Conversion</title>
  </head>
  <body>
    <table>
      <tr>
        <td><%= ref = Measured::Length.new(1, a) %></td>
        <td><%= ref.convert_to(b) %></td>
      </tr>
      <tr>
        <td><%= ref = Measured::Length.new(1, b) %></td>
        <td><%= ref.convert_to(a) %></td>
      </tr>
    <table>
  </body>
  </html>
ERB

null = File.open('/dev/null', 'w')

a = 'meter'
b = 'foot'

# Write once to a file so you can see what the result is.
File.write 'out.html', template.result(binding)

Benchmark.ips do |x|

  x.iterations = 3
  
  x.report('macro') do
    null.write template.result(binding)
  end

end
