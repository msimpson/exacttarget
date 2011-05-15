class ExactTarget
  
  public
  
  # Sends an email to an collection of lists or groups.
  def job_send(options)
    @options = {
      :id         => nil,
      :include    => [],
      :exclude    => [],
      :from_name  => nil,
      :from_email => nil,
      :additional => nil,
      :when       => nil,
      :multipart  => false,
      :track      => true,
      :test       => false
    }.merge(options)
    
    # Sanity check:
    if @options[:id].nil? ||
       @options[:include].empty?
       raise "#{ERROR} id and include array/string required!"
    end
    
    @date =
      (@options[:when].strftime('%-m/%-d/%Y') if
        @options[:when].instance_of?(Date) ||
        @options[:when].instance_of?(DateTime)) || 'immediate'
    
    @time =
      (@options[:when].strftime('%H:%M') if
        @options[:when].instance_of?(DateTime)) || ''
    
    result = Nokogiri::XML(send(render(:job)))
    info   = result.xpath('//job_info').text
    desc   = result.xpath('//job_description').text
    
    raise "#{ERROR} job send failed !" if !info.include? 'success'
    desc
  end
  
end
