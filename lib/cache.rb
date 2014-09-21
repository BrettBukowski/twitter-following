
class FollowerCache
  def initialize(options = {})
    @cache_file = options['cache_file']
    @cache_time = options['cache_time']
  end

  def cache(&block)
    already_cached = cached
    if !already_cached.nil?
      return already_cached
    end
    write_to_cache(yield)
  end

  private

  def write_to_cache(to_cache)
    serialized = Marshal::dump(to_cache)
    IO.write(@cache_file, serialized)
    to_cache
  end

  def cached
    if File.exists?(@cache_file) && (Time.now - File.ctime(@cache_file)) / 3600 < @cache_time
      Marshal::load(IO.read(@cache_file))
    end
  end
end
