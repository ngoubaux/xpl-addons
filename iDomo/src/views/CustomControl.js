iDomo.views.CustomControl = Ext.extend(Ext.Component, {
  itemSelector: '.customcontrol-item',
  cls: 'customcontrol',
  //flex: 1,
  constructor: function(config) {
    var action = config.action;
    this.control = config.control;
    var device = this.control.device;
    var room = device.room;
    
    var str = "";
   
    str += '<div class="device" id="' + device.key + '" >' + room.name + ' ' + device.name + '</div>';
    str += '<div id="' + device.key + '_' + this.control.key + '"';
    str += ' class="control ' + device.key + ' ' + this.control.key + '">';
    str += this.control.name + '</div>';

    this.update(str);

    iDomo.views.CustomControl.superclass.constructor.call(this, config);
  },
  
  afterRender: function() {
        iDomo.views.CustomControl.superclass.afterRender.call(this);
        
        this.mon(this.el, {
            tap: this.onTap,
            scope: this
        });
    },
    
    onTap: function() {
        eval(this.control.action);
    }
});
