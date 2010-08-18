function ajax_rcall(url) {
    
    var store = new Ext.data.JsonStore({

        fields: ['title'],

        // load using script tags for cross domain, if the data in on the same domain as
        // this page, an HttpProxy would be better
        proxy: new Ext.data.ScriptTagProxy({
            url: url
        })
    });

    store.load();
}

function ajax_call(url) {
	Ext.Ajax.request({
	   url: url,
	   success: function(response, opts) {
            var obj = Ext.decode(response.responseText);
            console.dir(obj);
        },
        failure: function(response, opts) {
            console.log('server-side failure with status code ' + response.status);
        }
	});
}