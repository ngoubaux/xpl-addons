iDomo.views.RoomsList = Ext.extend(Ext.List, {
  itemSelector: '.room-list-item',
  singleSelect: true,
  initComponent: function() {
    this.store = iDomo.stores.Rooms;
    this.tpl = Ext.XTemplate.from('room-list');
    iDomo.views.RoomsList.superclass.initComponent.call(this);
  }
});