
# THE MODULE
module HumanApi
	# THE CLASS
	class Human < Nestful::Resource

		attr_reader :token

		# The host of the api
		endpoint 'https://api.humanapi.co'
		puts "human api loaded -------------------------"
		# The path of the api
		path '/v1/human'

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
				url = "#{method}"

				if options[:report_id]
					url += "/#{options[:report_id]}"

					if options[:report_format]
						url += "/raw?format=#{options[:report_format]}"
					end
				end
				
			else
				return "The method '#{method}' does not exist!"
			end

			puts "method and url -------------------------"
			puts method
			puts url
			puts "-------------------------"
			if method && url
				query_params = options[:query_params] || {}
				# result = get(url, {:access_token => "Bearer demo"}.merge(query_params))
				result = get(url, {:headers => {"Authorization" => "Bearer demo"}})
				puts "response -------------------------"
				JSON.parse(result.body)
				puts "-------------------------"
				JSON.parse(result.body)
			end
		end
	end
end