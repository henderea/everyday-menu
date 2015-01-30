module EverydayMenu
  class DynamicTitle
    attr_accessor :title
    def initialize(getter, item_parent, item, title)
      @getter = getter
      @item_parent = item_parent
      @item = item
      @title = title
      @item.bind('title', toObject: self, withKeyPath: 'title', options: { 'NSContinuouslyUpdatesValue' => true })
      @item.bind(NSEnabledBinding, toObject: @item_parent.commands, withKeyPath: 'canExecute', options: nil)
    end
    def update
      self.performSelectorOnMainThread('title=:', withObject: @getter.call, waitUntilDone: false)
    end
  end
  class MenuItem
    include MyAccessors

    def self.create(label, title, options = {})
      new.tap { |item| setup_obj(item, label, title, options) }
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

    def containedObject
      @menuItem
    end

    def setSubmenu(menu)
      @menuItem.submenu = menu.menu
    end

    my_attr_reader :menuItem
    alias :item :menuItem

    def label
      @label ||= nil
    end

    my_attr_writer :label

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

    def self.def_presets
      def_hide_preset
      def_hide_others_preset
      def_show_all_preset
      def_quit_preset
      def_close_preset
      def_services_preset
    end

    def self.fill_preset(item, options = {}, &block)
      fill_options(item, options)
      item.subscribe &block
    end

    def self.def_hide_preset
      definePreset(:hide) { |item|
        fill_preset(item, key_equivalent: 'h') { |_, _| NSApp.hide(item) }
      }
    end

    def self.def_hide_others_preset
      definePreset(:hide_others) { |item|
        fill_preset(item, key_equivalent: 'H', key_equivalent_modifier_mask: NSCommandKeyMask|NSAlternateKeyMask) { |_, _| NSApp.hideOtherApplications(item) }
      }
    end

    def self.def_show_all_preset
      definePreset(:show_all) { |item|
        item.subscribe { |_, _| NSApp.unhideAllApplications(item) }
      }
    end

    def self.def_quit_preset
      definePreset(:quit) { |item|
        fill_preset(item, key_equivalent: 'q') { |_, _| NSApp.terminate(item) }
      }
    end

    def self.def_close_preset
      definePreset(:close) { |item|
        fill_preset(item, key_equivalent: 'w') { |_, _| NSApp.keyWindow.performClose(item) }
      }
    end

    def self.def_services_preset
      definePreset(:services) { |item|
        item[:submenu] = Menu.create(:services_menu, item[:title], services_menu: true)
        item.registerOnBuild { NSApp.servicesMenu = item[:submenu] }
      }
    end

    def_presets

    my_attr_reader :dynamicTitle

    def setDynamicTitle(getter)
      @dynamicTitle = EverydayMenu::DynamicTitle.new(getter, self, self.item, self[:title])
    end

    alias :dynamicTitle= :setDynamicTitle
    alias :dynamic_title= :setDynamicTitle

    def updateDynamicTitle
      @dynamicTitle.update if @dynamicTitle
    end

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

    def subscribe(command_id = nil, &block)
      @menuItem.subscribe(self, self.label, command_id, &block)
    end

    def execute
      @menuItem.runBlock(self)
    end

    def commands
      @commands ||= EverydayMenu::CommandList.new(self, self.label)
    end
  end
end

class NSMenuItem
  attr_reader :commands

  def subscribe(parent, label, command_id = nil, &block)
    @commands    ||= parent.commands
    command      = parent.commands.add command_id, &block
    self.enabled = parent.commands.canExecute
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
