class ExactTarget
  
  public
  
  # Upload an image (note: uses the FTP and cleans up afterward).
  #
  #   Supported file types:
  #   bmp, gif, jpeg, jpg, png, tif, tiff
  #
  #   Note: Files must be under 200KB.
  #
  #   --- DON'T PANIC ---
  #   This function may spit out FTP deletion failures.
  #   It seems that ExactTarget locks the image file while
  #   it is moving it (the API call). However, it should
  #   delete the file within the retry limit (15).
  #
  # @param [string] file_path The absolute file path of the image to upload/import
  #
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
