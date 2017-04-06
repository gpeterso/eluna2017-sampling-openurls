# Adapted from https://github.com/google/google-api-ruby-client-samples/blob/master/service_account/analytics.rb
require 'google/api_client'

class GoogleAnalyticsService

	API_VERSION = 'v3'
	CACHED_API_FILE = "analytics-#{API_VERSION}.cache"

	def initialize(opts={})
		service_account_email = opts['service_account_email'] 
		key_file = opts['key_file']       
		key_secret = opts['key_secret'] 
		application_name = opts['application_name']
		application_version = opts['application_version']
		@profile_id = opts['profile_id'].to_s    

		@client = Google::APIClient.new(application_name: application_name, 
																		application_version: application_version)

		authorize(service_account_email, key_file, key_secret)
		@analytics = load_analytics
	end

	def query(dimension:, metric:, sort:, filter:, start_date:, end_date:)
		query_data = @client.execute(:api_method => @analytics.data.ga.get, :parameters => {
			'ids' => "ga:" + @profile_id,
			'start-date' => start_date,
			'end-date' => end_date,
			'dimensions' => dimension,
			'metrics' => metric,
			'sort' => sort,
			'filters' => filter,
			'max-results' => '10000'
		})
		return query_data
	end

	private

	def authorize(service_account_email, key_file, key_secret)
		key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
		@client.authorization = Signet::OAuth2::Client.new(
			:token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
			:audience => 'https://accounts.google.com/o/oauth2/token',
			:scope => 'https://www.googleapis.com/auth/analytics.readonly',
			:issuer => service_account_email,
			:signing_key => key)
		@client.authorization.fetch_access_token!
	end

	def load_analytics
		analytics = nil
		if File.exists? CACHED_API_FILE
			File.open(CACHED_API_FILE) do |file|
				analytics = Marshal.load(file)
			end
		else
			analytics = @client.discovered_api('analytics', API_VERSION)
			File.open(CACHED_API_FILE, 'w') do |file|
				Marshal.dump(analytics, file)
			end
		end
		analytics
	end

end

