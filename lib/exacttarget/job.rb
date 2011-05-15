class ExactTarget
  
  public
  
  # Send an email to a collection of lists or groups.
  #
  # @param [hash] options Options hash
  # @option options [int,string] :id Email ID
  # @option options [array] :include The collection of lists or groups to target
  # @option options [array] :exclude The collection of lists or groups to skip
  # @option options [string] :from_name Name of sender (only if supported by your account)
  # @option options [string] :from_email Email address of sender (only if supported by your account)
  # @option options [string] :additional Additional information to include
  # @option options [date,datetime] :when The date and/or time which to send the email(s)
  # @option options [bool] :multipart Whether or not to send in multiple parts (for MIME compatibility)
  # @option options [bool] :track Whether or not to track hyperlink clicks
  # @option options [bool] :test If true, suppress email(s) from Performance Reports
  #
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
