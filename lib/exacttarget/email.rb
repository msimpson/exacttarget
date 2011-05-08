module ExactTarget
  class Client
  
    public
    
    def email_find_all
      email_search
    end
    
    def email_find_by_id(id)
      email_search :id, id, true
    end
    
    def email_find_by_name(name, get_body = false)
      email_search :name, name, get_body
    end
    
    def email_find_by_subject(subject, get_body = false)
      email_search :subject, subject, get_body
    end
    
    private
    
    def email_search(filter = :all, value = '', get_body = false)
      # ExactTarget does not return more than one email
      # for any search besides all. So we must grab the
      # entire list and search here (slow, but necessary).
      
      @action = 'retrieve'
      @sub_action = 'all'
      @type = ''
      @value = ''
      
      list = []
      Nokogiri::Slop(send(render(:email)))
        .exacttarget
        .system
        .email
        .emaillist.each do |email|
          case filter
            when :id
              next if email.emailid.content != value.to_s
            when :name, :subject
              next if !email.send('email' + filter.to_s).content.include? value.to_s
          end
          
          body = (email_get_body(email.emailid.content) if get_body) || nil
          
          email.instance_eval do
            list << {
              :id           => emailid.content,
              :name         => emailname.content,
              :subject      => emailsubject.content,
              :category_id  => categoryid.content,
              :body         => body
            }
          end
      end
      
      list
    end
    
    def email_get_body(id)
      @action = 'retrieve'
      @sub_action = 'htmlemail'
      @type = 'emailid'
      @value = id.to_s
      
      begin
        Nokogiri::XML(send(render(:email)))
          .xpath('//htmlbody').text
      rescue
        nil
      end
    end
    
  end

end
