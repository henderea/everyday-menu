class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :hide_others, 'Hide Others', preset: :hide_others
  menuItem :show_all, 'Show All', preset: :show_all
  menuItem :quit, 'Quit', preset: :quit

  menuItem :services_item, 'Services', preset: :services

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'

  mainMenu(:app, 'Blah') {
    hide_others
    show_all
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
  }
end
