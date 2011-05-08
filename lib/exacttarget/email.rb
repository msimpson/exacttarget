module ExactTarget
  class Client
  
    public
    
    def email_find_by_name(name)
      @action = 'retrieve'
      @sub_action = 'all'
      @type = 'emailname'
      @value = name.to_s
      
      send render(:email)
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
