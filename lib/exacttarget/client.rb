module ExactTarget
  FTP_STANDARD = {
    :location  => 'ExactTargetFTP',
    :uri       => 'ftp.exacttarget.com',
    :path      => '/',
  }
  FTP_ENHANCED = {
    :location  => 'ExactTargetEnhancedFTP',
    :uri       => 'ftp1.exacttarget.com',
    :path      => '/import',
  }

  class Client

    attr_reader :username, :password, :ftp
    
    public
    
    def initialize(username, password, ftp_username = 'import', ftp_password = 'import', ftp = FTP_STANDARD)
      @username   = username
      @password   = password
      @ftp        = {
        :username => ftp_username.to_s,
        :password => ftp_password.to_s,
        :handle   => Net::FTP.new(ftp[:uri])
      }.merge ftp
      
      begin
        @ftp[:handle].login @ftp[:username], @ftp[:password]
        @ftp[:handle].chdir @ftp[:path]
      rescue Net::FTPPermError => msg
        puts '[ExactTarget] Error: FTP access failed.'
        raise msg
      end
      
      @uri = URI.parse('https://api.dc1.exacttarget.com/integrate.asp')
      @api = Net::HTTP.new(@uri.host, @uri.port)
      @api.use_ssl = true
    end
    
    private
    
    def put(file)
      begin
        @ftp[:handle].put(file.to_s)
      rescue Exception => msg
        puts '[ExactTarget] Error: FTP put failed.'
        raise msg
      end
    end
    
    def delete(file)
      begin
        @ftp[:handle].delete(file.to_s)
      rescue Exception => msg
        puts '[ExactTarget] Error: FTP delete failed.'
        raise msg
      end
    end
        
    def render(template)
      path = File.join(File.dirname(__FILE__), "templates/#{template.to_s}.xml.erb")
      file = File.open(path, 'r').read
      ERB.new(file, 0, '<>').result(binding)
    end
    
    def send(xml)
      @system = xml
      post = 'qf=xml&xml=' + URI.escape(render(:main))
      
      begin
        @api.post(@uri.path, post,
          {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Content-length' => post.length.to_s
          }
        ).body
      rescue SocketError => msg
        puts '[ExactTarget] Error: API request failed.'
        raise msg
      end
    end
    
  end
end
