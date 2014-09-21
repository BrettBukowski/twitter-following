# Twitter Following

List and prune who you're following on Twitter via a CLI.

Handy if you want to prune who you follow, follow a lot of people, and don't want to wade through twitter.com's infinite-scroll following page.

Inspired by [twitter-cleaner](https://github.com/apassant/twitter-cleaner).


### Prereqs

Ruby and the Bundler gem.

### Setup

1. Create a Twitter app at <https://apps.twitter.com>.
2. Go to <https://apps.twitter.com/app/[appid]/keys> and copy out the "API key", "API secret", "Access token", and "Access token secret" values into `config.yml`.
3. `bundle`
4. `./following.rb`

### Notes

Twitter's API is [rate limited](https://dev.twitter.com/rest/public/rate-limiting). So if you follow a lot of accounts, it may take awhile to get the full list. The script sleeps until it's safe to begin making API requests again.

_By default, your following list is cached for 48 hours_.


![](http://i.imgur.com/vwzr8Io.gif)
