class EverydayRmDigest
  include RmDigest
end

module EverydayMenu
  class EverydayCommand
    attr_reader :label, :parent, :command_id
    attr_writer :canExecute

    def initialize(parent, label, command_id = nil, canExecute = true, &block)
      @parent          = parent
      @label           = label
      @block           = block
      @command_id      = command_id
      @canExecute      = canExecute
      @canExecuteBlock = nil
    end

    def canExecuteBlock(&block)
      @canExecuteBlock = block
      self
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
      @items  = {}
      @rand   = Random.new
    end

    def unique_id
      EverydayRmDigest::MD5.hexdigest("#{@rand.rand}#{@rand.rand}")
    end

    def rand_id
      :"command_id_#{unique_id}"
    end

    def add(command_id = nil, &block)
      id         = command_id || rand_id
      @items[id] = EverydayCommand.new(@parent, @label, id, &block)
    end

    def [](id)
      @items[id]
    end

    def execute(sender)
      @items.values.each { |item| item.execute(sender) }
    end

    def canExecute
      @items.values.any? { |item| item.canExecute }
    end
  end

  module MyAccessors
    def get_val(name)
      self.respond_to?(name) ? self.send(name) : self.containedObject.send(name)
    end

    def set_val(name, value)
      self.respond_to?(name) ? self.send(name, value) : self.containedObject.send(name, value)
    end

    def has(key)
      name = self.class.key_to_name(key, 'has')
      get_val(name)
    end

    def is(key)
      name = self.class.key_to_name(key, 'is')
      get_val(name)
    end

    def [](key)
      name = self.class.key_to_name(key)
      get_val(name)
    end

    def []=(key, value)
      name = self.class.key_to_name(key, 'set')
      set_val(name, value)
    end

    class << self
      def self.setup_obj(obj, label, title, options)
        obj[:label] = label
        obj[:title] = title
        options.each { |option| obj[option[0]] = option[1] }
      end

      def self.key_to_name(key, prefix = nil)
        rval = key.to_s.gsub(/_(\w)/) { |_| $1.upcase }
        prefix.nil? ? rval : "#{prefix}#{rval[0].upcase}#{rval[1..-1]}"
      end

      def self.name_to_key(name)
        name.to_s.gsub(/A-Z/) { |c| c.downcase }.to_sym
      end

      def self.getter_names(name)
        name2, var_name = common_names(name)
        isName          = :"#{key_to_name(name, 'is')}"
        name2_is        = :"#{name2.to_s}?"
        return var_name, isName, name2, name2_is
      end

      def self.setter_names(name)
        name2, var_name = common_names(name)
        setName         = :"#{key_to_name(name, 'set')}"
        name_e          = :"#{name.to_s}="
        name2_e         = :"#{name2.to_s}="
        return var_name, setName, name_e, name2_e
      end

      def self.common_names(name)
        var_name = :"@#{name.to_s}"
        name2    = name_to_key(name)
        return name2, var_name
      end

      def self.def_getter(name, do_is = false)
        var_name, isName, name2, name2_is = getter_names(name)
        block                             = ->() { self.instance_variable_get(var_name) }
        define_method(name, &block)
        define_method(name2, &block)
        def_getter_is(isName, name2_is, &block) if do_is
      end

      def self.def_getter_is(isName, name2_is, &block)
        define_method(isName, &block)
        define_method(name2_is, &block)
      end

      def self.def_setter(name)
        var_name, setName, name_e, name2_e = setter_names(name)
        block                              = ->(val) { self.instance_variable_set(var_name, val) }
        define_method(name_e, &block)
        define_method(setName, &block)
        define_method(name2_e, &block)
      end

      def self.my_attr_accessor(*names)
        names.each { |name|
          def_getter(name)
          def_setter(name)
        }
      end

      def self.my_attr_accessor_bool(*names)
        names.each { |name|
          def_getter(name, true)
          def_setter(name)
        }
      end

      def self.my_attr_reader(*names)
        names.each { |name|
          def_getter(name)
        }
      end

      def self.my_attr_reader_bool(*names)
        names.each { |name|
          def_getter(name, true)
        }
      end

      def self.my_attr_writer(*names)
        names.each { |name|
          def_setter(name)
        }
      end
    end
  end
end