require 'json'
require 'rest-client'
require 'pp'
require 'cifsdk'
require 'cifsdk/version'

module CIFSDK
  class Client
    attr_accessor :remote, :token, :no_verify_ssl, :log, :handle,
    :query, :submit, :logger, :config_path, :columns, :submission, :search_id

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
      #@handle = HTTPClient.new(agent_name: 'rb-cifsdk/' + CIFSDK::VERSION)

      #unless @verify_ssl
      #  @handle.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      #end

      @headers = {
          'Accept' => 'application/vnd.cif.v' + CIFSDK::API_VERSION + '+json',
          'Authorization' => 'Token token=' + params['token'].to_s,
          'Content-Type' => 'application/json',
          'User-Agent' => 'cifsdk-rb/' + CIFSDK::VERSION
      }
    end

    def _make_request(uri='',type='get',params={})

      case type
        when 'put'
          uri = URI(@remote)
          self.logger.debug { "uri: #{uri}.to_s" }
          res = @handle.post(uri,params['data'],@headers)
        else
          self.logger.debug { "uri: " + @remote + "#{uri}" }
          self.logger.debug { "params: #{params}" }
          uri = URI(@remote + uri).to_s + '?'
          uri += params.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join('&')

          pp uri

          #raise

          res = RestClient::Request.execute(method: :get,
                                            url: uri,
                                            headers: @headers,
                                            verify_ssl: OpenSSL::SSL::VERIFY_NONE)

          pp res
      end

      case res.code
        when 200...299
          return JSON.parse(res.body)['data']
        when 300...399
          @logger.debug { "received: #{res.code}" }
        when 400
            @logger.warn { 'unauthorized, bad or missing token' }
        when 404
            @logger.warn { 'invalid remote uri: #{uri}.to_s' }
        else
          @logger.fatal { 'router failure, contact administrator' }
        end
    end

    def ping
      start = Time.now()

      rv = self._make_request(uri='/ping')
      return nil unless(rv)

      (Time.now()-start)
    end

    def search(filters)
      if filters['id']
        res = self._make_request(uri="/indicators" + filters['id'],type='get')
      else
        res = self._make_request(uri="/indicators",type='get',params=filters)
      end
      res
    end

    def submit(data=nil)
      #data = JSON.generate(data) if data.is_a?(::Hash)
      params = {
        data: data
      }
      self._make_request(uri='/indicators',type='post',params)
    end
  end
end
