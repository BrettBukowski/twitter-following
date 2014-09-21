require 'term/ansicolor'
require 'commander/import'
require_relative 'lib/TwitterFollowing.rb'
require_relative 'lib/Cache.rb'

program :version, "1.0.0"
program :description, "Everyone you follow on Twitter"

command :list do |c|
  c.syntax = "#{__FILE__} list [options]"
  c.description = "List the Twitter users you're following (ordered by when you followed users, most recent first)"
  c.option "--inactive DAYS", Integer, "Show following users that haven't tweeted since at least the specified number of days"
  c.action do |args, options|
    lister = twitter_following
    lister.since = options.inactive
    lister.output_following
  end
end

command :unfollow do |c|
  c.syntax = "#{__FILE__} unfollow [options]"
  c.description = "Unfollow Twitter users who haven't posted in a number of days"
  c.option "--inactive DAYS", Integer, "Show following users that haven't tweeted since at least the specified number of days"
  c.action do |args, options|
    lister = twitter_following

    if !options.inactive
      $stderr.puts "The --inactive option is required"
      exit -1
    end

    lister.since = options.inactive
    lister.unfollow!
  end
end

def load_config
  config = YAML.load(IO.read('config.yml'))

  if config.values.include? ''
    $stderr.puts 'Invalid config.yml. Create an app at <https://apps.twitter.com> and copy in the values.'
    exit -1
  end

  config['cache_file'] = File.absolute_path(config['cache_file'])

  config
end

def twitter_following
  config = load_config
  TwitterFollowing.new(config['twitter'], Cache.new(config))
end
