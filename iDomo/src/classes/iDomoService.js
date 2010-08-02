iDomo.ServiceImpl = Ext.extend(Object, {
    RESTUrl: "",
	systemDB:'',
    rooms: new Array(),
    devices: new Array(),
    controls: new Array(),
    panels: new Array(),
								 
	 /*! Initialize the systemDB global variable. */
	 init: function()
	 {
	    try {
	      if (!window.openDatabase) {
	        alert('not supported');
		  } else {
	        var shortName = 'idomo_db';
	        var version = '1.0';
	        var displayName = 'iDomo Database';
	        var maxSize = 65536; // in bytes
	        var myDB = openDatabase(shortName, version, displayName, maxSize);
	 
	         // You should have a database instance in myDB.
	 
	      }
	    } catch(e) {
	      // Error handling code goes here.
	      if (e == INVALID_STATE_ERR) {
	        // Version number mismatch.
	        alert("Invalid database version.");
	        } else {
	         alert("Unknown error "+e+".");
		  }
	      return;
	   }
	 
	   // alert("Database is: "+myDB);
	 
	   
	   this.systemDB = myDB;
	   //this.createTables();
	 },
							   
	loadConfiguration: function(cb, scope) {
	   // Check and see if you need to initalize the DB
	   this.systemDB.transaction(function(tx) {
			tx.executeSql("SELECT COUNT(*) as count FROM rooms", [], 
				  function(tx, result) { 
      				 if (result.rows.item(0).count == 0)
      				      iDomo.Service.loadFromJSON(cb, scope);
      				 else
      				      iDomo.Service.loadFromDatabase(cb, scope);

				  }, 
				  function(tx, result) { 
				        iDomo.Service.loadFromJSON(cb, scope);
				  }
		      );
        }); 
    },
    
    createTables: function() {

        // Check and see if you need to initalize the DB
        this.systemDB.transaction(function(tx) {
        tx.executeSql("SELECT COUNT(*) as count FROM rooms", [], 
			  function(tx, result) { }, 
			  iDomo.Service.onCreateTables);
        }); 
   },
							
   onCreateTables: function(tx, error) {   
	   iDomo.Service.create_rooms_table();
	   iDomo.Service.create_devices_table();
	   iDomo.Service.create_controls_table();
	   iDomo.Service.create_panels_table();
	   iDomo.Service.create_panelControls_table();
    },
							   
	create_rooms_table: function() {
		this.systemDB.transaction(function(tx) {
			tx.executeSql('CREATE TABLE IF NOT EXISTS rooms ' +
						  '   (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
						  '    name TEXT NOT NULL, ' +
						  '    key TEXT NOT NULL);'
						  , [], 
						  function(tx, result) {}, 
						  this.errorHandler);
		});
   },
   			   
   create_devices_table: function() {
		this.systemDB.transaction(function(tx) {
			tx.executeSql(' CREATE TABLE IF NOT EXISTS devices ' +
						  '   (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
						  '    room_id INTEGER NOT NULL, ' +
						  '    type TEXT NOT NULL, ' +
						  '    name TEXT NOT NULL, ' +
						  '    key TEXT NOT NULL);'
						  , [], 
						  function(tx, result) {}, 
						  this.errorHandler);
		});
    },

    create_controls_table: function() {
		this.systemDB.transaction(function(tx) {
			 tx.executeSql(' CREATE TABLE IF NOT EXISTS controls ' +
						   '   (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
						   '    device_id INTEGER NOT NULL, ' +
						   '    action TEXT NOT NULL, ' +
						   '    name TEXT NOT NULL, ' +
						   '    key TEXT NOT NULL);'
						   , [], 
						   function(tx, result) {}, 
						   this.errorHandler);
	    });
	},
	
	create_panels_table: function() {
		this.systemDB.transaction(function(tx) {
			 tx.executeSql(' CREATE TABLE IF NOT EXISTS panels ' +
						   '   (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
						   '    name TEXT NOT NULL, ' +
						   '    key TEXT NOT NULL);'
						   , [], 
						   function(tx, result) {}, 
						   this.errorHandler);
	    });
	},
	
	create_panelControls_table: function() {
		this.systemDB.transaction(function(tx) {
			 tx.executeSql(' CREATE TABLE IF NOT EXISTS panels_controls ' +
						   '   (panel_id INTEGER NOT NULL, ' +
						   '    control_id INTEGER NOT NULL); '
						   , [], 
						   function(tx, result) {}, 
						   this.errorHandler);
	    });
	},
	
	loadFromJSON: function(cb, scope) {
	   this.onCreateTables();
	   Ext.util.JSONP.request({
			url: localStorage.getItem('jsonuri'),
			callbackKey: 'callback',
			scope: scope,
			params: {auth: localStorage.getItem('auth')},
			callback: function(data) {
			  iDomo.Service.rooms = [];
			  iDomo.Service.devices = [];
			  iDomo.Service.controls = [];
			  iDomo.Service.panels = [];
			  
			  rooms = data.rooms;
			  //Ext.ns("iDomo");
			
			  /* Add Room to the toolbar */
			  for (var i = 0; i < rooms.length; i++) {
			    var room = rooms[i];
			    iDomo.Service.rooms.push(room);
				room["id"] = i + 1;
			    
			    iDomo.Service.create_room(room);
				
				var devices = room["devices"];
			    for (var j = 0; j < devices.length; j++) {
			      var device = devices[j];
				  iDomo.Service.devices.push(device);
			      
			      device.id = iDomo.Service.devices.length;
			      device.room = room;
			      
			      iDomo.Service.create_device(device);
			
				  var controls = device["controls"];
				  for (var k = 0; k < controls.length; k++) {
					var control = controls[k];
					
				    iDomo.Service.controls.push(control);
					
					control["id"] = iDomo.Service.controls.length;
					control["device"] = device;
					
					iDomo.Service.create_control(control);
				  }
			
			    }
		 	  }
		 	  
		 	  panels = data.panels;
		 	  for (var i = 0; i < panels.length; i++) {
		 	    var panel = panels[i];
		 	    iDomo.Service.panels.push(panel);
		 	    panel["id"] = i + 1;
		 	    iDomo.Service.create_panel(panel);
		 	    
		 	    var controls = panel["controls"];
		 	    for (var j = 0; j < controls.length; j++) {
		 	        var pCtr   = controls[j];
		 	        var device = iDomo.Service.getDeviceByKey(pCtr.device);
		 	        if (device) {
     		 	        var control = iDomo.Service.getControlByKey(device, pCtr.control);  
     		 	        
     		 	        if (control) {
     		 	           control["panel_id"] = panel["id"];
      		 	          controls[j] = control;
     		 	        } 
     		 	        else {
     		 	           alert(pCtr.control + " not found");
     		 	        }
     		 	        
     		 	        iDomo.Service.create_panelcontrol(control);  
		 	        }
		 	        else
		 	            controls.splice(j);
		 	    }
		 	  }
			
		  cb.call(scope || window, iDomo.Service);
	  	  }
	   });
     },
     
    getControlByKey: function (device, key) {
        for (var i = 0; i < device["controls"].length; i++) {
            var control = device["controls"][i];
            if (key == control["key"]) {
                return control;
            }
        }     
        return null;
    },

    getDeviceByKey: function (key) {
        for (var i = 0; i < iDomo.Service.devices.length; i++) {
            var device = iDomo.Service.devices[i];
            if (key == device["key"]) {
                return device;
            }
        }
        return null;
    },
	
	loadFromDatabase: function(cb, scope) {
		this.systemDB.transaction(
	      function(tx) {
			tx.executeSql("SELECT id, name, key FROM rooms ORDER BY id ASC", [], 
			  function(tx, result) {
				
						  for (i = 0; i < result.rows.length; i++) {
							var row = result.rows.item(i);
							iDomo.Service.rooms[i] = {id: row.id, name: row.name, key: row.key};
						    iDomo.Service.rooms[i]["devices"] = new Array();
						  }
						  
						  iDomo.Service.loadRoomsDevices(cb, scope);
			  }
		   );
		 }
	  );
	},
	
	loadRoomsDevices: function (cb, scope) {
	   this.systemDB.transaction(function(tx) {
	       tx.executeSql(
			    "SELECT id, room_id, type, name, key FROM devices ORDER BY room_id, id ASC", [], 
				function(tx, result) {
				
        			for (i = 0; i < result.rows.length; i++) {
        			var row = result.rows.item(i);
        			var room = iDomo.Service.rooms[row.room_id - 1];
        			if (room) {
        			     var device = {
        			             id: row.id, 
        			             room: room, 
        			             type: row.type, 
        			             name: row.name, 
        			             key: row.key, 
        			             controls: new Array()
        			     }; 
        			
        			     iDomo.Service.devices.push(device);
        			     room["devices"].push(device);
        			}
				}
				iDomo.Service.loadRoomsControls(cb, scope);
				
				});
        });
   },
   
   loadRoomsControls: function(cb, scope) {
	   this.systemDB.transaction(function(tx) {
	       tx.executeSql(
                "SELECT id, device_id, action, name, key FROM controls ORDER BY device_id, id ASC", [], 
				function(tx, result) {
				
    				  for (i = 0; i < result.rows.length; i++) {
        				    var row = result.rows.item(i);
        				    var device = iDomo.Service.devices[row.device_id - 1];
        				    if (device) {
              				      var control = {
              				            id: row.id, 
              				            device: device, 
              				            action: row.action, 
              				            name: row.name, 
              				            key: row.key};
              				            
              				      iDomo.Service.controls.push(control);
              				      device["controls"].push(control);          
        				    }
    			 	  }
    				  iDomo.Service.loadPanels(cb, scope);
				}
			);
        });
	},
	
	loadPanels: function(cb, scope) {
	   this.systemDB.transaction(function(tx) {
	       tx.executeSql(
                "SELECT id, name, key FROM panels ORDER BY id ASC", [], 
				function(tx, result) {
				
				  for (i = 0; i < result.rows.length; i++) {
				    var row = result.rows.item(i);
					var panel = {
					   id: row.id, 
					   name: row.name, 
					   key: row.key};
					   
					panel["controls"] = new Array();
					
					iDomo.Service.panels.push(panel);
		
			 	  }
				  iDomo.Service.loadControlPanels(cb, scope);
				}
				);
        });
	},
	
	loadControlPanels: function(cb, scope) {
	   this.systemDB.transaction(function(tx) {
	       tx.executeSql(
               "SELECT panel_id, control_id FROM panels_controls ORDER BY panel_id, control_id ASC", [], 
	           function(tx, result) {
			     
			     for (i = 0; i < result.rows.length; i++) {
				    var row = result.rows.item(i);
					
					var panel = iDomo.Service.panels[row["panel_id"] - 1];
					if (panel) {
					   var control =  iDomo.Service.controls[row["control_id"] - 1];
					   if (control) 
					       panel["controls"].push(control);   
					} 
			 	 }
				  cb.call(scope || window, iDomo.Service);	
			  }
	       );
        });
	},
							   
    ResetDB: function () {
		this.systemDB.transaction(
			 function(tx) {
    			 tx.executeSql("DROP TABLE IF EXISTS rooms", [ ], null, this.errorHandler);
    			 tx.executeSql("DROP TABLE IF EXISTS devices", [ ], null, this.errorHandler);
    			 tx.executeSql("DROP TABLE IF EXISTS controls", [ ], null, this.errorHandler);
    			 tx.executeSql("DROP TABLE IF EXISTS panels", [ ], null, this.errorHandler);
    			 tx.executeSql("DROP TABLE IF EXISTS panels_controls", [ ], null, this.errorHandler);
			 }
			 );
	    
		return false;
	},
	
	/*! When passed as the error handler, this causes a transaction to fail with a warning message. */
	errorHandler: function(transaction, error)
	{
		// error.message is a human-readable string.
		// error.code is a numeric error code
		alert('Oops.  Error was '+error.message+' (Code '+error.code+')');
		
		// Handle errors here
		var we_think_this_error_is_fatal = true;
		if (we_think_this_error_is_fatal) return true;
		return false;
	},
	
    create_room: function(room)
	{
		var name = room["name"];
		var key  = room["key"];
		
		this.systemDB.transaction(
		      function(transaction) {
		      transaction.executeSql(
				  'INSERT INTO rooms (name, key) VALUES (?, ?);', 
				  [name, key], 
				  function(tx, results){
				     //alert('insert ID is'+results.insertId);//load_Tabpanel();
				  }, 
				  this.errorHandler
			  );
		   }
	    );
		return false;
	},
	
    create_device: function(device)
	{
		var roomID = device.room.id;
		var type   = device["type"];
		var name   = device["name"];
		var key    = device["key"];
		
		this.systemDB.transaction(
			 function(transaction) {
			     transaction.executeSql(
						'INSERT INTO devices (room_id, type, name, key) VALUES (?, ?, ?, ?);', 
						[roomID, type, name, key], 
						function(tx, results){
						//alert('insert ID is'+results.insertId);//load_Tabpanel();
						}, 
						this.errorHandler
						);
			 }
	    );
		return false;
	},
	
    create_control: function(control)
	{
		var deviceID = control.device.id;
		var action   = control["action"];
		var name     = control["name"];
		var key      = control["key"];
		
		this.systemDB.transaction(
			 function(transaction) {
			 transaction.executeSql(
				'INSERT INTO controls (device_id, action, name, key) VALUES (?, ?, ?, ?);', 
				[deviceID, action, name, key], 
				function(tx, results){
				//alert('insert ID is'+results.insertId);//load_Tabpanel();
				}, 
				this.errorHandler
				);
			 }
	    );
		return false;
	},
	
    create_panel: function(panel)
	{
		var name     = panel["name"];
		var key      = ""; //control["key"];
		
		this.systemDB.transaction(
			 function(transaction) {
			 transaction.executeSql(
				'INSERT INTO panels (name, key) VALUES (?, ?);', 
				[name, key], 
				function(tx, results){
				//alert('insert ID is'+results.insertId);//load_Tabpanel();
				}, 
				this.errorHandler
				);
			 }
	    );
		return false;
	},
	
    create_panelcontrol: function(control)
	{
		var panel_id    = control.panel_id;
		var control_id  = control.id;
		
		this.systemDB.transaction(
			 function(transaction) {
			 transaction.executeSql(
				'INSERT INTO panels_controls (panel_id, control_id) VALUES (?, ?);', 
				[panel_id, control_id], 
				function(tx, results){
				//alert('insert ID is'+results.insertId);//load_Tabpanel();
				}, 
				this.errorHandler
				);
			 }
	    );
		return false;
	},
	
});
iDomo.Service = new iDomo.ServiceImpl();
