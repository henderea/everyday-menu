class TestMenu; extend EverydayMenu::MenuBuilder; end
class TestMenu2; include EverydayMenu::MenuBuilder; end

describe 'sugar for creating menus' do

  it 'supports defining menu items' do
    menuItem = TestMenu.menuItem :create_site, 'Create Site'
    menuItem[:label].should.equal :create_site
    menuItem[:title].should.equal 'Create Site'
  end

  it 'builds gives access to menu instance' do
    TestMenu.menuItem :create_site, 'Create Site'
    TestMenu.menu :main_menu, 'Main'
    menu = TestMenu[:main_menu]
    menu.should.be.an.instance_of EverydayMenu::Menu
  end

  it 'allows creating a top-level menu' do
    menu = TestMenu.menu :main_menu, 'Blah'
    menu.menu.should.be.an.instance_of NSMenu
    menu[:title].should.equal 'Blah'
  end

  it 'evaluates menu\'s block to add items to menu' do
    builder = TestMenu2.new
    item1   = builder.menuItem :test_item1, 'Blah'
    item2   = builder.menuItem :test_item2, 'Blah'

    builder.menu :main_menu, 'Main' do
      test_item1
      ___
      test_item2
    end

    builder.build!

    builder[:main_menu].items[:test_item1].should.equal item1
    builder[:main_menu].items[:test_item2].should.equal item2

    builder[:main_menu].items[2].is(:separator_item).should.be.true
  end

  it 'supports generating an NSApp\'s mainMenu items' do
    builder   = TestMenu2.new
    testItem1 = builder.menuItem :test_item1, 'Blah 1'
    testItem2 = builder.menuItem :test_item2, 'Blah 2'

    menu1 = builder.mainMenu :menu1, 'Menu 1' do
      test_item1
    end

    menu2 = builder.mainMenu :menu2, 'Menu 2' do
      test_item2
    end

    builder.build!

    mainMenu = NSApp.mainMenu

    menuItem = mainMenu.itemArray[0]
    puts "menu1 title: #{menu1[:title].inspect}"
    puts "menuItem title: #{menuItem.title.inspect}"
    menuItem.title.should.equal menu1[:title]
    menuItem.submenu.title.should.equal menu1[:title]
    menuItem.submenu.itemArray[0].title.should.equal('Blah 1')

    menuItem = mainMenu.itemArray[1]
    menuItem.title.should.equal menu2[:title]
    menuItem.submenu.title.should.equal menu2[:title]
    menuItem.submenu.itemArray[0].title.should.equal('Blah 2')
  end

  describe 'builder\'s context class' do

    Context = EverydayMenu::MenuBuilder::Context

    it 'adds item to menu by calling method named after item\'s label' do
      menu    = EverydayMenu::Menu.create :test, 'Test'
      item    = EverydayMenu::MenuItem.create :test_item, 'Blah'
      context = Context.new(menu, { test_item: item })

      menu.items[:test_item].should.be.nil

      context.test_item

      menu.items[:test_item].should.equal item
    end

    it 'creates separators from ___' do
      menu = EverydayMenu::Menu.create :test, 'Test'

      menu.items[1].should.be.nil

      Context.new(menu).__send__ :'___'

      menu.items[1].is(:separator_item).should.be.true
    end

  end
end
