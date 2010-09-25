iDomo.views.UserSetting = Ext.extend(Ext.form.FormPanel, {    
	initComponent: function() {
	
    this.password = new Ext.form.PasswordField({
       name: 'auth',
       label: 'Auth'
    });
    
    this.shuffle = new Ext.form.Toggle({
       name:'shuffle',
       label:'shuffle'
    });
    
    this.jsonUri = new Ext.form.TextField({
       name: 'jsonuri',
       label: 'Json URI'
    });
    
    this.resetDB = new Ext.Button({
       name: 'DBSync',
       text:'Synchronize',
       handler: function() { 
         iDomo.Service.ResetDB(); 
                     app.loadConfiguration();
       }
    });
    
    this.UpdateCache = new Ext.Button({
       name: 'Update',
       text:'Update',
       handler: function() { 
          var appCache = window.applicationCache
          if (appCache.status == appCache.UPDATEREADY ){
              appCache.swapCache()
          }
       }
    });
     
    this.fsProfile = new Ext.form.FieldSet({
       title: 'profile',
       instructions: 'Please enter your info.  See about tab for details.',
       items: [this.password]
    });
    
    this.fsPreference = new Ext.form.FieldSet({
      title:'preferences',
      items: [this.jsonUri, this.resetDB, this.UpdateCache]
    });
    
    this.items = [this.fsProfile,this.fsPreference];
    
    this.dockedItems = [{
         xtype: 'toolbar',
         dock: 'top',
         items: [                 
                 {xtype:'spacer'},
            {
      		text: 'Save',
      		ui: 'action',
      		scope:this,
      		handler: this.setUserInfo
      	}
          ]
    }];
    
    this.on('activate', this.getUserInfo, this);
    iDomo.views.UserSetting.superclass.initComponent.call(this);
    },
	
    getUserInfo: function() {
	
	   var jsonuri = app.GetJSONUri();
	
	   this.setValues({ 
            auth: localStorage.getItem('auth'),
            jsonuri: jsonuri,
	   });
	//this.shuffle.setValue(parseInt(Get_Cookie('shuffle'))); 
	},
	
     setUserInfo: function() {
	//Ext.getBody().mask(false, '<div class="loading">loading&hellip;</div>');
	//iDomo.SubscriberService.fetchUserProfile(this.getValues().password, this.onCheckUserInfo, this);
	       localStorage.setItem('auth', this.getValues().auth); 
	       localStorage.setItem('jsonuri', this.getValues().jsonuri); 
	},
	
});
