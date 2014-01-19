# EverydayMenu

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

  menuItem :quit, 'Quit', key_equivalent: 'q'

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'
end

```

Layout is as simple as:

```ruby
class MainMenu
  extend EverydayMenu::MenuBuilder

  mainMenu(:app, 'Blah') {
    quit
  }

  mainMenu(:file, 'File') {
    new
    open
    ___
    close
  }
end
```

And actions are as simple as:
```ruby
class AppDelegate
  def applicationDidFinishLaunching(notification)
    @has_open = false
    MainMenu.build!

    MainMenu[:app].subscribe(:quit) { |_, _| NSApp.terminate(self) }

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
