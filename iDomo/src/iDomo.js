iDomo.App = Ext.extend(Ext.TabPanel, {
	cls: 'app',
	fullscreen: true,
	//layout: 'card',
	tabBar: {
    	dock: 'bottom',
    	ui:'dark',
    	layout: {
    	   pack: 'center'
    	}
	},
	ui: 'dark',    
	defaults: {
	   scroll: 'vertical'
	},
	
	initComponent: function() {  
	    this.customPanels = [];
	    
        this.isProfileLoaded=false;   
    	this.initiate();
    	
    	this.roomsPanel = new iDomo.views.RoomsPanel({
	       title: 'Rooms',
		   iconCls: 'icon-tabpanel-home',
        });
  	/*
    	this.groupPanel = new BH.views.GroupPanel({
    											  title:'stations',
    											  iconCls:'playlist',
    											  listeners:{
    											  activate:function(o) {
    											  if(!o.ownerCt.isProfileLoaded)
    											  alert('Please enter your credentials to see your Stations.');
    											  }
    											  }
    											  });
    	*/
    	this.userSettingPanel = new iDomo.views.UserSetting({
			title: 'settings',
			iconCls: 'settings'
		});
    	/*
    	this.aboutPanel = new Ext.Panel({
    									title:'about',
    									iconCls:'info',
    									contentEl:'about'
    									});
    	*/
    	this.items = [
            this.roomsPanel,
		    //this.analyticsPanel,this.groupPanel,
		    this.userSettingPanel
		    //,this.aboutPanel
		]; 
  	   iDomo.App.superclass.initComponent.call(this);
  	   
	   this.on('beforeactivate', this.onItemTap, this);
	   
    	this.roomsPanel.loadRoomsStore(iDomo.Service.rooms);
  	    //this.tabBar.items.items[1].setDisabled(true);
  	    //this.items.add(this.roomsPanel);
  	    
  	    //this.doLayout();
  	   //this.analyticsPanel.on('songselect', this.onSongSelect, this);
	},
	
	onItemTap: function(dv , index, item, e) {
          dv.setCard(0, {type: 'slide', direction: 'left'});  
    },
    
	afterRender: function() {
    	iDomo.App.superclass.afterRender.apply(this, arguments);
    	
    	Ext.getBody().on(Ext.isChrome ? 'click' : 'tap', 
    	   this.onLinkTap, this, {delegate: 'a.goOutside'});
	
	},
	
	loadConfiguration: function() {
	   /*
	   for (var i = this.items.length - 1; i > 1; i--) {
	       this.remove(this.items[i]);
	   }
	   this.doLayout();
	   */
	   iDomo.Service.loadConfiguration(this.onLoadConfiguration, this); 
	},
	
	initiate: function() { 
	   iDomo.Service.init();
	   this.loadConfiguration();
	//if (Get_Cookie('UserId') && Get_Cookie('Password')) {
	//iDomo.SubscriberService.fetchUserProfile(Get_Cookie('UserId'), Get_Cookie('Password'), this.onLoadProfile, this);
	//Ext.getBody().mask(false, '<div class="loading">loading&hellip;</div>');    
	//}
	},
	
	onLoadConfiguration: function (resp) {
	   this.roomsPanel.loadRoomsStore(resp.rooms);
	   this.loadCustomPanels(resp.panels);
	},
	
	loadCustomPanels: function (panels) {
	   for (var i = this.items.length - 1; i > 1; i--) {
	       this.remove(this.items[i]);
	   }
	   
	   for (i = 0; i < panels.length; i++) {
	       var panel = panels[i];
	       var card  = new iDomo.views.CustomPanel({
	            cls:    panel.name,
                id:     panel.name,
                title:  panel.name,
                //layout: 'card',
                iconCls: 'favorites',
                });
                
        card.loadControls(panel["controls"]);
  	    this.add(card);
  	    
	   }
	   /*
	   this.roomsPanel = new iDomo.views.RoomsPanel({
	       title: 'Rooms',
		   iconCls: 'icon-tabpanel-home',
        });
        
        this.userSettingPanel = new iDomo.views.UserSetting({
			title: 'settings',
			iconCls: 'settings'
		});
        
  	    this.add(this.roomsPanel);
  	    this.add(this.userSettingPanel);*/
  	    this.tabBar.doLayout();
	},
	
	onLinkTap: function(e, t) {        
	//e.stopEvent();
	//Geo.Util.openUrl(t.href);
	},    
	
	onSplashDeactivate: function() {
	//this.analyticsPanel.list.clearSelections();
	},
	
	onSongSelect: function(govtrack_id) {
	//alert('hit');
	//this.setCard(this.detail, Geo.defaultAnim);
	//this.detail.update(govtrack_id);
	}
});