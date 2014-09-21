require 'yaml'
require 'date'
require 'twitter'

class String
  include Term::ANSIColor
end


class Cleaner
  attr_accessor :since

  def initialize(config, cache)
    @config = config
    @client = client
    @cache = cache
  end

  def following
    @following ||= @cache.cache do
      get_following_with_cursor
    end
  end

  def output_following
    following.each do |followee|
      if !since.nil?
        time_since = Cleaner.last_tweet(followee)
        next if time_since[:unit] != :day || time_since[:interval] < since
      end

      puts "@#{followee[:screen_name]}".bold + " (#{followee[:name]}) " + "<https://twitter.com/#{followee[:screen_name]}>".magenta
      puts "Followers:" + " #{followee[:followers_count]}".blue + " Following: " + "#{followee[:friends_count]}".blue
      puts "#{followee[:description]}" unless followee[:description].empty?
      puts ("Last tweet was " + "#{time_since[:interval]} #{time_since[:unit].to_s}s".underline + " ago")
      puts ""
    end
  end

  private

  def self.last_tweet(user)
    time = DateTime.parse(user[:status][:created_at])
    since = Time.now - time.to_time

    units = {
      second: 60,
      minute: 60,
      hour: 24,
      day: nil,
    }

    units.each do |unit, number|
      return { interval: since.ceil, unit: unit } if number.nil? || since < number
      since /= number
    end
  end

  def get_following_with_cursor(cursor = -1, list = [])
    puts "getting cursor #{cursor}"
    return list if cursor == 0

    results = following_cursor(cursor)
    list.concat(results.attrs[:users])
    get_following_with_cursor(results.attrs[:next_cursor], list)
  end

  def following_cursor(cursor)
    begin
      following = @client.following(:cursor => cursor)
    rescue Twitter::Error::TooManyRequests => error
      puts "Twitter rate limit error - sleeping for #{error.rate_limit.reset_in} seconds before continuing...".yellow
      sleep error.rate_limit.reset_in
      retry
    end

    following
  end

  def client()
    Twitter::REST::Client.new do |config|
      @config.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end
end
