module EverydayMenu
  class EverydayCommand
    attr_reader :label, :parent
    attr_writer :canExecute

    def initialize(parent, label, canExecute = true, &block)
      @parent          = parent
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

    def initialize(parent, label)
      @parent = parent
      @label  = label
      @items  = []
    end

    def add(&block)
      @items << EverydayCommand.new(@parent, @label, &block)
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

  module MyAccessors
    def has(key)
      name = self.class.key_to_name(key, 'has')
      if self.respond_to?(name)
        self.send(name)
      else
        self.containedObject.send(name)
      end
    end

    def is(key)
      name = self.class.key_to_name(key, 'is')
      if self.respond_to?(name)
        self.send(name)
      else
        self.containedObject.send(name)
      end
    end

    def [](key)
      name = self.class.key_to_name(key)
      if self.respond_to?(name)
        self.send(name)
      else
        self.containedObject.send(name)
      end
    end

    def []=(key, value)
      name = self.class.key_to_name(key, 'set')
      if self.respond_to?(name)
        self.send(name, value)
      else
        self.containedObject.send(name, value)
      end
    end

    class << self
      def self.key_to_name(key, prefix = nil)
        rval = key.to_s.gsub(/_(\w)/) { |_| $1.upcase }
        prefix.nil? ? rval : "#{prefix}#{rval[0].upcase}#{rval[1..-1]}"
      end

      def self.name_to_key(name)
        name.to_s.gsub(/A-Z/) { |c| c.downcase }.to_sym
      end

      def self.my_attr_accessor(*names)
        names.each { |name|
          var_name = :"@#{name.to_s}"
          define_method(name) { self.instance_variable_get(var_name) }
          define_method(:"#{name.to_s}=") { |val| self.instance_variable_set(var_name, val) }
          setName = :"set#{name.to_s[0].upcase}#{name.to_s[1..-1]}"
          define_method(setName) { |val| self.instance_variable_set(var_name, val) }
          name2 = name_to_key(name)
          define_method(name2) { self.instance_variable_get(var_name) }
          define_method(:"#{name2.to_s}=") { |val| self.instance_variable_set(var_name, val) }
        }
      end

      def self.my_attr_accessor_bool(*names)
        names.each { |name|
          var_name = :"@#{name.to_s}"
          define_method(name) { self.instance_variable_get(var_name) }
          define_method(:"#{name.to_s}=") { |val| self.instance_variable_set(var_name, val) }
          isName = :"#{key_to_name(name, 'is')}"
          define_method(isName) { self.instance_variable_get(var_name) }
          setName = :"#{key_to_name(name, 'set')}"
          define_method(setName) { |val| self.instance_variable_set(var_name, val) }
          name2 = name_to_key(name)
          define_method(name2) { self.instance_variable_get(var_name) }
          define_method(:"#{name2.to_s}?") { self.instance_variable_get(var_name) }
          define_method(:"#{name2.to_s}=") { |val| self.instance_variable_set(var_name, val) }
        }
      end

      def self.my_attr_reader(*names)
        names.each { |name|
          var_name = :"@#{name.to_s}"
          define_method(name) { self.instance_variable_get(var_name) }
          name2 = name_to_key(name)
          define_method(name2) { self.instance_variable_get(var_name) }
        }
      end

      def self.my_attr_reader_bool(*names)
        names.each { |name|
          var_name = :"@#{name.to_s}"
          define_method(name) { self.instance_variable_get(var_name) }
          isName = :"#{key_to_name(name, 'is')}"
          define_method(isName) { self.instance_variable_get(var_name) }
          name2 = name_to_key(name)
          define_method(name2) { self.instance_variable_get(var_name) }
          define_method(:"#{name2.to_s}?") { self.instance_variable_get(var_name) }
        }
      end

      def self.my_attr_writer(*names)
        names.each { |name|
          var_name = :"@#{name.to_s}"
          define_method(:"#{name.to_s}=") { |val| self.instance_variable_set(var_name, val) }
          setName = :"#{key_to_name(name, 'set')}"
          define_method(setName) { |val| self.instance_variable_set(var_name, val) }
          name2 = name_to_key(name)
          define_method(:"#{name2.to_s}=") { |val| self.instance_variable_set(var_name, val) }
        }
      end
    end
  end
end