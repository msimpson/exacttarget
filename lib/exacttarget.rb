# Nokogiri is required for XML parsing:
require 'nokogiri'

# Standard:
require 'net/https'
require 'net/ftp'
require 'uri'
require 'erb'

# Library:
require 'exacttarget/email'
require 'exacttarget/image'

class ExactTarget
  
  ERROR  = '[ExactTarget] Error:'
  
  FTP_STANDARD_NAME = 'ExactTargetFTP'
  FTP_STANDARD_URI  = 'ftp.exacttarget.com'
  FTP_STANDARD_PATH = '/'
  
  FTP_ENHANCED_NAME = 'ExactTargetEnhancedFTP'
  FTP_ENHANCED_URI  = 'ftp1.exacttarget.com'
  FTP_ENHANCED_PATH = '/import'
  
  attr_reader :config
  
  public
  
  def initialize(config)
    @config = {
      :username     => nil,
      :password     => nil,
      :api_uri      => 'https://api.dc1.exacttarget.com/integrate.asp',
      :ftp_username => 'import',
      :ftp_password => 'import',
      :ftp_name     => FTP_STANDARD_NAME,
      :ftp_uri      => FTP_STANDARD_URI,
      :ftp_path     => FTP_STANDARD_PATH
    }.merge(config)
    
    # Sanity check:
    if @config[:username].nil? || 
       @config[:password].nil?
       raise "#{ERROR} username and password required!"
    end
    
    # Start FTP:
    begin
      @ftp = Net::FTP.new(@config[:ftp_uri])
      @ftp.login @config[:ftp_username], @config[:ftp_password]
      @ftp.chdir @config[:ftp_path]
    rescue Net::FTPPermError => msg
      puts "#{ERROR} FTP access failed!"
      raise msg
    end
    
    # Start HTTP:
    @uri = URI.parse(@config[:api_uri])
    @api = Net::HTTP.new(@uri.host, @uri.port)
    @api.use_ssl = true
  end
  
  private
  
  def put(file_path)
    begin
      @ftp.put(file_path.to_s)
    rescue Exception => msg
      puts "#{ERROR} FTP put failed!"
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
      
      puts "#{ERROR} FTP delete failed!"
      raise msg
    end
  end
  
  def render(template)
    path = File.join(File.dirname(__FILE__), "exacttarget/templates/#{template.to_s}.xml.erb")
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
      puts "#{ERROR} API request failed."
      raise msg
    end
  end
    
end
