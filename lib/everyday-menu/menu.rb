module EverydayMenu
  class Menu
    include MyAccessors

    my_attr_writer :label

    my_attr_accessor_bool :servicesMenu, :windowsMenu, :helpMenu, :mainMenu

    my_attr_reader_bool :statusMenu

    my_attr_reader :statusItemTitle, :statusItemIcon, :statusItemViewClass

    attr_reader :menu, :builder

    def self.create(label, title, options = {}, &block)
      new(label, &block).tap { |menu|
        setup_obj(menu, label, title, options)
      }
    end

    def initialize(label, &block)
      @label               = label
      @builder             = block
      @menu                = NSMenu.alloc.init
      @menuItems           = MenuItemList.new(@menu)
      @mainMenu            = false
      @statusMenu          = false
      @servicesMenu        = false
      @windowsMenu         = false
      @helpMenu            = false
      @statusItemTitle     = nil
      @statusItemIcon      = nil
      @statusItemViewClass = nil
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

    def subscribe(label, command_id = nil, &block)
      self.items[label].subscribe(command_id, &block)
    end

    def <<(item)
      @menuItems << item
    end

    def containedObject
      @menu
    end

    def runOnBuild
      @@buildBlocks ||= {}
      @@buildBlocks.each { |block| block[1].call(self) if self.is(block[0]) }
      @menuItems.each { |item| item.runOnBuild }
    end

    def self.registerBuildBlock(field, &block)
      @@buildBlocks        ||= {}
      @@buildBlocks[field] = block
    end

    registerBuildBlock(:services_menu) { |menu| NSApp.servicesMenu = menu.menu }
    registerBuildBlock(:windows_menu) { |menu| NSApp.windowsMenu = menu.menu }
    registerBuildBlock(:help_menu) { |menu| NSApp.helpMenu = menu.menu }
    registerBuildBlock(:status_menu) { |menu| menu.createStatusItem! }

    def label
      @label ||= nil
    end

    def setStatusItemTitle(title)
      @mainMenu        = false unless title.nil?
      @statusItemTitle = title
      @statusMenu      = true unless title.nil?
    end

    alias :statusItemTitle= :setStatusItemTitle
    alias :status_item_title= :setStatusItemTitle

    def setStatusItemIcon(icon)
      @mainMenu       = false unless icon.nil?
      @statusItemIcon = icon
      @statusMenu     = true unless icon.nil?
    end

    alias :statusItemIcon= :setStatusItemIcon
    alias :status_item_icon= :setStatusItemIcon

    def setStatusItemViewClass(viewClass)
      @mainMenu            = false unless viewClass.nil?
      @statusItemViewClass = viewClass
      @statusMenu          = true unless viewClass.nil?
    end

    alias :statusItemViewClass= :setStatusItemViewClass
    alias :status_item_view_class= :setStatusItemViewClass

    def createStatusItem!
      statusBar                 = NSStatusBar.systemStatusBar
      @statusItem               = statusBar.statusItemWithLength(NSSquareStatusItemLength)
      @statusItem.highlightMode = true

      @statusItem.menu = self.menu

      unless @statusItemViewClass.nil?
        statusItemView            = @statusItemViewClass.viewWithStatusItem(@statusItem)
        @statusItem.menu.delegate = @statusItemView
        @statusItem.view          = statusItemView
      end

      @statusItem.title = @statusItemTitle
      @statusItem.image = @statusItemIcon

      @statusItem
    end

    def items
      @menuItems
    end

    def selectItem(label)
      item = self.items[label]
      item.execute
    end
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