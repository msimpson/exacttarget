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
  
  # A Ruby implementation of the ExactTarget XML API.
  # @author Matthew Simpson
  class Client

    attr_reader :username, :password, :ftp
    
    public
    
    # @param [String] username ExactTarget username.
    # @param [String] password ExactTarget password.
    # @param [String] ftp_username FTP username.
    # @param [String] ftp_password FTP password.
    # @param [Hash] ftp FTP configuration.
    # @option ftp [String] :location The name of the FTP (e.g. ExactTargetFTP).
    # @option ftp [String] :uri The actual URI of the FTP itself (e.g. ftp.exacttarget.com).
    # @option ftp [String] :path The folder for imports (e.g. /import).
    # @example
    #   # Default:
    #   client = ExactTarget::Client.new 'username' 'password'
    #
    #   # Using ExactTargetEnhancedFTP:
    #   client = ExactTarget::Client.new 'username' 'password' 'ftp_username' 'ftp_password' ExactTarget::FTP_ENHANCED
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
    
    def put(file_path)
      begin
        @ftp[:handle].put(file_path.to_s)
      rescue Exception => msg
        puts '[ExactTarget] Error: FTP put failed.'
        raise msg
      end
    end
    
    def delete(file_name)
      tries = 2
      wait  = 2
      
      begin
        @ftp[:handle].delete(file_name.to_s)
      rescue
        tries -= 1
        sleep wait
        retry if tries > 0
        
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
