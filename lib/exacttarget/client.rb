require 'net/https'
require 'nokogiri'
require 'uri'
require 'erb'

class ExactTarget
  class Client
  
    attr_reader :username, :password
    
    def initialize(username, password)
      @username = username
      @password = password
      @uri = URI.parse('https://api.dc1.exacttarget.com/integrate.asp')
      @url = Net::HTTP.new(@uri.host, @uri.port)
      @url.use_ssl = true
    end
    
    private
    
    def render(template)
      path = File.join(File.dirname(__FILE__), "templates/#{template.to_s}.xml.erb")
      file = File.open(path, 'r').read
      ERB.new(file, 0, '<>').result(binding)
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
