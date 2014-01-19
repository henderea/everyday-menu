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

  menuItem :create_site, 'Create Site'
  menuItem :export, 'Export to Folder...'
  menuItem :import, 'Import Folder as Site...'
  menuItem :force_rebuild, 'Force Rebuild'
  menuItem :about, 'About Staticly'
  menuItem :quit, 'Quit', key_equivalent: 'q'
end
```

and then layout is as simple as:

```ruby

class MainMenu
  extend EverydayMenu::MenuBuilder

  mainMenu :main_menu, 'Main Menu' do
    create_site
    ___
    export
    import
    force_rebuild
    ___
    about
    quit
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
