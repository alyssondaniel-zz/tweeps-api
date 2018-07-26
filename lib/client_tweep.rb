require 'net/http'

module ClientTweep
  class Api
    attr_accessor :headers, :client
    LOCAWEBER_ID = 42

    def initialize(username = "", url = "")
      @headers  = { "Username" => (username.empty? ? ENV['TWEEP_HTTP_USERNAME'] : username) }
      @uri      = URI.parse((url.empty? ? ENV['TWEEP_BASE_URL'] : url))
      @client   = Net::HTTP.new(@uri.host, @uri.port)
    end

    def most_relevants(tweeps)
      tweeps.select do |tweep|
        locaweber_mention = tweep['entities']['user_mentions'].any? { |u| u['id'] == LOCAWEBER_ID }
        reply_to_locaweber = tweep['in_reply_to_user_id'] == LOCAWEBER_ID
        locaweber_mention && !reply_to_locaweber
      end
    end

    def most_mentions(tweeps)
      users = tweeps.map { |t| t["user"] }.uniq
      users_with_tweets = users.map do |user|
        user_tweets = tweeps.select { |t| t["user"]["screen_name"] == user["screen_name"] }
        user.merge(tweeps: user_tweets)
      end
      users_with_tweets.sort_by { |u| !u[:tweeps].size }
    end

    def by_order(tweeps = [])
      tweeps.sort_by do |tweep|
        (tweep['user']['followers_count'].to_i * 10) + tweep['retweet_count'].to_i + tweep['favorite_count'].to_i
      end.reverse
    end

    def getAll(params = {})
      response = @client.send_request("GET", @uri.path, params.to_json, @headers)
      data = JSON.parse(response.body)
      data['statuses'] || []
    end
  end

  class TweepResource
    def self.from_json(data)
      return if data.blank?
      {
        followers_count: data["user"]["followers_count"] || 0,
        screen_name: data["user"]["screen_name"],
        profile_link: "https://twitter.com/#{data["user"]["screen_name"]}",
        created_at: data["created_at"],
        link: "https://twitter.com/#{data["user"]["screen_name"]}/status/#{data["user"]["id_str"]}",
        retweet_count: (data["retweet_count"] || 0),
        text: data["text"],
        favorite_count: (data["favorite_count"] || 0)
      }
    end
  end

  class UserResource
    attr_accessor :screen_name, :tweeps

    def self.from_json(data)
      return if data.blank?

      {
        data["screen_name"].parameterize.underscore.to_sym => data[:tweeps].map{|t| TweepResource.from_json(t)}
      }
    end
  end

end