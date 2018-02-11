module Measured::Cache
  class Null
    def exist?
      false
    end

    def read
      nil
    end

    def write(table)
      nil
    end
  end
end
