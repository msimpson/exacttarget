module ExactTarget
  class Client
  
    public
    
    def image_import(files)
      @files = (["#{files}"] if files.instance_of? String) || files
      send(render(:image))
    end
    
  end
end
