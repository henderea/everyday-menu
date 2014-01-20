# EverydayMenu

## Updates
* 0.4.0:
    * Please see the "Introducing Presets!" section below for an awesome new feature!
* 1.0.0:
    * Please see the "Introducing Statusbar Menus!" section below for another awesome new feature!

## Issue Tracking
Please use <https://everydayprogramminggenius.atlassian.net/browse/EM> for issue tracking.

## Credit
Please note that this gem is strongly based off of Joe Fiorini's `drink-menu` gem (with a little code copy-paste and lots of test and readme copy-paste), which I couldn't get to work for me.

You can find his gem at <https://github.com/joefiorini/drink-menu>.  He doesn't get all of the credit, but he gets a lot of it.

## Installation

Add this line to your application's Gemfile:

    gem 'everyday-menu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install everyday-menu

## Usage

Everyday Menu separates menu layout from menu definition. Menu definition looks like:


```ruby
class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :hide_others, 'Hide Others', key_equivalent: 'H', key_equivalent_modifier_mask: NSCommandKeyMask|NSAlternateKeyMask
  menuItem :quit, 'Quit', key_equivalent: 'q'

  menu :services, 'Services', services_menu: true
  menuItem :services_item, 'Services', submenu: :services

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'
  menuItem :start_stop, 'Start'
end

```

Layout is as simple as:

```ruby
class MainMenu
  extend EverydayMenu::MenuBuilder

  mainMenu(:app, 'Blah') {
    hide_others
    ___
    services_item
    ___
    quit
  }

  mainMenu(:file, 'File') {
    new
    open
    ___
    close
    ___
    start_stop
  }
end
```

And actions are as simple as:
```ruby
class AppDelegate
  def applicationDidFinishLaunching(notification)
    @has_open = false
    MainMenu.build!

    MainMenu[:app].subscribe(:hide_others) { |_, _| NSApp.hideOtherApplications(self) }
    MainMenu[:app].subscribe(:quit) { |_, _| NSApp.terminate(self) }    

    MainMenu[:file].subscribe(:start_stop) { |command, _|
      @started               = !@started
      command.parent[:title] = @started ? 'Stop' : 'Start'
    }
    MainMenu[:file].subscribe(:new) { |_, _|
      @has_open = true
      puts 'new'
    }

    MainMenu[:file].subscribe(:close) { |_, _|
      @has_open = false
      puts 'close'
    }.canExecuteBlock { |_| @has_open }

    MainMenu[:file].subscribe(:open) { |_, _|
      @has_open = true
      puts 'open'
    }
  end
end
```

You can even put multiple actions on a single item by calling subscribe multiple times.

The block passed to `subscribe` takes two parameters, the command instance and the sender.  The command instance has knowledge of the label (`command.label`) and (as of version 1.1.0) the parent `EverydayMenu::MenuItem` instance (`command.parent`).  In the above example, the parent instance is used to toggle the menu item text between 'Start' and 'Stop'.

## Introducing Presets!
With version 0.4.0, I have added the capability to use some presets.  Here is the above example with presets:

```ruby
class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :hide_others, 'Hide Others', preset: :hide_others
  menuItem :show_all, 'Show All', preset: :show_all
  menuItem :quit, 'Quit', preset: :quit

  menuItem :services_item, 'Services', preset: :services

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'
end
```

with actions defined as:

```ruby
class AppDelegate
  def applicationDidFinishLaunching(notification)
    @has_open = false
    MainMenu.build!

    MainMenu[:file].subscribe(:new) { |_, _|
      @has_open = true
      puts 'new'
    }
    MainMenu[:file].subscribe(:close) { |_, _|
      @has_open = false
      puts 'close'
    }.canExecuteBlock { |_| @has_open }
    MainMenu[:file].subscribe(:open) { |_, _|
      @has_open = true
      puts 'open'
    }
  end
end
```

I didn't use a preset for close because there was special handling.  Here are the presets and what they do:

Preset | Settings | Action
--------|-----------------------|------------------------------
`:hide` | `key_equivalent: 'h'` | <code>{ &#124;_, _&#124; NSApp.hide(self) }</code>
`:hide_others` | `key_equivalent: 'H'` <br> and <br> <code>:key\_equivalent\_modifier_mask: NSCommandKeyMask&#124;NSAlternateKeyMask</code> | <code>{ &#124;_, _&#124; NSApp.hideOtherApplications(self) }</code>
`:show_all` | none | <code>{ &#124;_, _&#124; NSApp.unhideAllApplications(self) }</code>
`:quit` | `key_equivalent: 'q'` | <code>{ &#124;_, _&#124; NSApp.terminate(self) }</code>
`:close` | `key_equivalent: 'w'` | <code>{ &#124;_, _&#124; NSApp.keyWindow.performClose(self) }</code>
`:services` | `submenu: (menu :services, <item-title>, services_menu: true)` | none

Let me know if you have any others you think I should add.  If you want to add one of your own, I have included the ability to define presets.  You will want to do this at the top of the file where you setup your menu items.  Here is an example:

```ruby
EverydayMenu::MenuItem.definePreset(:hide_others) { |item|
  item[:key_equivalent]               = 'H'
  item[:key_equivalent_modifier_mask] = NSCommandKeyMask|NSAlternateKeyMask
  item.subscribe { |_, _| NSApp.hideOtherApplications(item) }
}
```

Since the block is being run after the item instance is created, you have to use the other syntax, `item[<key>]=` in order to set the values.  If you want to create a submenu in this, you can use `EverydayMenu::Menu.create(label, title, options = {})`, which accepts the same parameters as the `menu` method when building the menu normally.

If you set some application property (like `NSApp.servicesMenu`) in your method, you should probably have that delayed until the whole menu setup is built.  You can do that like this:

```ruby
EverydayMenu::MenuItem.definePreset(:services) { |item|
  item[:submenu] = Menu.create(:services_menu, item[:title], services_menu: true)
  item.registerOnBuild { NSApp.servicesMenu = item[:submenu] }
}
```

Any block you pass to `item.registerOnBuild(&block)` will be added to a list of blocks to be run when the menu setup is built.

## Introducing Statusbar Menus!
As of version 1.0.0, `everyday-menu` now supports creating statusbar menus.  With this addition, I believe I have finally matched all of the important features of `drink-menu`.

Here's how you can make a menu be for the statusbar icon:

```ruby
class MainMenu
  extend EverydayMenu::MenuBuilder
  
  menuItem :status_open, 'Open', key_equivalent: 'o'
  menuItem :status_new, 'New'
  menuItem :status_close, 'Close', key_equivalent: 'w'
  menuItem :status_quit, 'Quit', preset: :quit

  statusbarMenu(:statusbar, 'Statusbar Menu', status_item_icon: 'icon', status_item_view_class: ViewClass) {
    status_new
    status_open
    ___
    status_close
    ___
    status_quit
  }
end
```

This will create a statusbar menu with the specified title, icon, and view class.

You can also create a statusbar menu by using the key `status_item_title:`, `status_item_icon:`, and/or `status_item_view_class:` in a regular (non-main) menu.  Other than the addition of these parameters, a statusbar menu has all of the same parameters as a regular menu.


## Known Issues

Here are known issues.  If you encounter one, please log a bug ticket in the issue tracker (link above)

1. Some methods in `NSMenuItem` that set values don't like being called with `send`.  I have to handle these on a case-by-case basis.  Please log a bug in my issue tracker (link above) with any you find.  It is possible that `NSMenu` might have the same issue.

## Running the Examples

To run our example apps:

1. Clone this repo
2. From within your clone's root, run `platform=osx example=basic_main_menu rake`

You can replace the value of `example` with any folder under the `examples` directory to run that example.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
