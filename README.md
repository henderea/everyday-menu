# EverydayMenu

[![Gem Version](https://badge.fury.io/rb/everyday-menu.png)](http://badge.fury.io/rb/everyday-menu)
[![Build Status](https://travis-ci.org/henderea/everyday-menu.png?branch=master)](https://travis-ci.org/henderea/everyday-menu)
[![Dependency Status](https://gemnasium.com/henderea/everyday-menu.png)](https://gemnasium.com/henderea/everyday-menu)
[![Code Climate](https://codeclimate.com/github/henderea/everyday-menu.png)](https://codeclimate.com/github/henderea/everyday-menu)

## Updates
* 0.2.0:
    * Create `EverydayCommand` to allow control of enablement of menu items
* 0.2.1:
    * Fix a set method issue and resolve the error messages about missing methods
* 0.3.0:
    * Add handling for `NSApp.servicesMenu`, `NSApp.windowsMenu`, and `NSApp.helpMenu`
* 0.4.0:
    * Please see the "Introducing Presets!" section below for an awesome new feature!
* 1.0.0:
    * Please see the "Introducing Statusbar Menus!" section below for another awesome new feature!
* 1.1.0:
    * Added reference to parent `MenuItem` instance to `EverydayCommand`
* 1.2.0:
    * Added the ability to have individual ids for each command
* 1.3.0:
    * Commands now get a random id if you don't give them one
    * You can now access a command by id
    * I now have a runtime dependency, the gem `rm-digest`, but it has the necessary objective-c code built-in, so     there shouldn't be any extra work for users of `everyday-menu`
* 1.3.1:
    * Oops, I forgot to test outside the gem before releasing.  The dependency issue should be fixed now.
* 1.3.2:
    * Get tests working and add the missing `selectItem` method in `EverydayMenu::Menu`

## Credit
Please note that this gem is based off of Joe Fiorini's `drink-menu` gem (with a little code copy-paste and lots of test and readme copy-paste), which I couldn't get to work for me.

You can find his gem at <https://github.com/joefiorini/drink-menu>.  He doesn't get all of the credit, but he gets a fair amount of it.

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

    MainMenu[:file].subscribe(:start_stop, :start_stop_command_id) { |command, _|
      @started               = !@started
      command.parent[:title] = @started ? 'Stop' : 'Start'
      puts "subscribe 1 command id: #{command.command_id}"
    }
    MainMenu[:file].subscribe(:start_stop, :start_stop_command_id2) { |command, _|
      puts "subscribe 2 command id: #{command.command_id}"
    }
    MainMenu[:file].subscribe(:new) { |_, _|
      @has_open = true
      puts 'new'
    }

    MainMenu[:file].subscribe(:close) { |_, _|
      @has_open = false
      puts 'close'
    }.canExecuteBlock { |_| @has_open }

    MainMenu[:file].subscribe(:open) { |command, _|
      @has_open = true
      puts 'open'
      puts "open subscribe 1 command id: #{command.command_id}"
    }
    MainMenu[:file].subscribe(:open) { |command, _|
      puts "open subscribe 2 command id: #{command.command_id}"
    }
    puts "start_stop subscribe 1 parent label: #{MainMenu[:file].items[:start_stop][:commands][:start_stop_command_id].label}"
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
