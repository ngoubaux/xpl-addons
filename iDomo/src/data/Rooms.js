Ext.regModel('Rooms', {
			 idProperty: 'key',
			 fields: [
					  // id's
					  //'RoomKey',
					  
					  // basic info
					  'name',
					  'zone',
					  'temp',
					  'temp_cls',
					  'humidity',
					  'humidity_cls'
					  ]
			 });

iDomo.stores.Rooms = new Ext.data.Store({
									 model: 'Rooms'
									 });