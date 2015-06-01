$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pry'

require 'commitchamp/version'
require 'commitchamp/init_db'
require 'commitchamp/github'

module Commitchamp
  class App
    def initialize
      if ENV['OAUTH_TOKEN']
        token = ENV['OAUTH_TOKEN']
      else
        token = get_auth_token
      end
      @github = Github.new(token)
    end

    def prompt(question, validator)
      puts question
      input = gets.chomp
      until input =~ validator
        puts "Sorry, didn't understand that answer."
        puts question
        input = gets.chomp
      end
      input
    end

    def get_auth_token
      prompt("Please enter your personal access token for Github: ",
            /^[0-9a-f]{40}$/)
    end

    def import_contributors(repo_name)
      repo = Repo.first_or_create(name: repo_name)
      results = @github.get_contributors('redline6561', repo_name)
      results.each do |contributor|
        user = User.first_or_create(name: contributor['author']['login'])
        lines_added = contributor['weeks'].map { |x| x['a'] }.sum
        lines_deleted = contributor['weeks'].map{ |x| x['d'] }.sum
        commits_made = contributor['weeks'].map { |x| x['c'] }.sum
        # Contribution.create(user_id: user.id,
        #                      lines_added: lines_added,
        #                      lines_deleted: lines_deleted,
        #                      commits_made: commits_made,
        #                      repo_id: repo.id)


        user.contributions.create(lines_added: lines_added,
                                  lines_deleted: lines_deleted,
                                  commits_made: commits_made,
                                  repo_id: repo.id)
      end
    end
  end
end

app = Commitchamp::App.new
binding.pry
