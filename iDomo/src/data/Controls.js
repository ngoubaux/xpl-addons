Ext.regModel('Controls', {
			 idProperty: 'key',
			 fields: [
					  // id's
					  //'RoomKey',
					  'action',
					  // basic info
					  'name',
					  ]
			 });

iDomo.stores.Controls = new Ext.data.Store({
									 model: 'Controls'
									 });