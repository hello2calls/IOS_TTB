var bridge = null;

var iOS = {
	initPage: function(backHandler) {
        document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false);

        function onBridgeReady(event) {
            bridge = event.bridge;
            bridge.init(function(message, responseCallback) {
                backHandler(message, responseCallback);
            });
        }
    },
    
    pushWeb: function(title,url,file_name) {
    	if (!bridge) return;
    	var json = {
    		"url":url,
    		"title":title,
    		"file_name":file_name
    	};
    	bridge.callHandler('openWebViewController', json, null);
    },
    
    showDialog: function(message,title,positive_only,positive_text,
    	positive_cb,negative_text,negative_cb) {
    	if (!bridge) return;
    	var json = {
			"message" : message, 
			"title" : title,
			"positive_only" : positive_only, 
			"positive_text" : positive_text, 
			"positive_cb" : positive_cb, 
			"negative_text" : negative_text,
			"negative_cb" : negative_cb
		};
		bridge.registerHandler(positive_cb, function(data, responseCallback) {
			eval(positive_cb);
		});
		bridge.registerHandler(negative_cb, function(data, responseCallback) {
			eval(negative_cb);
		});
    	bridge.callHandler('showDialog', json, null);
    },
    
    registerJavaScriptHandler: function(name, handler) {
        if (!bridge) return;
        bridge.registerHandler(name, function(data, responseCallback) {
            handler(data, responseCallback);
        });
    },
    
    share: function(approaches,type,dlg_title,title,content,url,from,image_url){
    	if (!bridge) return;
    	var json = {
    		"approaches":approaches,
    		"type":type,
    		"dlg_title":dlg_title,
    		"title":title,
    		"content":content,
    		"url":url,
    		"from":from,
    		"image_url":image_url
    	};
    	bridge.callHandler('popShareView', json, null);
    },
    
    doTask: function(task_id){
    	if (!bridge) return;
    	var json = {
    		"task_id":task_id
    	}
    	bridge.callHandler('doTask', json, null);
    },
    
    popToRoot: function(){
        if (!bridge) return;
        bridge.callHandler('popToRoot',null,null);
    },
    
    exchangeFlow: function(number){
        if (!bridge) return;
        var json = {
            "number":number
        };
        bridge.callHandler('TaobaoFlow',json,null);
    },
    
    setKey: function(key,value,type){
        if (!bridge) return;
        var json = {
            "key":key,
            "value":value,
            "type":type
        };
        bridge.callHandler('setKey',json,null);
    },
    
    getKey: function(key,defaultValue,type,callback){
        if (!bridge) return;
        var json = {
            "key":key,
            "defaultValue":defaultValue,
            "type":type
        };
        bridge.callHandler('getKey',json,callback);
    },
    
    pushController: function(controller){
        if (!bridge) return;
        var json = {
            "controller":controller,
        };
        bridge.callHandler('pushViewController',json,null);
    },
    
    register: function(type){
        if (!bridge) return;
        var json = {
            "type":type
        };
        bridge.callHandler('register',json,null);
    },
    
    dialerRecord: function(path,value){
        if (!bridge) return;
        var json = {
            "path":path,
            "value":value
        };
        bridge.callHandler('dialerRecord',json,null);
    },
    
    goContact: function(type,ifSingle,func){
        if (!bridge) return;
        var selectType = 0;
        if ( type == 'mobile' ){
            selectType = 1;
        }else if ( type == 'voip' ){
            selectType = 2;
        }
        
        var json = {
            "type":selectType,
            "isSingle":ifSingle
        };
        bridge.callHandler('selectUserList',json,func);
    }
}
