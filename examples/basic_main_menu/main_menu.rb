class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :hide_others, 'Hide Others', preset: :hide_others
  menuItem :show_all, 'Show All', preset: :show_all
  menuItem :quit, 'Quit', preset: :quit

  menuItem :services_item, 'Services', preset: :services

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'

  menuItem :status_open, 'Open', key_equivalent: 'o'
  menuItem :status_new, 'New'
  menuItem :status_close, 'Close', key_equivalent: 'w'
  menuItem :status_quit, 'Quit', preset: :quit


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

  statusbarMenu(:statusbar, 'Statusbar Menu') {
    status_new
    status_open
    ___
    status_close
    ___
    status_quit
  }
end
