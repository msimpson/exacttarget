module ExactTarget
  FTP_STANDARD  = 'ExactTargetFTP'
  FTP_ENHANCED  = 'ExactTargetEnhancedFTP'
  FTP_ENCRYPTED = 'ExactTargetEncryptedFTP'

  class Client

    attr_reader :username,
                :password,
                :ftp_username,
                :ftp_password
    
    public
    
    def initialize(
          username,
          password,
          ftp_location = FTP_STANDARD,
          ftp_username = 'import',
          ftp_password = 'import'
        )
      
      @username     = username
      @password     = password
      @ftp_location = ftp_location
      @ftp_username = ftp_username
      @ftp_password = ftp_password
      
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
        @url.post(@uri.path, post,
          {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Content-length' => post.length.to_s
          }
        ).body
      rescue SocketError
        raise '[ExactTarget] Error: API request failed (SocketError).'
      end
    end
    
  end
end
