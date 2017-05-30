/**
 * Created by 耸善 on 2015/11/5.
 * Modify by 耸善 on 2015/12/4.
 * version 1.3
 */
var BaseParams = {
    phoneNum:'',
    token:'',
    platform:'',
    channel:'',
    apiLevel:0,
    version:'',
    registerTime:'',
    intlRoaming: '',
};

/**
 * @description 全局变量：android平台
 */
var PLATFORM_ANDROID = 1;

/**
 * @description 全局变量：ios平台
 */
var PLATFORM_IOS = 0;

String.prototype.toJsonObject = function() {
    return eval("(" + this + ")");
};

/**
 * @description 用户当前平台
 * @param {Emu} weixin 微信平台
 * @param {Emu} ios iOS平台
 * @param {Emu} android 安卓平台
 * @param {Emu} mobile 移动终端
 * @param {Emu} iPhone iPhone或者QQHD浏览器
 */
window.ua = detectUA();
function detectUA() {
    var u = navigator.userAgent;
    return {
        weixin: u.match(/MicroMessenger/i) || window.WeixinJSBridge != undefined,
        ios: !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/), //ios终端
        android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1,
        mobile: !!u.match(/AppleWebKit.*Mobile.*/), //是否为移动终端
        iPhone: u.indexOf('iPhone') > -1  //是否为iPhone或者QQHD浏览器
    };
}

/**
 * @description 百度统计工具
 * 使用示例: _hmt.push(['_trackEvent', path, path+data]);
 */
var _hmt = _hmt || [];
(function() {
    var hm = document.createElement("script");
    hm.src = "//hm.baidu.com/hm.js?8203b93a73fd9e8ffc85bdaa08f566ba";
    var s = document.getElementsByTagName("script")[0];
    s.parentNode.insertBefore(hm, s);
})();

/**
 * @description 打开一个新的链接
 * @param      {String}   title 标题(仅通过本地应用打开时才生效)
 * @param      {String}   url 链接地址
 */
function openLink(title,url) {
    console.log('url:' + url);
    if (ua.android) {
        if (BaseParams.version >= 5740 || window.CTKJavaScriptHandler) {
            window.location.href = url;
        } else {
            AndroidFunction.pushWeb(title, url);
        }
    } else if (ua.ios) {
        iOSFunction.pushWeb(title, url);
    } else {
        window.location.href = url;
    }

}

//get name of current folder for data recording
function getCurFolderName(strPath) {
    var strFolder = strPath.substring(0, strPath.lastIndexOf("/"));
    return (strFolder);
}


var isIniting = false;

/**
 * @description 初始化时必须要调用的函数；
 * @param      {Function}   initFinishCallback(callback) 初始化完成后回调函数，回传一个参数
 */
function initEnvironment (initFinishCallback, initFailedCallback) {
        if (ua.android) {
            var jsHandler = window.DialerJavaScriptHandler || window.CTKJavaScriptHandler;
            var json = jsHandler.init();
            BaseParams.token = json.toJsonObject().token;
            BaseParams.phoneNum = json.toJsonObject().number;
            BaseParams.platform = PLATFORM_ANDROID;
            BaseParams.version = json.toJsonObject().version;
            BaseParams.channel = json.toJsonObject().channel;
            BaseParams.registerTime = json.toJsonObject().registerTime;
            BaseParams.intlRoaming = json.toJsonObject().isInternationalRoaming;
            AndroidFunction.register(jsHandler);
            BaseParams.apiLevel = AndroidFunction.getApiLevel();
            //if (window.CTKJavaScriptHandler && BaseParams.apiLevel > 0) {
            //    if (BaseParams.apiLevel < 31) {
            //        window.location.href = "http://search.cootekservice.com/page_v3/upgrade.html";
            //    }
            //}

            if (BaseParams.phoneNum) {
                setCookie('initEnv', 'succeed', '30');
                initFinishCallback(BaseParams);
            } else if (initFailedCallback){
                setCookie('initEnv', 'failed', '30');
                initFailedCallback();
            }
        } else if (ua.ios) {
            var init = function () {
                iOSFunction.initPage(initPageCallBack, initOldVersion);
            };
            //support old version iOS Dialer
            var initOldVersion = function (version) {
                if (isIniting) return;
                isIniting = true;
                BaseParams.version = version;
                BaseParams.platform = PLATFORM_IOS;
                BaseParams.channel = '010100';
                iOSFunction.getPhoneNum(function (phone) {
                    BaseParams.phoneNum = phone;
                    iOSFunction.getToken(function (token){
                        BaseParams.token = token;
                        iOSFunction.getApiLevel(function (api_level) {
                            BaseParams.apiLevel = api_level;
                            BaseParams.intlRoaming = '0';
                            if (BaseParams.phoneNum) {
                                setCookie('initEnv', 'succeed', '30');
                                initFinishCallback(BaseParams);
                            } else if (initFailedCallback){
                                setCookie('initEnv', 'failed', '30');
                                initFailedCallback();
                            }
                        });
                    });
                });
            };

            var initPageCallBack = function (message, response) {
                console.log('initPageCallback');
                if (message.version < 5331) {
                    initOldVersion(message.version);
                } else {
                    BaseParams.token = message.token;
                    BaseParams.phoneNum = message.number;
                    BaseParams.platform = PLATFORM_IOS;
                    BaseParams.version = message.version;
                    BaseParams.channel = message.channel;
                    BaseParams.registerTime = message.registerTime;
                    BaseParams.intlRoaming = message.isInternationalRoaming;
                    BaseParams.apiLevel = message.apiLevel;
                    console.log('baseParams: ' + BaseParams + ', phoneNumber: ' + BaseParams.phoneNum);
                    // if (BaseParams.phoneNum) {
                    //     setCookie('initEnv', 'succeed', '30');
                    //     initFinishCallback(BaseParams);
                    // } else if (initFailedCallback){
                    //     console.log('fail callback');
                    //     setCookie('initEnv', 'failed', '30');
                    //     initFailedCallback();
                    // }
                    setCookie('initEnv', 'succeed', '30');
                    initFinishCallback(BaseParams);
                }
            };

            init();
        }
}
/**
 * @description android接口，只有通过此接口才能调用android原生代码
 */
var AndroidFunction = {
    js_handler :'',
    register: function(handler) {
        this.js_handler = handler;
    },

    /**
     * @description AndroidFunction方法：弹出会话框分享
     * @param      {Array}   approaches 分享途径
     * @param      {String}   type
     * @param      {String}   dlg_title 分享途径提示标题
     * @param      {String}   title 分享消息标题
     * @param      {String}   content 分享消息内容
     * @param      {String}   url 分享消息指向路径
     * @param      {String}   img_url 分享消息配图路径
     * @param      {String}   from 分享消息来源
     */
    share: function(approaches, type, dlg_title, title, content, url, img_url, from) {
        if (BaseParams.version && BaseParams.version <= 5741) {
            img_url = '';
        }
        var json = {
            "approaches" : approaches,
            "type" : type,
            "dlg_title" : dlg_title,
            "title" : title,
            "content" : content,
            "url" : url,
            "img_url" : img_url,
            "from" : from
        };
        this.js_handler.share(JSON.stringify(json));
    },

    /**
     * @description AndroidFunction方法：显示会话框
     * @param      {String}   message 会话框内容
     * @param      {String}   title 会话框标题
     * @param      {String}   positive_only 只显示确定按钮
     * @param      {String}   positive_text 确定按钮上显示文字
     * @param      {String}   positive_cb 确定按钮的回调函数
     * @param      {String}   negative_text 取消按钮上显示文字
     * @param      {String}   negative_cb 取消按钮的回调函数
     */
    showDialog: function(message, title, positive_only, positive_text, positive_cb, negative_text, negative_cb) {
        var json = {
            "message" : message,
            "title" : title,
            "positive_only" : positive_only,
            "positive_text" : positive_text,
            "positive_cb" : positive_cb,
            "negative_text" : negative_text,
            "negative_cb" : negative_cb};
        window.generalBridge.showDialog(JSON.stringify(json));
    },

    /**
     * @description AndroidFunction方法：显示浏览器页面
     * @param      {String}   title 网页标题
     * @param      {String}   url 网页路径
     */
    pushWeb: function(title, url) {
        var json = {
            "title" : title,
            "url" : url
        };
        window.generalBridge.pushWeb(JSON.stringify(json));
    },

    redirect: function(json) {
        window.generalBridge.pushWeb(JSON.stringify(json));
    },

    /**
     * @description AndroidFunction方法：通过类名启动本地应用程序
     * @param      {String}   pkgname 安装包名
     * @param      {String}   clsname 类名
     * @param      {String}   intentData
     * @param      {String}   jsonExtraData
     * @param      {String}   startService
     */
    startActivity: function(pkgname, clsname, intentData, jsonExtraData, startService) {
        this.js_handler.launchLocalAppByClassName(pkgname, clsname, intentData, jsonExtraData, startService);
    },

    exchangeFlow: function(number) {
        this.js_handler.exchangeTraffic(number, 0);
    },

    /**
     * @description AndroidFunction方法：返回拨号页面
     */
    popToRoot: function() {
        this.js_handler.popToRoot();
    },

    doTask: function(task_id) {
        var json = {
            "task_id" : task_id
        };
        this.js_handler.doTask(JSON.stringify(json));
    },

    canTakeOver: function() {
        return this.js_handler.canTakeOver();
    },

    isNewInstall: function() {
        return this.js_handler.isNewInstall();
    },

    /**
     * @description AndroidFunction方法 尝试接管系统拨号：
     * @param      {Boolean}   canTakeOver
     * @param      {String}   finishPageWhenDismiss
     * @param      {String}   onlyDismissDlg
     * @param      {String}   refreshWhenDismiss
     */
    takeOverSys: function(canTakeOver, finishPageWhenDismiss, onlyDismissDlg, refreshWhenDismiss) {
        this.js_handler.takeOverSys(canTakeOver, finishPageWhenDismiss, onlyDismissDlg, refreshWhenDismiss);
    },

    // type: "integer" "long" "boolean" "string"
    setKey: function(key, value, type) {
        this.js_handler.setKey(key, value, type);
    },

    // type: "integer" "long" "boolean" "string"
    getKey: function(key, defaultValue, type) {
        return this.js_handler.getKey(key, defaultValue, type);
    },

    //type: string, object(dict like)
    //Attention: do not use boolean type in the object as ios will convert the 
    //boolean into 0 or 1. so use int 0 or 1 instead of boolean value.
    dialerRecord: function(path, values) {
        if (!path || !values) return;
        if (typeof path !== 'string') return;
        if (typeof values !== 'object') return;
        path += "_" + getUA();
        //Android Java code can only recognize string as parameters through js interface, 
        //so it is a must to stringify the values object.
        if (this.js_handler.dialerRecord) {
            this.js_handler.dialerRecord(path, JSON.stringify(values));
        }
    },

    /**
     * @description AndroidFunction方法：下载应用程序
     * @param      {String}   app_id 应用程序的id值
     * @param      {String}   params 下载所需的应用程序参数
     */
    downloadApp: function (app_id, params) {
        this.js_handler.downloadApp(app_id, params);
    },

    /**
     * @description AndroidFunction方法：获取本地js_handler的版本号
     */
    getApiLevel: function() {
        return this.js_handler.getApiLevel();
    },

    /**
     * @description AndroidFunction方法：分享
     * @param      {String}   approach
     * @param      {Json}   jsonparam
     */
    doShare: function(approach,jsonparam) {
        this.js_handler.share(approach,jsonparam);
    },

    /**
     * @description AndroidFunction方法：应用是否安装;APLI-LEVEL 35及以上支持
     * @param      {String}   packageName 应用的包名
     */
    isPackageInstalled: function(packageName) {
        if (BaseParams.apiLevel < 35) {
            return false;
        } else {
            return this.js_handler.isPackageInstalled(packageName);
        }
    },

    /**
     * @description AndroidFunction方法：运行应用程序
     * @param      {String}   clsName
     * @param      {String}   intentAction
     */
    launchApp : function(clsName, intentAction) {
        this.js_handler.launchApp(clsName, intentAction);
    },

    /**
     * @description AndroidFunction方法：是否支持调用本地接口DownloadApp
     * @return      {Boolean}
     */
    supportDownloadApp: function() {
        if ((window.DialerJavaScriptHandler && BaseParams.apiLevel <8)
            || (window.CTKJavaScriptHandler && BaseParams.apiLevel < 33)) {
            return false;
        } else {
            return true;
        }
    },

};

var ios_bridge =  null;
/**
 * @description ios接口，只有通过此接口才能调用ios原生代码
 */
var iOSFunction = {
    initPage: function(backHandler, initOldVersion) {
        document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false);

        function onBridgeReady(event) {
            ios_bridge = event.bridge;
            ios_bridge.init(function(message, responseCallback) {
                console.log('message' + message + ', backhandler: '  + backHandler.toString());
                backHandler(message, responseCallback);
            });

            // support old version
            var version;
            var json = null;
            ios_bridge.callHandler('getActivationJsonInfo', json, function (value) {
                var json_string = eval('(' + value + ')');
                version = json_string.app_version;
                if (version < 5331) {
                    initOldVersion(version);
                }
            });

        }
    },

    /**
     * @description iOSFunction方法：显示浏览器页面
     * @param      {String}   title 网页标题
     * @param      {String}   url 网页路径
     * @param      {String}   file_name 文件名
     */
    pushWeb: function(title,url,file_name) {
        if (!ios_bridge) return;
        var json = {
            "url":url,
            "title":title,
            "file_name":file_name
        };
        ios_bridge.callHandler('openWebViewController', json, null);
    },

    /**
     * @description iOSFunction方法：显示会话框
     * @param      {String}   message 会话框内容
     * @param      {String}   title 会话框标题
     * @param      {String}   positive_only 只显示确定按钮
     * @param      {String}   positive_text 确定按钮上显示文字
     * @param      {String}   positive_cb 确定按钮的回调函数
     * @param      {String}   negative_text 取消按钮上显示文字
     * @param      {String}   negative_cb 取消按钮的回调函数
     */
    showDialog: function(message,title,positive_only,positive_text,
                         positive_cb,negative_text,negative_cb) {
        if (!ios_bridge) return;
        var json = {
            "message" : message,
            "title" : title,
            "positive_only" : positive_only,
            "positive_text" : positive_text,
            "positive_cb" : positive_cb,
            "negative_text" : negative_text,
            "negative_cb" : negative_cb
        };
        ios_bridge.registerHandler(positive_cb, function(data, responseCallback) {
            eval(positive_cb);
        });
        ios_bridge.registerHandler(negative_cb, function(data, responseCallback) {
            eval(negative_cb);
        });
        ios_bridge.callHandler('showDialog', json, null);
    },

    registerJavaScriptHandler: function(name, handler) {
        if (!ios_bridge) return;
        ios_bridge.registerHandler(name, function(data, responseCallback) {
            handler(data, responseCallback);
        });
    },

    /**
     * @description iOSFunction方法：弹出会话框分享
     * @param      {Array}   approaches 分享途径
     * @param      {String}   type
     * @param      {String}   dlg_title 分享途径提示标题
     * @param      {String}   title 分享消息标题
     * @param      {String}   content 分享消息内容
     * @param      {String}   url 分享消息指向路径
     * @param      {String}   from 分享消息来源
     * @param      {String}   image_url 分享消息配图路径
     */
    share: function(approaches,type,dlg_title,title,content,url,from,image_url){
        if (!ios_bridge) return;
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
        ios_bridge.callHandler('popShareView', json, null);
    },

    doTask: function(task_id){
        if (!ios_bridge) return;
        var json = {
            "task_id":task_id
        };
        ios_bridge.callHandler('doTask', json, null);
    },

    /**
     * @description iOSFunction方法：返回拨号页面
     */
    popToRoot: function(){
        if (!ios_bridge) return;
        ios_bridge.callHandler('popToRoot',null,null);
    },
    /*
     * @description iOSFunction方法：弹出会话框分享
     * @param      {String}   position tosat的位置(默认底部) "top" "center" "UpKeyboard" "bottom"
     * @param      {String}   duration 停留时间 （默认1秒）
     * @param      {String}   msg      显示的内容（必要的）

    */
    showToast: function(json){
        if (!ios_bridge) return;
        ios_bridge.callHandler('showToast',json,null);
    },

    exchangeFlow: function(number){
        if (!ios_bridge) return;
        var json = {
            "number":number
        };
        ios_bridge.callHandler('TaobaoFlow',json,null);
    },
    // type: "integer" "boolean" "string"
    setKey: function(key,value,type){
        if (!ios_bridge) return;
        var json = {
            "key":key,
            "value":value,
            "type":type
        };
        ios_bridge.callHandler('setKey',json,null);
    },
    // type: "integer" "boolean" "string"
    getKey: function(key,defaultValue,type,callback){
        if (!ios_bridge) return;
        var json = {
            "key":key,
            "defaultValue":defaultValue,
            "type":type
        };
        ios_bridge.callHandler('getKey',json, callback);
    },

    /**
     * @description iOSFunction方法， 启动iOS本地的一个ViewController：
     * @param      {String}   controller
     */
    pushController: function(controller){
        if (!ios_bridge) return;
        var json = {
            "controller":controller,
        };
        ios_bridge.callHandler('pushViewController',json,null);
    },

    register: function(type){
        if (!ios_bridge) return;
        var json = {
            "type":type
        };
        ios_bridge.callHandler('register',json,null);
    },

    /**
     * @description iOSFunction方法：获取城市
     * @param      {Function}   callback
     */
    getCity: function(callback) {
        if (!ios_bridge) return;
        var json = null;
        ios_bridge.callHandler('getCity', json, callback);
    },

    /**
     * @description iOSFunction方法：下载其他的应用程序
     * @param      {Integer}   appid 应用程序id
     * @param      {String}   value 下载应用程序所需的参数
     */
    dialerRecord: function(path,value){
        if (!ios_bridge || !path || !value) return;
        if (typeof path !== 'string') return;
        if (typeof value !== 'object') return;
        path += "_" + getUA();
        var json = {
            "path":path,
            "value":value
        };
        ios_bridge.callHandler('dialerRecord',json,null);
    },

    /**
     * @description iOSFunction方法：下载接口
     * @param      {String}   appid
     * @param      {Json}   value
     */
    downloadOtherApp: function(appid,value){
        if (!ios_bridge) return;
        var json = {
            "appid":appid,
            "param":value
        };
        ios_bridge.callHandler('downloadOtherApp',json,null);
    },

    /**
     * @description iOSFunction方法：分享
     * @param      {String}   approach
     * @param      {Json}   jsonparam
     */
    doShare: function(approach,params){
        if (!ios_bridge) return;
        var json = {
            "approach": approach,
            "json": params,
        };

        ios_bridge.callHandler('webShare', json, function(result) {
            var result_params = eval(result);
            if (result_params.result == 0) {
                shareSucceed(result_params.approach);
            } else if (result_params.result == 1) {
                shareFailed(result_params.approach);
            } else if (result_params.result == 2) {
                shareCanceled(result_params.approach);
            }

        });
    },


    getToken: function(callback) {
        if (!ios_bridge) return;
        var json = null;
        ios_bridge.callHandler('getAuthToken', json, callback);
    },

    getPhoneNum: function(callback) {
        if (!ios_bridge) return;
        var json = null;
        ios_bridge.callHandler('getLoginNumber', json, callback);
    },

    getVersion: function(callback) {
        if (!ios_bridge) return;
        var json = null;
        ios_bridge.callHandler('getActivationJsonInfo', json, callback);
    },

    /**
     * @description iOSFunction方法：获取本地js_handler接口的版本
     * @param      {callback}   callback 回调方法
     */
    getApiLevel: function(callback) {
        if (!ios_bridge) return;
        var json = null;
        ios_bridge.callHandler('getApiLevel', json, callback);
    },

    /**
     * @description iOSFunction方法：当无法获得号码时自动跳转至注册页面
     */
    login: function () {
        if (!ios_bridge) return;
        var data = {
            title: '',
            phone: '',
            callback: 'loginCallback'
        };
        ios_bridge.callHandler('login', JSON.stringify(data), function (response) {

        });
    },
    
    voipFeedback: function(reason, callback) {
        if (!ios_bridge) return;
        ios_bridge.callHandler('voipFeedback', reason, callback);
    },
    
    makeCall: function(info, callback) {
        if (!ios_bridge) return;
        ios_bridge.callHandler('makeCall', info, callback);
    },

    
    getOSVersion: function(info, callback) {
        if (!ios_bridge) return;
        ios_bridge.callHandler('getOSVersion', info, callback);
    }

};


function loginCallback(json) {
    window.location.reload();
}

//common hadler function
/**
 * @description 通用方法：返回拨号页面
 */
function popToRoot() {
    if (ua.android) {
        AndroidFunction.popToRoot();
    } else if (ua.ios) {
        iOSFunction.popToRoot();
    }
}

function doTask(task_id) {
    if (ua.android) {
        AndroidFunction.doTask(task_id);
    } else if (ua.ios) {
        iOSFunction.doTask(task_id);
    }
}

/**
 * @description 通用方法：设置本地一个key
 * @param      {String}   key key的名称
 * @param      {String}   value 设置的值
 * @param      {String}   type 值的类型"integer" "boolean" "string"
 */
function setKey(key, value, type) {
    if (ua.android) {
        AndroidFunction.setKey(key, value, type);
    } else if (ua.ios) {
        iOSFunction.setKey(key, value, type);
    }
}

//data is a object composed by two members: 'path' and 'values' if specifed clearly.
//or just the path then the values are default to pv and token.
function record(data) {
    if (typeof data === 'string') {
        //default is to record page visit(pv)
        data = {
            'path': data,
            'values': {
                'pv': 1
            }
        };
    }
    var platform = null;
    switch (this.getUA()) {
        case 'iphone':
        case 'ios':
            // mac devices can be detected in a narrow scope.
            // make sure that the iOS.init() is alreay called.
            if (this.token) {
                platform = iOSFunction;
                data.values.token = BaseParams.token;
            }
            break;
        case 'android':
            // the others are considered as android devices
            platform = AndroidFunction;
            data.values.token = BaseParams.token;
            break;
        default:
            break;
    }
    if (platform && data && platform.dialerRecord) {
        platform.dialerRecord(data.path, data.values);
    }
}

//get userAgent
function getUA() {
    var u = navigator.userAgent;
    var result =  {
        weixin: u.match(/MicroMessenger/i) || window.WeixinJSBridge != undefined,
        ios: !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/), //ios终端
        android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1,
        mobile: !!u.match(/AppleWebKit.*Mobile.*/), //是否为移动终端
        iphone: u.indexOf('iPhone') > -1  //是否为iPhone或者QQHD浏览器
    };
    if (result.weixin) return 'weixin';
    if (result.iphone) return 'iphone';
    if (result.ios) return 'ios';
    if (result.android) return 'android';
    if (result.mobile) return 'mobile';
    return "";
}


/**
 * @description 通用方法，设置cookie
 * @param      {String}   NameOfCookie cookie名
 * @param      {String}   value cookie值
 * @param      {String}   expiredays cookie有效时长
 */
function setCookie(NameOfCookie, value, expiredays) {
    var ExpireDate = new Date();
    ExpireDate.setTime(ExpireDate.getTime() + (expiredays * 24 * 3600 * 1000));
    document.cookie = NameOfCookie + "=" + decodeURIComponent(value) +
        ((expiredays == null) ? "" : "; expires=" + ExpireDate.toGMTString());
}

/**
 * @description 通用方法，获取cookie
 * @return      {String}   NameOfCookie cookie名
 */
function getCookie(NameOfCookie) {
    if (document.cookie.length > 0) {
        begin = document.cookie.indexOf(NameOfCookie + "=");
        if (begin != -1) {
            begin += NameOfCookie.length + 1;
            end = document.cookie.indexOf(";", begin);
            if (end == -1) end = document.cookie.length;
            return encodeURIComponent(document.cookie.substring(begin, end));
        }
    }
    return null;
}

/**
 * @description 通用方法，删除cookie
 * @param      {String}   NameOfCookie cookie名
 */
function delCookie(NameOfCookie) {
    if (getCookie(NameOfCookie)) {
        document.cookie = NameOfCookie + "=" +
            "; expires=Thu, 01-Jan-70 00:00:01 GMT";
    }
}


var mURLParams = new Array();
/**
 * @description 获取URL中的参数的值
 * @param      {String}   paramKey 参数名称
 */
function getUrlParam(paramKey) {
    if (mURLParams.length < 1) {
        var url=window.location.search;
        if(url.indexOf("?")!=-1) {
            var str = url.substr(1)
            strs = str.split("&");
            var key=new Array(strs.length);
            var value=new Array(strs.length);
            for(i=0;i<strs.length;i++)
            {
                key[i]=strs[i].split("=")[0]
                value[i]=decodeURI(strs[i].split("=")[1]);
                mURLParams[key[i]] = value[i];
            }
        }
    }

    if (mURLParams[paramKey]) {
        return mURLParams[paramKey];
    }
    return null;
}




function isPackageInstalled(packageName) {
    if (ua.android) {
        return AndroidFunction.isPackageInstalled(packageName);
    } else if (ua.ios) {
        return false;
    }
}




function afterDate(startTime) {
    var curDate = new Date();
    var start = new Date(Date.parse(startTime));
    if (curDate >= start) {
        return true;
    } else {
        return false;
    }
}

function beforeDate(endTime) {
    var curDate = new Date();
    var start = new Date(Date.parse(endTime));
    if (curDate < start) {
        return true;
    } else {
        return false;
    }
}


function showRegisterPage(tips_container) {
    var delay = 1000;
    if (tips_container) {
        delay = 2600;
        tips_container.append(
            '<div style="position: absolute; text-align: center; top: 45%; font-size: 16px; width: 100%;">' +
                '<p>使用该功能必须登录/注册，</p>' +
                '<p>现帮您跳转至登录界面...</p>' +
            '</div>');
    }
    setTimeout(function () {
        if (ua.android) {
            var paramArray = new Array('{"extraName": "login_from", "extraValue" : "web_task", "extraType": "String"}');
            AndroidFunction.startActivity("com.cootek.smartdialer", "com.cootek.smartdialer.assist.LoginDialogActivity",
                null, null, -1, null,
                paramArray);
        } else if (ua.ios) {
            iOSFunction.login();
        }
    }, delay);

}