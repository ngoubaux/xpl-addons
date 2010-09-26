iDomo.views.RoomsPanel = Ext.extend(Ext.Panel, {
      isLoaded: false,
      layout: 'card',
      initComponent: function() {        
	  this.backButton = new Ext.Button({
    	 text: 'Retour',
    	 ui: 'back',
    	 hidden: true,
    	 handler: function() { 
    	 
        	 var item = this.getActiveItem();
        	 
        	 if (item == this.ControlList) 
        		card = 1;
        	 else 
        	    card = 0;
        	 
        	 this.setCard(card,{type: 'slide', direction: 'right'});
        	 
        	 var dockedItems = this.getDockedItems();
        	 var header = this.dockedItems.items[0];
        	 
        	 header.setTitle(this.items.items[card].title);
        	 
        	 if (card == 0) {
        	 var compo = header.getComponent(0);
        		//compo.setVisible(true);
        		compo.hide();
        	 }
    	 }
    	       });
	
	 this.toolbar = new Ext.Toolbar({
		title: 'Pi&egrave;ces',
		dock: 'top',
		layout: {
		          pack: 'start'
		},
		defaults: {
    		scope: this,
    		ui: 'mask'
		},
		items: [//{flex: 1},
		      this.backButton,
				//this.refreshIcon
		]
	   });
	 
	 this.dockedItems = [this.toolbar];
	 
	   this.Roomlist = new iDomo.views.RoomsList({
	           scroll: true, 
	           title: 'Pi&egrave;ces'
	   });
	 
	   this.DeviceList = new iDomo.views.DevicesList({
	           scroll: true, 
	           title:'Devices'
	   });
	   
	   this.ControlList = new iDomo.views.ControlsList({
	           scroll: true, 
	           title:'Controls'
	   });
	
	     this.items = [this.Roomlist, this.DeviceList, this.ControlList];
	     iDomo.views.RoomsPanel.superclass.initComponent.call(this);
	     this.Roomlist.on('itemtap', this.onRoomItemTap, this);
	     this.DeviceList.on('itemtap', this.onDeviceItemTap, this);
	     this.ControlList.on('itemtap', this.onControlItemTap, this);
	 
	       //this.onRefreshTap();
    },
    
    changePanel: function (card, title) {
	   var header = this.dockedItems.items[0];
       header.getComponent(0).show();
       header.setTitle(title);
	   this.getComponent(card).title = title;
	   this.setCard(card, {type: 'slide', direction: 'left'});  
    },
    
    onControlItemTap: function(dv , index, item, e) {
        var ds = dv.getStore();
  	    r = ds.getAt(index);
	    eval(r.get('action'));
    },
    
    onDeviceItemTap: function (dv, index, item, e) {
        var ds = dv.getStore(),
	    r = ds.getAt(index);

	    var controls = r.get('controls');
        iDomo.stores.Controls.loadData(controls);
            
        this.changePanel(2, r.get('name'));  
    },
    
    onRoomItemTap: function(dv, index, item, e) {
       var ds = dv.getStore(),
	   r = ds.getAt(index);

	   var devices = r.get('devices');
       iDomo.stores.Devices.loadData(devices);

       this.changePanel(1, r.get('name'));  
	  // this.fireEvent('songselect', r.get('MediaKey'));
	  
	   var setting  = new iDomo.views.UserSetting({
			title: 'param',
			iconCls: 'settings'
		});
	    app.getTabBar().add(setting);
    },
    
	 
    onRefreshTap: function() {
 	/*setTimeout(function(){
                  if (!this.isLoaded) {
 		   Ext.getBody().mask(false, '<div class="loading">Loading&hellip;</div>');
 	          }
         }, 1);
         */
  //this.refreshIcon.setDisabled(true);
      //  iDomo.Service.fetchRooms(this.loadRoomsStore, this);
    },
	 
    loadRoomsStore: function(rooms) {
	 //this.refreshIcon.setDisabled(false);
	 //this.toolbar.setTitle("Pieces");
	    this.isLoaded = true;
	    Ext.getBody().unmask();
        iDomo.stores.Rooms.loadData(rooms);
    }
 });