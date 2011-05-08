module ExactTarget
  class Client
  
    public
    
    def email_find
      email_search :all
    end
    
    def email_find_by_id(id)
      email_search :id, id
    end
    
    def email_find_by_name(name)
      email_search :name, name
    end
    
    def email_find_by_subject(subject)
      email_search :subject, subject
    end
    
    private
    
    def email_search(filter = :all, value = '')
      # ExactTarget does not return more than one email
      # for any search besides all. So we must grab the
      # entire list and search here (slow, but necessary).
      
      @action = 'retrieve'
      @sub_action = 'all'
      @type = ''
      @value = ''
      
      list = []
      send(render(:email))
        .exacttarget
        .system
        .email
        .emaillist.each do |email|
          if filter != :all
            next if !email.send('email' + filter.to_s).content.include? value.to_s
          end
          
          body = email_get_body(email.emailid.content)
          
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
        result = send(render(:email))
        puts result
        result
          .exacttarget
          .system
          .email
          .htmlbody
          .content
        
        result.gsub /<!\[CDATA\[(.*?)\]\]>/, '\1'
      rescue
        nil
      end
    end
    
  end

end
