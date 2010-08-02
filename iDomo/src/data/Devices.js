Ext.regModel('Devices', {
			 idProperty: 'key',
			 fields: [
					  // id's
					  //'RoomKey',
					  'room_id',
					  // basic info
					  'name',
					  'type',
					  ]
			 });

iDomo.stores.Devices = new Ext.data.Store({
									 model: 'Devices'
									 });