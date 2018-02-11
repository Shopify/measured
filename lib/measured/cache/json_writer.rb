module Measured::Cache::JsonWriter
  def write(table)
    File.open(@path, "w") do |f|
      f.write("// Do not modify this file directly. Regenerate it with 'rake cache:write'.\n")
      f.write(encode(table).to_json)
    end
  end
end
