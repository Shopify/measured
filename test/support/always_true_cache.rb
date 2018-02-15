class AlwaysTrueCache
  def exist?
    true
  end

  def read
    {}
  end

  def write(*)
    nil
  end
end
