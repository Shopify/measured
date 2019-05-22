# frozen_string_literal: true
module Measured::Cache::JsonWriter
  def write(table)
    File.open(@path, "w") do |f|
      f.write("// Do not modify this file directly. Regenerate it with 'rake cache:write'.\n")
      f.write(JSON.pretty_generate(encode(table)))
    end
  end
end
