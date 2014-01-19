module EverydayMenu
  class EverydayCommand
    attr_reader :label
    attr_writer :canExecute

    def initialize(label, canExecute = true, &block)
      @label           = label
      @block           = block
      @canExecute      = canExecute
      @canExecuteBlock = nil
    end

    def canExecuteBlock(&block)
      @canExecuteBlock = block
    end

    def canExecute
      @canExecuteBlock.nil? ? @canExecute : @canExecuteBlock.call(self)
    end

    def execute(sender)
      @block.call(self, sender)
    end
  end

  class CommandList
    attr_accessor :label

    def initialize(label)
      @label = label
      @items = []
    end

    def add(&block)
      @items << EverydayCommand.new(@label, &block)
    end

    def last
      @items.last
    end

    def execute(sender)
      @items.each { |item| item.execute(sender) }
    end

    def canExecute
      @items.any? { |item| item.canExecute }
    end
  end
end