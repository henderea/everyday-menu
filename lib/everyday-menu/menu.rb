module EverydayMenu
  class Menu
    attr_reader :needsMenuItem

    def self.create(label, title, options = {}, &block)
      new(label, &block).tap { |menu|
        menu[:label] = label
        menu[:title] = title
        options.each { |option| menu[option[0]] = option[1] }
      }
    end

    def initialize(label, &block)
      @label         = label
      @builder       = block
      @menu          = NSMenu.alloc.init
      @menuItems     = MenuItemList.new(@menu)
      @needsMenuItem = false
      @servicesMenu  = false
      @windowMenu    = false
      @helpMenu      = false
    end

    def menuItemFromMenu!
      @mainMenuItem ||= MenuItem.create(self[:label], self[:title], submenu: self)
      self
    end

    alias :menu_item_for_menu! :menuItemFromMenu!

    def menuItem
      @mainMenuItem.item
    end

    alias :menu_item :menuItem

    def subscribe(label, &block)
      self.items[label].subscribe(&block)
    end

    def <<(item)
      @menuItems << item
    end

    def has(key)
      name = key_to_name(key, 'has')
      if self.respond_to?(name)
        self.send(name)
      else
        @menu.send(name)
      end
    end

    def is(key)
      name = key_to_name(key, 'is')
      if self.respond_to?(name)
        self.send(name)
      else
        @menu.send(name)
      end
    end

    def [](key)
      name = key_to_name(key)
      if self.respond_to?(name)
        self.send(name)
      else
        @menu.send(name)
      end
    end

    def []=(key, value)
      name = key_to_name(key, 'set')
      if self.respond_to?(name)
        self.send(name, value)
      else
        @menu.send(name, value)
      end
    end

    def key_to_name(key, prefix = nil)
      rval = key.to_s.gsub(/_(\w)/) { |_| $1.upcase }
      prefix.nil? ? rval : "#{prefix}#{rval[0].upcase}#{rval[1..-1]}"
    end

    def runOnBuild
      if self.is :services_menu
        NSApp.servicesMenu = self.menu
      end
      if self.is :windows_menu
        NSApp.windowsMenu = self.menu
      end
      if self.is :help_menu
        NSApp.helpMenu = self.menu
      end
      @menuItems.each { |item| item.runOnBuild }
    end

    def label
      @label ||= nil
    end

    def setLabel(label)
      @label = label
    end

    alias :label= :setLabel

    def isServicesMenu
      @servicesMenu
    end

    alias :servicesMenu :isServicesMenu
    alias :services_menu? :isServicesMenu

    def setServicesMenu(value)
      @servicesMenu = value
    end

    alias :servicesMenu= :setServicesMenu
    alias :services_menu= :setServicesMenu

    def isWindowsMenu
      @windowMenu
    end

    alias :windowsMenu :isWindowsMenu
    alias :windows_menu? :isWindowsMenu

    def setWindowsMenu(value)
      @windowMenu = value
    end

    alias :windowsMenu= :setWindowsMenu
    alias :windows_menu= :setWindowsMenu

    def isHelpMenu
      @helpMenu
    end

    alias :helpMenu :isHelpMenu
    alias :help_menu? :isHelpMenu

    def setHelpMenu(value)
      @helpMenu = value
    end

    alias :helpMenu= :setHelpMenu
    alias :help_menu= :setHelpMenu

    def items
      @menuItems
    end

    def menu
      @menu
    end

    def builder
      @builder
    end

    def isMainMenu
      @needsMenuItem
    end

    alias :mainMenu :isMainMenu
    alias :main_menu? :isMainMenu

    def setMainMenu(value)
      @needsMenuItem = value
    end

    alias :main_menu= :setMainMenu
  end

  class MenuItemList
    def initialize(menu)
      @menuItems = {}
      @menu      = menu
    end

    def <<(item)
      previousItemTag        = @menuItems.keys.last || 0
      item[:tag]             = previousItemTag + 1
      @menuItems[item[:tag]] = item
      @menu.addItem item.menuItem
    end

    def [](labelOrTag)
      (labelOrTag.is_a? Fixnum) ? @menuItems[labelOrTag] : @menuItems.values.find { |item| item.label == labelOrTag }
    end

    def selectItem(label)
      item = self[label]
      item.execute
    end

    alias :select_item :selectItem

    def selectItemByMember(member)
      item = @menuItems.values.find do |i|
        i[:represented_object] == member
      end
      item.execute
    end

    alias :select_item_by_member :selectItemByMember

    def each(&block)
      @menuItems.values.each(&block)
    end
  end
end