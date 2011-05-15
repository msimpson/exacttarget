class ExactTarget
  
  public
  
  alias :email_send :job_send
  
  # Find all emails.
  #
  # @param [bool] body Retrieve HTML body of each email (can cause seriously lag) [dangerous]
  #
  def email_find_all(body = false)
    email_find({ :body => body })
  end
  
  # Retrieve an email by its ID.
  #
  # @param [int,string] id Email ID
  # @param [hash] options Other options
  # @see ExactTarget#email_find
  #
  def email_find_by_id(id, options = {})
    email_find({
      :id => id,
      :body => true
    }.merge(options))
  end
  
  # Find all emails who's name includes the given keyword.
  #
  # @param [string] name Name of the email (keyword)
  # @param [hash] options Other options
  # @see ExactTarget#email_find
  #
  def email_find_by_name(name, options = {})
    email_find({
      :name => name,
    }.merge(options))
  end
  
  # Find all emails who's subject includes the given keyword.
  #
  # @param [string] subject Subject of the email (keyword)
  # @param [hash] options Other options
  # @see ExactTarget#email_find
  #
  def email_find_by_subject(subject, options = {})
    email_find({
      :subject => subject,
    }.merge(options))
  end
  
  # Find all emails who's attributes match the selected options.
  #
  # @param [hash] options Options hash
  # @option options [int,string] :id Email ID
  # @option options [string] :name Name of the email (keyword search)
  # @option options [string] :subject Subject of the email (keyword search)
  # @option options [date] :start_date The date at which to start the search
  # @option options [date] :end_date The date at which to end the search
  # @option options [bool] :get_body Whether or not to retrieve the HTML body of the email
  #
  def email_find(options = {})
    @action     = 'retrieve'
    @sub_action = 'all'
    @type       = ''
    @value      = ''
    
    id          = options[:id]      || false
    name        = options[:name]    || false
    subject     = options[:subject] || false
    start_date  = options[:start]   || false
    end_date    = options[:end]     || false
    get_body    = options[:body]    || false
    list        = []
    
    Nokogiri::Slop(send(render(:email)))
      .exacttarget
      .system
      .email
      .emaillist.each do |email|
        (next if email.emailid.content != id.to_s) if id
        (next if !email.emailname.content.include? name.to_s) if name
        (next if !email.emailsubject.content.include? subject.to_s) if subject
        
        date = Date.strptime(email.emailcreateddate.content, '%m/%d/%Y')
        
        (next if date < start_date) if start_date && start_date.instance_of?(Date)
        (next if date > end_date) if end_date && end_date.instance_of?(Date)
        
        body = email_get_body(email.emailid.content) if get_body
        
        email.instance_eval do
          new = {
            :id           => emailid.content,
            :name         => emailname.content,
            :subject      => emailsubject.content,
            :date         => date,
            :category_id  => categoryid.content
          }
          
          new[:body] = body if get_body
          list << new
        end
    end
    
    list
  end
  
  # Create an email.
  #
  # @param [string] name Name of the new email
  # @param [string] subject The subject line
  # @param [string] html The HTML source
  # @param [string] text The text version
  #
  def email_create(name, subject, html, text = false)
    id = email_add_html(name, subject, html)
    email_add_text(id, text) if text
    id
  end
  
  private
  
  def email_add_html(name, subject, html)
    @action     = 'add'
    @sub_action = 'HTMLPaste'
    @name       = name.to_s
    @subject    = subject.to_s
    @body       = html
    
    result = Nokogiri::XML(send(render(:email)))
    id = result.xpath('//emailID').text
    
    raise "#{ERROR} email HTMLPaste failed." if id.empty?
    id
  end
  
  def email_add_text(id, text)
    @action     = 'add'
    @sub_action = 'text'
    @id         = id
    @body       = text
    
    result = Nokogiri::XML(send(render(:email)))
    info = result.xpath('//email_info').text
    
    raise "#{ERROR} email text update failed." if info.empty?
    true
  end
  
  def email_get_body(id)
    @action     = 'retrieve'
    @sub_action = 'htmlemail'
    @type       = 'emailid'
    @value      = id.to_s
    
    begin
      Nokogiri::XML(send(render(:email)))
        .xpath('//htmlbody').text
    rescue
      nil
    end
  end
  
end
