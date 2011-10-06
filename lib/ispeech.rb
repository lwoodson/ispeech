require 'uri'
require 'net/http'
require 'ostruct'

module ISpeech
  URL_ENCODED_ENDPOINT = 'http://api.ispeech.org/api/rest'

  def self.parameterize(hash)
    hash.inject(""){|str,tuple| str << "&#{tuple[0].to_s}=#{tuple[1].to_s.gsub(/\s/, '+')}"}[1..-1]
  end

  def self.decode_param_string(pstring)
    map = {}
      pstring.split("&").each do |pair|
        key, value = pair.split "="
        map[key] = value
      end
      OpenStruct.new map
  end

  class Client
    def initialize(config)
      @endpoint = config[:endpoint] ||= ISpeech::URL_ENCODED_ENDPOINT
      @api_key = config[:api_key]
    end

    def information
      url = "#{@endpoint}?apikey=#{@api_key}&action=information"
      result = Net::HTTP.get(URI.parse(url))
      ISpeech.decode_param_string result
    end

    def convert(opts)
      params = ISpeech.parameterize opts
      url = "#{@endpoint}?apikey=#{@api_key}&action=convert&#{params}"
      puts url
      result = Net::HTTP.get(URI.parse(url))
      if !opts[:filename].nil?
        File.open(opts[:filename], 'w') do |file|
          file.write result
        end
      end
      result
    end
  end
end
