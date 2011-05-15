class ExactTarget
  
  public
  
  # Retrieve a list by its ID.
  #
  # @param [int,string] id List ID
  # @param [hash] options Other options
  # @see ExactTarget#list_find
  #
  def list_find_by_id(id, options = {})
    list_find({
      :id => id
    }.merge(options))
  end
  
  # Find all lists who's name includes the given keyword.
  #
  # @param [string] name Name of the list (keyword)
  # @param [hash] options Other options
  # @see ExactTarget#list_find
  #
  def list_find_by_name(name, options = {})
    list_find({
      :name => name,
    }.merge(options))
  end
  
  # Find all lists who's type includes the given keyword.
  #
  # @param [string] subject Type of the list (keyword)
  # @param [hash] options Other options
  # @see ExactTarget#list_find
  #
  def list_find_by_type(type, options = {})
    list_find({
      :type => subject,
    }.merge(options))
  end
  
  # Find all lists who's attributes match the selected options.
  #
  # @param [hash] options Options hash
  # @option options [int,string] :id list ID
  # @option options [string] :name Name of the list (keyword search)
  # @option options [string] :type Type of the list (keyword search)
  # @option options [date] :start The date at which to start the search
  # @option options [date] :end The date at which to end the search
  #
  def list_find(options = {})
    id         = options[:id]    || false
    name       = options[:name]  || false
    type       = options[:type]  || false
    start_date = options[:start] || false
    end_date   = options[:end]   || false
    list       = list_get_all
    
    list.select do |item|
      (next if item[:id] != id.to_s) if id
      (next if !item[:name].include? name.to_s) if name
      (next if !item[:type].include? type.to_s) if type
      (next if item[:modified] < start_date) if start_date && start_date.instance_of?(DateTime)
      (next if item[:modified] > end_date) if end_date && end_date.instance_of?(DateTime)
      true
    end
  end
  
  alias :list_find_all :list_find
  
  private
  
  def list_get_all
    @action = 'retrieve'
    @type   = 'listname'
    @value  = ''
    
    result  = Nokogiri::XML(send(render(:list)))
    error   = result.xpath('//error_description').text
    id_list = result.xpath('//listid').map &:text
    list    = []
    
    id_list.each { |id| list << list_get_details(id) } if error.empty?
    list
  end
  
  def list_get_details(id)
    @action = 'retrieve'
    @type   = 'listid'
    @value  = id.to_s
    
    result  = Nokogiri::XML(send(render(:list)))
    error   = result.xpath('//error_description').text
    error   = error.empty? ? nil : error
    
    {
      :id           => id.to_s,
      :name         => result.xpath('//list_name').text,
      :type         => result.xpath('//list_type').text,
      :modified     => (DateTime.strptime(result.xpath('//modified').text, '%m/%d/%Y %I:%M:%S %p') if !error),
      :total        => (result.xpath('//subscriber_count').text.to_i if !error),
      :subscribed   => (result.xpath('//active_total').text.to_i if !error),
      :unsubscribed => (result.xpath('//unsub_count').text.to_i if !error),
      :bounce       => (result.xpath('//bounce_count').text.to_i if !error),
      :held         => (result.xpath('//held_count').text.to_i if !error),
      :error        => error
    }
  end
  
end
