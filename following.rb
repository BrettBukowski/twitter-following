#!/usr/bin/ruby

require 'optparse'
require 'term/ansicolor'
require_relative 'lib/cleaner.rb'
require_relative 'lib/cache.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: following.rb [options]"

  opts.on("-l", "--list", "List followers") do |l|
    options['list'] = l
  end

  opts.on("--last [Days]", Integer, "Show followers that haven't tweeted since at least the specified number of days") do |days|
    options['since'] = days
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!


def load_config
  config = YAML.load(IO.read('config.yml'))

  if config.values.include? ''
    $stderr.puts 'Invalid config.yml. Create an app at <https://apps.twitter.com> and plug in the values.'.red
    exit -1
  end

  config['cache_file'] = File.absolute_path(config['cache_file'])

  config
end

config = load_config.merge(options)
cache = FollowerCache.new(config)
cleaner = Cleaner.new(config['twitter'], cache)

if options['since']
  cleaner.since = options['since']
end
if options['list']
  cleaner.output_following
end
