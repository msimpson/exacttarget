module ExactTarget
  class Client
  
    public
    
    def image_import(file_path)
      @name = File.basename(file_path)
      
      begin
        put(file_path.to_s)
        result = Nokogiri::XML(send(render(:image)))
        delete(@name)
      rescue Exception => msg
        puts msg
      end
      
      desc   = result.xpath('//filemanagement-description').text
      total  = result.xpath('//filemanagement-totalmoved').text.to_i
      name   = result.xpath('//filemanagement-info').text
      error  = desc.include?('not exist') ? 'File not found.' : total < 1 ? 'Unsupported file type.' : nil
      
      {
        :file_path => file_path,
        :old_name  => @name,
        :new_name  => name,
        :error     => error
      }
    end
    
  end
end
