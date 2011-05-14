class ExactTarget
    
  public
  
  def image_import(file_path)
    @name  = File.basename(file_path)
    
    ftp_put(file_path.to_s)
    
    result = Nokogiri::XML(send(render(:image)))
    desc   = result.xpath('//filemanagement-description').text
    total  = result.xpath('//filemanagement-totalmoved').text.to_i
    name   = result.xpath('//filemanagement-info').text
    error  = desc.include?('not exist') ? 'File not found' : total < 1 ? 'Unsupported file type' : nil
    
    count  = 0
    limit  = 15
    
    begin
      sleep 0.5
      ftp_delete(@name)
    rescue
      count += 1
      retry if count < limit
    end
    
    {
      :file_path => file_path.to_s,
      :old_name  => @name,
      :new_name  => name,
      :error     => error
    }
  end
    
end
