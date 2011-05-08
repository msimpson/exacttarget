module ExactTarget
  class Client
  
    public
    
    def email_find_by_id(id, options = {})
      email_find({
        :id => id,
        :body => true
      }.merge(options))
    end
    
    def email_find_by_name(name, options = {})
      email_find({
        :name => name,
      }.merge(options))
    end
    
    def email_find_by_subject(subject, options = {})
      email_find({
        :subject => subject,
      }.merge(options))
    end
    
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
      
      format = Proc.new { |date|
        begin
          date if date.instance_of? Date
          Date.strptime(date, '%m/%d/%Y')
        rescue
          raise '[ExactTarget] Error: Invalid date.'
        end
      }
      
      Nokogiri::Slop(send(render(:email)))
        .exacttarget
        .system
        .email
        .emaillist.each do |email|
          (next if email.emailid.content != id.to_s) if id
          (next if !email.emailname.content.include? name.to_s) if name
          (next if !email.emailsubject.content.include? subject.to_s) if subject
          
          date = format.call(email.emailcreateddate.content)
          
          (next if date < format.call(start_date)) if start_date
          (next if date > format.call(end_date)) if end_date
          
          body = email_get_body(email.emailid.content) if get_body
          
          email.instance_eval do
            new = {
              :id           => emailid.content,
              :name         => emailname.content,
              :subject      => emailsubject.content,
              :date         => email.emailcreateddate.content,
              :category_id  => categoryid.content
            }
            
            new[:body] = body if get_body
            list << new
          end
      end
      
      list
    end
    
    private
    
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
end
