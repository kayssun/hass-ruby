require 'net/http'
require 'uri'
require 'json'
require 'hass/domain'

module Hass
  # The HomeAssistant server
  class Client
    def initialize(host, port, token, base_path = '/api')
      @host = host
      @port = port
      @token = token
      @base_path = base_path
      prepare_domains
      prepare_methods
    end

    def get(path)
      path = @base_path + path
      request = Net::HTTP::Get.new path
      header.each_pair { |field, content| request[field] = content }
      response = send_http(request)
      parse(response.body)
    end

    def post(path, data)
      path = @base_path + path
      request = Net::HTTP::Post.new path
      request.body = data.to_json
      header.each_pair { |field, content| request[field] = content }
      response = send_http(request)
      parse(response.body)
    end

    def send_http(request)
      Net::HTTP.start(@host, @port, use_ssl: true) do |http|
        response = http.request request
        if response.code.to_i > 299
          handle_http_error(response)
          return {} # if handle does not throw an exception
        end
        return response
      end
    end

    def handle_http_error(response)
      raise "Server returned #{response.code}: #{response.body}"
    end

    def parse(response_text)
      JSON.parse(response_text)
    rescue JSON::ParserError => e
      puts "Cannot parse JSON data: #{e}"
      puts response_text
    end

    def header
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@token}",
        'Accept-Encoding' => 'identity'
      }
    end

    def domains
      @domains ||= get('/services')
    end

    def snake_to_camel(text)
      text.split('_').collect(&:capitalize).join
    end

    def prepare_domains
      domains.each do |domain|
        domain_name = snake_to_camel(domain['domain'])
        domain_class = Class.new(Domain)
        domain_class.const_set('DATA', domain)
        domain['services'].keys.each do |service|
          domain_class.send(:define_method, service.to_sym) do |params = {}|
            execute_service(service, params)
          end
        end
        Hass.const_set(domain_name, domain_class)
      end
    end

    def prepare_methods
      domains.each do |domain|
        domain_name = snake_to_camel(domain['domain'])
        self.class.send(:define_method, domain['domain'].to_sym) do |entity_id|
          domain_class = Hass.const_get(domain_name).new(entity_id)
          domain_class.client = self
          domain_class
        end
      end
    end
  end
end
