Ext.regModel('Rooms', {
			 idProperty: 'key',
			 fields: [
					  // id's
					  //'RoomKey',
					  
					  // basic info
					  'name',
					  'zone',
					  ]
			 });

iDomo.stores.Rooms = new Ext.data.Store({
									 model: 'Rooms'
									 });