iDomo.views.DevicesList = Ext.extend(Ext.List, {
  itemSelector: '.device-list-item',
  singleSelect: true,
  initComponent: function() {
    this.store = iDomo.stores.Devices;
    this.tpl = Ext.XTemplate.from('device-list');
    iDomo.views.DevicesList.superclass.initComponent.call(this);
  }
});