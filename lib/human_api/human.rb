
# THE MODULE
module HumanApi
	# THE CLASS
	class Human < Nestful::Resource

		attr_reader :token

		# The host of the api
		endpoint 'https://api.humanapi.co'

		# The path of the api
		path '/v1/human'

		puts "env ========================="
		puts Rails.env.staging?
		puts Rails.env
		puts "env ========================="
		# The available methods for this api
		AVAILABLE_WELLNESS_API_METHODS = [
			:profile, 
			:activities, 
			:blood_glucose, 
			:blood_pressure, 
			:body_fat, 
			:genetic_traits, 
			:heart_rate, 
			:height, 
			:locations, 
			:sleeps, 
			:weight, 
			:bmi,
			:sources,
			:food,
			:human
		]
		AVAILABLE_MEDICAL_API_METHODS = [
			:allergies,
			:encounters,
			:functional_statuses,
			:immunizations,
			:instructions,
			:medications,
			:narratives,
			:organizations,
			:plans_of_care,
			:issues,
			:procedures,
			:profile,
			:test_results,
			:vitals,
			:ccds,
			:demographics,
			:social_history
		]

		AVAILABLE_REPORTS_API_METHODS = [
			:reports
		]

		def initialize(options)
			@token = options[:access_token]
			@load_demo_data = Rails.env.staging? || Rails.env.development?
			@headers = {headers: {'Authorization' => 'Bearer demo', 'Content-Type' => 'application/json'}}
			super
		end

		# Profile =====================================

		def summary
			get('', :access_token => token)
		end

		def profile
			query('profile')
		end

		# =============================================

		def query(method, options = {})

			if AVAILABLE_WELLNESS_API_METHODS.include? method.to_sym
				method = method&.to_s
				url = "#{method}"

				if method == "food"
					url += "/meals"
				end

				if method.is_singular?
					if options[:readings] == true
						url += "/readings"
					end
				else
					if options[:summary] == true
						url += "/summary"
					elsif options[:summaries] == true
						url += "/summaries"
					end
				end

				if options[:date].present?
					url += "/daily/#{options[:date]}"
				elsif options[:id].present?
					url += "/#{options[:id]}"
				end

			elsif AVAILABLE_MEDICAL_API_METHODS.include? method.to_sym
				method = method&.to_s
				url = "medical/#{method}"

				if method == "organizations"
					if options[:organization_id]
						url += "/#{options[:organization_id]}"
					else
						return "Organizations endpoint need organization id"
					end
				end
			
			elsif AVAILABLE_REPORTS_API_METHODS.include? method.to_sym
				method = method.to_s
				url = "medical/#{method}"

				if options[:report_id]
					url += "/#{options[:report_id]}"

					if options[:report_format]
						url += "/raw?format=#{options[:report_format]}"
					end
				end
			else
				return "The method '#{method}' does not exist!"
			end

			if method && url
				query_params = options[:query_params] || {}
				
				if @load_demo_data
					result = get(url, {}, { headers: @headers})
				else
					result = get(url, {:access_token => token}.merge(query_params))
				end

				if options[:report_format]
					result.body
				else
					JSON.parse(result.body)
				end
			end
		end
	end
end