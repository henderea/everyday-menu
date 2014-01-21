describe 'creating menu items' do

  it 'keeps the title and label' do
    m = EverydayMenu::MenuItem.create :create_site, 'Create Site'
    m[:label].should.equal :create_site
    m[:title].should.equal 'Create Site'
  end

  it 'has an instance of NSMenuItem' do
    m = EverydayMenu::MenuItem.create :create_site, 'Create Site'
    m.menuItem.should.be.a.instance_of NSMenuItem
  end

  it 'allows extra options to create method' do
    m = EverydayMenu::MenuItem.create :create_site, 'Create Site', enabled: false, tag: 1, state: NSOnState
    m.menuItem.title.should.equal m[:title]
    m.menuItem.isEnabled.should.equal m.is :enabled
    m.menuItem.tag.should.equal m[:tag]
    m.menuItem.state.should.equal m[:state]
  end

  it 'allows creating separator items' do
    item = EverydayMenu::MenuItem.separatorItem
    item.is(:separator_item).should.be.true
  end

  def separator_id(item)
    item.label[/\d+$/].to_i
  end

  it 'generates unique label for separators' do
    item1 = EverydayMenu::MenuItem.separatorItem
    item2 = EverydayMenu::MenuItem.separatorItem
    separator_id(item2).should.equal separator_id(item1) + 1
  end

end
