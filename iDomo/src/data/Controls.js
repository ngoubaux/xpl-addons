Ext.regModel('Controls', {
			 idProperty: 'key',
			 fields: [
					  // id's
					  //'RoomKey',
					  'action',
					  // basic info
					  'name',
					  'img_cls',
					  'name_cls',
					  ]
			 });

iDomo.stores.Controls = new Ext.data.Store({
									 model: 'Controls'
									 });