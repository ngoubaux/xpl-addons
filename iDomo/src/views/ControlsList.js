iDomo.views.ControlsList = Ext.extend(Ext.List, {
  itemSelector: '.control-list-item',
  singleSelect: true,
  initComponent: function() {
    this.store = iDomo.stores.Controls;
    this.tpl = Ext.XTemplate.from('control-list');
    iDomo.views.DevicesList.superclass.initComponent.call(this);
  }
});