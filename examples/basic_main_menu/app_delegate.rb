class AppDelegate
  def applicationDidFinishLaunching(notification)
    @has_open = false
    @started  = false
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
    MainMenu[:file].subscribe(:start_stop, :start_stop_command_id) { |command, _|
      @started               = !@started
      command.parent[:title] = @started ? 'Stop' : 'Start'
      puts "subscribe 1 command id: #{command.command_id}"
    }
    MainMenu[:file].subscribe(:start_stop, :start_stop_command_id2) { |command, _|
      puts "subscribe 2 command id: #{command.command_id}"
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
