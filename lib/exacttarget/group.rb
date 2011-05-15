class ExactTarget
  
  public
  
  # Retrieve a group by its ID.
  #
  # @param [int,string] id Group ID
  # @param [hash] options Other options
  # @see ExactTarget#group_find
  #
  def group_find_by_id(id, options = {})
    group_find({
      :id => id
    }.merge(options))
  end
  
  # Retrieve a group by its name.
  #
  # @param [string] name Group name
  # @param [hash] options Other options
  # @see ExactTarget#group_find
  #
  def group_find_by_name(name, options = {})
    group_find({
      :name => name
    }.merge(options))
  end
  
  # Retrieve a group by its description.
  #
  # @param [string] desc Group description
  # @param [hash] options Other options
  # @see ExactTarget#group_find
  #
  def group_find_by_desc(desc, options = {})
    group_find({
      :desc => desc
    }.merge(options))
  end
  
  # Find all groups who's attributes match the selected options.
  #
  # @param [hash] options Options hash
  # @option options [int,string] :id Group ID
  # @option options [string] :name Name of the group (keyword search)
  # @option options [string] :desc Description of the group (keyword search)
  #
  def group_find(options = {})
    id     = options[:id]   || false
    name   = options[:name] || false
    desc   = options[:desc] || false
    groups = []
    
    Nokogiri::Slop(send(render(:group)))
      .exacttarget
      .system
      .list
      .groups.each do |group|
        (next if group.groupID.content != id.to_s) if id
        (next if !group.groupName.content.include? name.to_s) if name
        (next if !group.description.content.include? desc.to_s) if desc
        
        group.instance_eval do
          groups << {
            :id   => groupID.content,
            :name => groupName.content,
            :desc => description.content
          }
        end
    end
    groups
  end
  
  alias :group_find_all :group_find
  
end
