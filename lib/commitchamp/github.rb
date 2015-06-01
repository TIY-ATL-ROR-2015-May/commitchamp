require 'httparty'

module Commitchamp
  class Github
    include HTTParty
    base_uri "https://api.github.com"

    def initialize(access_token)
      @headers = {
        "Authorization" => "token #{access_token}",
        "User-Agent"    => "HTTParty"
      }
    end

    def get_user(username)
      self.class.get("/users/#{username}",
                     headers: @headers)
    end

    def get_contributors(owner, repo)
      self.class.get("/repos/#{owner}/#{repo}/stats/contributors",
                     headers: @headers)
    end

    # def extract_stat(contributor, stat_name)
    #   contributor['weeks'].map { |x| x[stat_name] }.sum
    # end
  end
end
