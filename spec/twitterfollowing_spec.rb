require_relative '../lib/TwitterFollowing.rb'

Rspec.describe TwitterFollowing do
  describe '#new' do
    it 'Accepts a client' do
      expected = 'client'
      following = TwitterFollowing.new({}, {}, expected)
      expect(following.client).to eq(expected)
    end
  end
end
