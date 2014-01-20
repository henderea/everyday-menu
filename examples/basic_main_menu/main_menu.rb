class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :hide_others, 'Hide Others', key_equivalent: 'H', key_equivalent_modifier_mask: NSCommandKeyMask|NSAlternateKeyMask
  menuItem :quit, 'Quit', key_equivalent: 'q'

  menu :services, 'Services', services_menu: true
  menuItem :services_item, 'Services', submenu: :services

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'

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
  }
end
