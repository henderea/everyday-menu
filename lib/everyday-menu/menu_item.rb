module EverydayMenu
  class MenuItem
    def self.create(label, title, options = {})
      new.tap { |item|
        item[:label] = label
        item[:title] = title
        options.each { |option| item[option[0]] = option[1] }
      }
    end

    def self.separator
      @@separatorId ||= 0
      @@separatorId += 1
      label         = :"separator#{@@separatorId}"
      new(NSMenuItem.separatorItem).tap do |item|
        item.label = label
      end
    end

    alias :separatorItem :separator

    def initialize(menuItem=nil)
      @menuItem = menuItem || NSMenuItem.alloc.init
    end

    def has(key)
      name = key_to_name(key, 'has')
      begin
        self.send(name)
      rescue NoMethodError
        @menuItem.send(name)
      end
    end

    def is(key)
      name = key_to_name(key, 'is')
      begin
        self.send(name)
      rescue NoMethodError
        @menuItem.send(name)
      end
    end

    def [](key)
      name = key_to_name(key)
      begin
        self.send(name)
      rescue NoMethodError
        @menuItem.send(name)
      end
    end

    def []=(key, value)
      name = key_to_name(key, 'set')
      begin
        self.send(name, value)
      rescue NoMethodError
        @menuItem.send(name, value)
      end
    end

    def key_to_name(key, prefix = nil)
      rval = key.to_s.gsub(/_(\w)/) { |_| $1.upcase }
      prefix.nil? ? rval : "#{prefix}#{rval[0].upcase}#{rval[1..-1]}"
    end

    def setSubmenu(menu)
      @menuItem.submenu = menu.menu
    end

    def menuItem
      @menuItem
    end

    alias :menu_item :menuItem
    alias :item :menuItem

    def label
      @label ||= nil
    end

    def setLabel(label)
      @label = label
    end

    alias :label= :setLabel

    def tag
      @menuItem.tag
    end

    def setTag(tag)
      @menuItem.tag = tag
    end

    alias :tag= :setTag

    def subscribe(&block)
      @menuItem.subscribe(&block)
    end

    def execute
      @menuItem.runBlock(self)
    end
  end
end

class NSMenuItem
  def subscribe(&block)
    @blocks ||= []
    @blocks << block
    return if (self.target = self && self.action == :'runBlocks:')
    @original_target = self.target
    self.target      = self
    self.action      = :'runBlock:'
  end

  def runBlock(sender)
    @blocks.each { |block| block.call(sender) } unless @blocks.nil?
  end
end
