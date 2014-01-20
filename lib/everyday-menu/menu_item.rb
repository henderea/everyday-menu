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

    def self.separatorItem
      self.separator
    end

    def initialize(menuItem=nil)
      @menuItem = menuItem || NSMenuItem.alloc.init
    end

    def has(key)
      name = key_to_name(key, 'has')
      if self.respond_to?(name)
        self.send(name)
      else
        @menuItem.send(name)
      end
    end

    def is(key)
      name = key_to_name(key, 'is')
      if self.respond_to?(name)
        self.send(name)
      else
        @menuItem.send(name)
      end
    end

    def [](key)
      name = key_to_name(key)
      if self.respond_to?(name)
        self.send(name)
      else
        @menuItem.send(name)
      end
    end

    def []=(key, value)
      name = key_to_name(key, 'set')
      if self.respond_to?(name)
        self.send(name, value)
      else
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

    def keyEquivalentModifierMask
      @menuItem.keyEquivalentModifierMask
    end

    def setKeyEquivalentModifierMask(value)
      @menuItem.keyEquivalentModifierMask = value
    end

    alias :keyEquivalentModifierMask= :setKeyEquivalentModifierMask
    alias :key_equivalent_modifier_mask= :setKeyEquivalentModifierMask

    def setPreset(action)
      @@presets ||= {}
      if @@presets.has_key?(action)
        @@presets[action].call(self)
      end
    end

    def self.definePreset(label, &block)
      @@presets        ||= {}
      @@presets[label] = block
    end

    definePreset(:hide) { |item|
      item[:key_equivalent] = 'h'
      item.subscribe { |_, _| NSApp.hide(item) }
    }

    definePreset(:hide_others) { |item|
      item[:key_equivalent]               = 'H'
      item[:key_equivalent_modifier_mask] = NSCommandKeyMask|NSAlternateKeyMask
      item.subscribe { |_, _| NSApp.hideOtherApplications(item) }
    }

    definePreset(:show_all) { |item|
      item.subscribe { |_, _| NSApp.unhideAllApplications(item) }
    }

    definePreset(:quit) { |item|
      item[:key_equivalent] = 'q'
      item.subscribe { |_, _| NSApp.terminate(item) }
    }

    definePreset(:close) { |item|
      item[:key_equivalent] = 'w'
      item.subscribe { |_, _| NSApp.keyWindow.performClose(item) }
    }

    definePreset(:services) { |item|
      item[:submenu] = Menu.create(:services_menu, item[:title], services_menu: true)
      item.registerOnBuild { NSApp.servicesMenu = item[:submenu] }
    }

    def runOnBuild
      onBuild.each { |block| block.call }
    end

    def onBuild
      @onBuild ||= []
    end

    def registerOnBuild(&block)
      @onBuild ||= []
      @onBuild << block
    end

    def subscribe(&block)
      @menuItem.subscribe(self.label, &block)
    end

    def execute
      @menuItem.runBlock(self)
    end
  end
end

class NSMenuItem
  attr_reader :commands

  def subscribe(label, &block)
    @commands ||= EverydayMenu::CommandList.new(label)
    @commands.add &block
    command      = @commands.last
    self.enabled = @commands.canExecute
    unless @boundEnabled
      @boundEnabled = true
      self.bind(NSEnabledBinding, toObject: self.commands, withKeyPath: 'canExecute', options: nil)
    end
    return command if (self.target = self && self.action == :'runBlocks:')
    @original_target = self.target
    self.target      = self
    self.action      = :'runBlock:'
    command
  end

  def runBlock(sender)
    @commands.execute(sender) unless @commands.nil?
  end
end
