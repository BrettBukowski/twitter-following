require 'yaml'
require 'date'
require 'twitter'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end


class TwitterFollowing
  attr_accessor :since, :config, :cache, :client

  def initialize(config, cache, client = nil)
    @config = config
    @cache = cache
    @client = client || initialize_client
  end

  def following
    @following ||= cache.cache do
      get_following_with_cursor
    end
  end

  def output_following
    following.each do |followee|
      time_since = TwitterFollowing.last_tweet(followee)

      next if !since.nil? && (time_since[:unit] != :day || time_since[:interval] < since)

      output_user(folowee, true, time_since)
    end
  end

  def output_user(user, full = true, relative_time_interval = nil)
      puts "@#{followee[:screen_name]}".bold + " (#{followee[:name]}) " + "<https://twitter.com/#{followee[:screen_name]}>".magenta

      if full
        puts "Followers:" + " #{followee[:followers_count]}".blue + " Following: " + "#{followee[:friends_count]}".blue
        puts "#{followee[:description]}" unless followee[:description].empty?
        puts ("Last tweet was " + "#{relative_time_interval[:interval]} #{relative_time_interval[:unit].to_s}s".underline + " ago")
        puts ""
      end
  end

  def unfollow!
    raise "since is required" unless since

    to_unfollow = following.reject_if do |followee|
      time_since = TwitterFollowing.last_tweet(followee)

      time_since[:unit] != :day || time_since[:interval] < since
    end

    if to_unfollow.empty?
      puts "Unfollowed no one"
      return
    end

    client.unfollow(to_unfollow.map {|user| user[:user_id] })

    puts "Unfollowed:".green

    to_unfollow.each(&:output_user)
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
      following = client.following(:cursor => cursor)
    rescue Twitter::Error::TooManyRequests => error
      puts "Twitter rate limit error - sleeping for #{error.rate_limit.reset_in} seconds before continuing...".yellow
      sleep error.rate_limit.reset_in
      retry
    end

    following
  end

  def initialize_client()
    Twitter::REST::Client.new do |client_config|
      config.each do |key, value|
        client_config.send("#{key}=", value)
      end
    end
  end
end
