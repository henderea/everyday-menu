class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :quit, 'Quit', key_equivalent: 'q'

  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'
  menuItem :close, 'Close', key_equivalent: 'w'

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
