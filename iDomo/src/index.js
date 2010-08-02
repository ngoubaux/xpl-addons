Ext.ns('iDomo', 'iDomo.views', 'iDomo.cache', 'iDomo.stores', 'iDomo.DB');

var app;

Ext.setup({
  icon: 'iDomo.png',
  tabletStartupScreen: 'tablet_startup.png',
  phoneStartupScreen: 'phone_startup.png',
  glossOnIcon: false,
  
  onReady: function() {
       app = new iDomo.App();
  },
		  
});
