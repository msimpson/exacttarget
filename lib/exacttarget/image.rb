module ExactTarget
  class Client
  
    public
    
    def image_import(files)
      @files = (["#{files}"] if files.instance_of? String) || files
      result = Nokogiri::XML(send(render(:image)))
    end
    
    private
    
  end
end
