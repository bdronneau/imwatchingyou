require 'octokit'
require 'pp'

# This class get info from github with octokit
class GithubInfo
  attr_reader :token_left

  def initialize
    @conf = ConfigApp.new
    Octokit.configure do |c|
      c.access_token = @conf.params['github']['tokens']['default']
    end
  end

  def list_orgas_repos
    repos = []
    orgs = @conf.params['github']['organizations']
    orgs.each do |org|
      Octokit.org_repos(org).each do |repo|
        repos.push({:full_name => repo['full_name'], :html_url => repo['html_url'], :open_issues_count => repo['open_issues_count']})
      end
    end
    @token_left = Octokit.last_response.headers[:x_ratelimit_remaining]
    repos
  end

  def list_orgas_pr
    prs = []
    repos = list_orgas_repos
    repos.each do |repo|
      Octokit.pull_requests(repo[:full_name]).each do |pr|
        prs.push({:title => pr['title']})
      end
    end
    @token_left = Octokit.last_response.headers[:x_ratelimit_remaining]
    prs
  end
end
