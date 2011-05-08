class ExactTarget
  class Client
  
    def email
      @action = 'retrieve'
      @sub_action = 'all'
      @type = ''
      @value = ''
      send render(:email)
    end
    
  end
end
