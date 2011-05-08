module ExactTarget
  class Client
  
    public
    
    def email_find_by_name(name)
      # ExactTarget does not return more than one email
      # for any search besides all. So we must grab the
      # entire list and search here (slow, but necessary).
      
      @action = 'retrieve'
      @sub_action = 'all'
      @type = ''
      @value = ''
      
      result = send render(:email)
      puts result
      result
        .exacttarget
        .system
        .email
        .emaillist.select do |email|
          email.emailname.include? name.to_s
      end
    end
    
    private
    
    def email_get_body(id)
      @action = 'retrieve'
      @sub_action = 'htmlemail'
      @type = 'emailid'
      @value = id
      
      send(render(:email))
        .exacttarget
        .system
        .email
        .htmlbody
    end
    
  end

end
