describe 'creating menus' do


  it 'creates an NSMenu instance' do
    menu = EverydayMenu::Menu.create :test, 'Test'
    menu.menu.should.be.an.instance_of NSMenu
  end

  it 'sets title on NSMenu instance' do
    menu = EverydayMenu::Menu.create :test_menu, 'title'
    menu[:title].should.equal 'title'
    menu.menu.title.should.equal menu[:title]
  end

  it 'automatically adds NSMenuItem instance to NSMenu' do
    menu = EverydayMenu::Menu.create :test, 'Test'
    item = EverydayMenu::MenuItem.create :test_item, 'Blah'
    menu << item

    menu[:item_array].should.include item.menuItem

  end

  it 'sets a unique tag on each menu item as it is added' do
    menu  = EverydayMenu::Menu.create :test, 'Test'
    item1 = EverydayMenu::MenuItem.create :test_item1, 'Blah'
    item2 = EverydayMenu::MenuItem.create :test_item2, 'Diddy'

    menu << item1
    menu << item2

    item1.menuItem.tag.should.equal 1
    item2.menuItem.tag.should.equal 2

  end

  it 'allows looking up menu items by label' do
    menu = EverydayMenu::Menu.create :test, 'Test'
    item = EverydayMenu::MenuItem.create :test_item, 'Blah'

    menu << item

    menu.items[item.label].should.equal item
  end

  it 'allows selecting an item by its label' do
    handled = false
    menu    = EverydayMenu::Menu.create :test, 'Test'
    item    = EverydayMenu::MenuItem.create :test_item, 'Blah'

    menu << item

    menu.subscribe :test_item do |_|
      handled = true
    end

    menu.selectItem :test_item

    handled.should.be.true
  end

  it 'allows looking up menu items by tag' do
    menu = EverydayMenu::Menu.create :test, 'Test'
    item = EverydayMenu::MenuItem.create :test_item, 'Blah'

    menu << item

    menu.items[1].should.equal item
  end
end
