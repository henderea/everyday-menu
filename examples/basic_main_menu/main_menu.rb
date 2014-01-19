class MainMenu
  extend EverydayMenu::MenuBuilder

  menuItem :quit, 'Quit', key_equivalent: 'q'
  menuItem :open, 'Open', key_equivalent: 'o'
  menuItem :new, 'New'

  menuItem :close, 'Close', key_equivalent: 'w'

  mainMenu :app, 'Blah' do
    quit
  end

  mainMenu :file, 'File' do
    new
    open
    ___
    close
  end
end
