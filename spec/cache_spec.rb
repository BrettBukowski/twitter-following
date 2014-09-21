require_relative '../lib/Cache.rb'

RSpec.describe Cache do
  describe '#new' do
    it 'Sets instance variables based on hash with string keys' do
      cache = Cache.new({'cache_file' => 'bop', 'cache_time' => 'it'})
      expect(cache.cache_file).to eq('bop')
      expect(cache.cache_time).to eq('it')
    end
  end

  describe '#cache' do
    it 'Yields the block and writes the result if the cache file does not exist' do
      expected = 'return val'

      expect(File).to receive(:exists?).and_return(false)
      expect(IO).to receive(:write).with('cachefile', Marshal::dump(expected))
      cache = Cache.new({'cache_file' => 'cachefile'})
      result = cache.cache { expected }
      expect(result).to eq(expected)
    end

    it 'Yields the block and writes the result if the cache file ctime is older than cache_tile' do
      expected = 'return val'

      expect(File).to receive(:exists?).and_return(true)
      expect(File).to receive(:ctime).with('cachefile').and_return(Time.now - 600000)
      expect(IO).to receive(:write).with('cachefile', Marshal::dump(expected))
      cache = Cache.new({'cache_file' => 'cachefile', 'cache_time' => 1})
      result = cache.cache { expected }
      expect(result).to eq(expected)
    end

    it 'Returns cached results instead of yielding the block' do
      expected = 'cached'

      expect(File).to receive(:exists?).and_return(true)
      expect(File).to receive(:ctime).with('cachefile').and_return(Time.now)
      expect(IO).to_not receive(:write)
      expect(IO).to receive(:read).with('cachefile').and_return(Marshal::dump(expected))
      cache = Cache.new({'cache_file' => 'cachefile', 'cache_time' => 1})
      result = cache.cache { 'return val' }
      expect(result).to eq(expected)
    end
  end
end
