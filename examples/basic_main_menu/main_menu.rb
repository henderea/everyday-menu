class MainMenu
  extend EverydayMenu::MenuBuilder

  def self.def_items
    menuItem :hide_others, 'Hide Others', preset: :hide_others
    menuItem :show_all, 'Show All', preset: :show_all
    menuItem :quit, 'Quit', preset: :quit

    menuItem :services_item, 'Services', preset: :services

    menuItem :open, 'Open', key_equivalent: 'o'
    menuItem :new, 'New'
    menuItem :close, 'Close', key_equivalent: 'w'
    menuItem :start_stop, 'Start'

    menuItem :status_date, 'Date: ', dynamicTitle: -> { "Date: #{NSDate.date.to_s}" }
    menuItem :status_open, 'Open', key_equivalent: 'o'
    menuItem :status_new, 'New'
    menuItem :status_close, 'Close', key_equivalent: 'w', opt: true
    menuItem :status_quit, 'Quit', preset: :quit
  end

  def self.def_menus
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
      ___
      start_stop
    }

    statusbarMenu(:statusbar, 'Statusbar Menu') {
      status_date
      ___
      status_new
      status_open
      ___
      status_close
      ___
      status_quit
    }
  end

  def_menus
  def_items
end
