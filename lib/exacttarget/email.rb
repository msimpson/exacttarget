module ExactTarget
  class Client
  
    public
    
    def email_find_by_name(name)
      @action = 'retrieve'
      @sub_action = 'all'
      @type = 'emailnameanddaterange'
      @value = name.to_s
      @start_date = 1/1/1970
      @end_date = Date.today.strftime '%-m/%-d/%Y'
      
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
