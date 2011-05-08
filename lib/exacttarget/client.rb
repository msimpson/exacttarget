require 'net/https'
require 'nokogiri'
require 'uri'
require 'erb'

module ExactTarget
  class Client
  
    attr_accessor :username, :password
    
    def initialize(username, password)
      @username = username
      @password = password
      @url = Net::HTTP.new('api.dc1.exacttarget.com', 443)
      @url.use_ssl = true
    end
    
    # Methods
    
    def retrieve_email_ids
      @action = 'retrieve'
      @sub_action = 'all'
      @type = ''
      @value = ''
      send render(:email)
    end

    # -------
    
    private
    
    def render(template)
      path   = File.join(File.dirname(__FILE__), "templates/#{template.to_s}.xml.erb")
      handle = File.open(path, 'r').read
      ERB.new(handle, 0, "<>").result
    end
    
    def send(xml)
      @system = xml
      post = 'qf=xml&xml=' + URI.escape(render(:main))
      
      begin
        Nokogiri::Slop(
          @url.post(@uri.path, post,
            {
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Content-length' => post.length.to_s
            }
          ).body
        )
      rescue SocketError
      end
    end
    
  end
end
