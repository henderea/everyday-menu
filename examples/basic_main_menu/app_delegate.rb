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
    MainMenu[:statusbar].subscribe(:status_new) { |_, _|
      @has_open = true
      puts 'status-new'
    }
    MainMenu[:statusbar].subscribe(:status_close) { |_, _|
      @has_open = false
      puts 'status-close'
    }.canExecuteBlock { |_| @has_open }
    MainMenu[:statusbar].subscribe(:status_open) { |_, _|
      @has_open = true
      puts 'status-open'
    }
  end
end
