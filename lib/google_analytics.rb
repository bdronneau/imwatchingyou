require 'google/api_client'
require 'date'

API_VERSION = 'v3'
CACHED_API_FILE = "analytics-#{API_VERSION}.cache"

# Get informations from Google Analytics API
class GoogleAnalytics
  def initialize
    @conf = ConfigApp.new

    service_account_email = @conf.params['google']['analytics']['service_account_email']
    key_file = @conf.params['google']['analytics']['key_file']
    key_secret = @conf.params['google']['analytics']['key_secret']
    @profileID = @conf.params['google']['analytics']['profileID'].to_s

    @client = Google::APIClient.new(
        :application_name => @conf.params['google']['analytics']['application_name'],
        :application_version => @conf.params['google']['analytics']['application_version'])

    ## Load our credentials for the service account
    key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)

    @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/analytics.readonly',
        :issuer => service_account_email,
        :signing_key => key)

    ## Request a token for google analytics service account
    @client.authorization.fetch_access_token!

    @analytics = nil
    ## Load cached discovered API, if it exists. This prevents retrieving the
    ## discovery document on every run, saving a round-trip to the discovery service.
    if File.exists? CACHED_API_FILE
      File.open(CACHED_API_FILE) do |file|
        @analytics = Marshal.load(file)
      end
    else
      @analytics = @client.discovered_api('analytics', API_VERSION)
      File.open(CACHED_API_FILE, 'w') do |file|
        Marshal.dump(@analytics, file)
      end
    end
  end

  def realtime_users
    visitCount = @client.execute(
        :api_method => @analytics.data.realtime.get,
        :parameters => {
            'ids' => "ga:" + @profileID,
            'metrics' => "ga:activeVisitors",
        })

    visitCount.data.rows[0][0]
  end

end
