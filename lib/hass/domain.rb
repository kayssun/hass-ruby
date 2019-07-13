module Hass
  # Base class for all domains (lights, switches, media_player...)
  class Domain
    attr_accessor :client
    attr_reader :entity_id

    # Just to make sure, the constant exists
    DATA = {}.freeze

    def initialize(entity_id)
      @entity_id = entity_id
    end

    def required_fields(method_name)
      data['services'][method_name]['fields'].keys.reject { |name| name == 'entity_id' }
    end

    def check_params(method_name, given_params)
      required_fields(method_name).each do |required_field|
        next if given_params.key?(required_field)

        raise "Parameter #{required_field} might be missing. #{method_help(method_name)}"
      end
    end

    # Returns a method description as a help text
    def method_help(method_name)
      param_help = required_fields(method_name).map { |name| "#{name}: #{name}_value" }
      method_hint = "#{method_name}(#{param_help.join(', ')})"
      fields = data['services'][method_name]['fields']
      method_description = fields.keys.map { |field| "#{field}: #{fields[field]['description']}" }.join("\n")
      "Hint: you can call this method with #{method_hint}\n#{method_description}"
    end

    def execute_service(service, params = {})
      params['entity_id'] = @entity_id
      @client.post("/services/#{data['domain']}/#{service}", params)
    rescue RuntimeError => error
      puts "Rescuing from #{error.class}: #{error}"
      check_params(service, params)
    end

    def state_data
      @client.get("/states/#{@entity_id}")
    end

    def attributes
      state_data['attributes']
    end

    def state
      state_data['state']
    end

    def data
      self.class.const_get('DATA')
    end
  end
end
