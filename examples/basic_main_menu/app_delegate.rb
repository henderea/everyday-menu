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
