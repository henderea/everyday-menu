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

    def md5(str)
      str.dataUsingEncoding(NSUTF8StringEncoding).MD5HexDigest
    end

    def unique_id
      md5(WeakRef.new("#{@rand.rand}#{@rand.rand}"))
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
      get_val(self.class.key_to_name(key, 'has'))
    end

    def is(key)
      get_val(self.class.key_to_name(key, 'is'))
    end

    def [](key)
      get_val(self.class.key_to_name(key))
    end

    def []=(key, value)
      set_val(self.class.key_to_name(key, 'set'), value)
    end

    class << self
      def self.setup_obj(obj, label, title, options)
        obj[:label] = label
        obj[:title] = title
        fill_options(obj, options)
      end

      def self.fill_options(obj, options)
        options.each { |option| obj[option[0]] = option[1] }
      end

      def self.key_to_name(key, prefix = nil)
        rval = WeakRef.new(WeakRef.new(key.to_s).gsub(/_(\w)/) { |_| WeakRef.new(WeakRef.new($1).upcase) })
        prefix.nil? ? rval : WeakRef.new("#{prefix}#{WeakRef.new(WeakRef.new(rval[0]).upcase)}#{WeakRef.new(rval[1..-1])}")
      end

      def self.name_to_key(name)
        WeakRef.new(WeakRef.new(name.to_s).gsub(/A-Z/) { |c| WeakRef.new(WeakRef.new(c).downcase) }).to_sym
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

      def self.define_methods(*names, &block)
        names.each { |name| define_method(name, &block) }
      end

      def self.def_getter(name, do_is = false)
        var_name, isName, name2, name2_is = getter_names(name)
        block                             = ->() { self.instance_variable_get(var_name) }
        define_methods(name, name2, &block)
        define_methods(isName, name2_is, &block) if do_is
      end

      def self.def_setter(name)
        var_name, setName, name_e, name2_e = setter_names(name)
        block                              = ->(val) { self.instance_variable_set(var_name, val) }
        define_methods(name_e, setName, name2_e, &block)
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