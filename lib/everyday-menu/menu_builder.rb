module EverydayMenu
  module MenuBuilder
    class Context < BasicObject
      def initialize(menu, menuItems={})
        @menu      = menu
        @menuItems = menuItems
      end

      def ___
        @menu << MenuItem.separator
      end

      def method_missing(meth, *args)
        if @menuItems.key?(meth)
          @menu << @menuItems[meth]
        else
          super
        end
      end
    end

    def <<(item)
      @menuItems             ||= {}
      @menuItems[item.label] = item
    end

    def menuItem(label, title, options = {})
      options[:submenu] = @menus[options[:submenu]] if options.has_key?(:submenu)
      self << MenuItem.create(label, title, options)
    end

    alias :menu_item :menuItem

    def mainMenu(label, title, options = {}, &block)
      options[:main_menu] = true
      @menus              ||= {}
      @menus[label]       = Menu.create(label, title, options, &block)
    end

    alias :main_menu :mainMenu

    def menu(label, title, options = {}, &block)
      options[:main_menu] = false
      @menus              ||= {}
      @menus[label]       = Menu.create(label, title, options, &block)
    end

    def [](label)
      @menus[label]
    end

    def build!
      @menus.values.each do |menu|
        context = Context.new(menu, @menuItems.dup)
        context.instance_eval(&menu.builder) if menu.builder
        if menu.is :main_menu
          @mainMenu ||= NSMenu.new
          @mainMenu.addItem menu.menuItemFromMenu!.menuItem
        end
        if menu.is :services_menu
          NSApp.servicesMenu = menu.menu
        end
        if menu.is :windows_menu
          NSApp.windowsMenu = menu.menu
        end
        if menu.is :help_menu
          NSApp.helpMenu = menu.menu
        end
      end
      setupMainMenu if @mainMenu
    end

    private

    def setupMainMenu
      NSApp.mainMenu = @mainMenu
    end
  end
end