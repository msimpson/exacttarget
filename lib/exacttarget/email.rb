module ExactTarget
  class Client
  
    public
    
    def email_find_all
      @action = 'retrieve'
      @sub_action = 'all'
      @type = ''
      @value = ''
      
      send render(:email)
    end
    
  end
end
