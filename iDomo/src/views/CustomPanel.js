iDomo.views.CustomPanel = Ext.extend(Ext.Panel, {
      isLoaded: false,
    /*  layout: {
            type: 'hbox',
      },
     */ 
      layoutConfig: {
            align: 'stretch',
            pack: 'start'
      },
        
      initComponent: function() {          
  	     iDomo.views.CustomPanel.superclass.initComponent.call(this);
      },
      
      loadControls: function(controls) {
          for (var i = 0; i < controls.length; i++) {
             var ctr = controls[i];
             var control = new iDomo.views.CustomControl({
                   title: ctr["name"], 
                   control: ctr,
                   action: ctr["action"],
             });
             this.add(control); 
          }
          this.doLayout();
      }    
});
