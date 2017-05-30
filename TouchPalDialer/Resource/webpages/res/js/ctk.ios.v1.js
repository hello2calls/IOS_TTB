;
var ctk_exist = true;
var CTK_IOS = {
    handler:null,
    ApiLevel: 'no_value',
    AuthToken: 'no_value',
    Secret: 'no_value',
    City: 'no_value',
    Address: 'no_value',
    Location: 'no_value',
    LocateCacheTime: 'no_value',
    CityCacheTime: 'no_value',
    AddrCacheTime: 'no_value',
    LocationServiceAvailable: 'no_value',
    NetworkAvailable: 'no_value',
    Logged: 'no_value',
    LoginNumber: 'no_value',
    WXAppInstalled: 'no_value',
    WXPaySupported: 'no_value',
    AccessToken: 'no_value',
    ActivationJsonInfo: 'no_value',
    loginCallback: '',
    alipayCallback: '',
    weixinpayCallback: '',

    dispatchEvent: function() {
        var self = this;
        self.handler = window.WebViewJavascriptBridge;
//        self.locate();
        IOS_APILEVEL = self.ApiLevel;
        try {
            if (localStorage.getItem('version_type') != 'old') {
                init();
            }
        } catch(e) {
            console.log('txm: no init');
        }
        self.setItemToStorage('version_type', 'new');
    },

    getValue: function(key, data) {
        var self = this;
        if (self.handler) {
            if (self[key] != 'no_value' && self[key] != null) {
                return self[key];
            }

            self.handler.callHandler('get' + key, data, function(response) {
                console.log('respone: ' + response)
                switch (response) {
                    case 'true':
                        self[key] = true;
                        break;
                    case 'false':
                        self[key] = false;
                        break;
                    default:
                        self[key] = response;
                }
            });

            if (self[key] === null) {
                return null;
            }
        }
    },

    getApiLevel: function(data) { // ok
        return this.getValue('ApiLevel', data);
    },

    isWXAppInstalled: function(data) { // ok
        return this.getValue('WXAppInstalled', data);
    },

    isWXPaySupported: function(data) { // ok
        return this.getValue('WXPaySupported', data);
    },

    getToken: function(data) { // ok
        var _token = this.getValue('AuthToken', data);
        var token = this.getItemFromStorage('auth_token');
        if (token != _token) {
            this.setItemToStorage('auth_token', _token);
        }
        return _token;
    },

    getSecret: function(data) { // ok
        var _secret = this.getValue('Secret', data);
        var secret = this.getItemFromStorage('secret');
        if (secret != _secret) {
            this.setItemToStorage('secret', _secret);
        }
        return _secret;
    },

    getLoginNumber: function(data){ // ok
        var _number = this.getValue('LoginNumber', data);
        var number = this.getItemFromStorage('login_number');
        if (number != _number) {
            this.setItemToStorage('login_number', _number);
        }
        return _number;
    },

    getCity: function(data) { // ok
        return this.getValue('City', data);
    },

    getAddress: function(data) { // ok
        return this.getValue('Address', data);
    },

    getLocation: function(data){ // ok
        return this.getValue('Location', data);
    },

    getCityCacheTime: function(data) { // ok
        return this.getValue('CityCacheTime', data);
    },

    getAddrCacheTime: function(data) { // ok
        return this.getValue('AddrCacheTime', data);
    },

    getLocateCacheTime: function(data){// ok
        return this.getValue('LocateCacheTime', data);
    },

    getPhoneNumber: function() {
        return '';
    },

    getItemFromStorage: function(key) {
        var self = this;

        if (self.handler && self.ApiLevel <= 2) {
            switch (key) {
                case 'native_param_location':
                    return self.getLocation();
                case 'native_param_city':
                    return self.getCity();
                case 'native_param_addr':
                    return self.getAddress();
                case 'native_param_locate_cache_time':
                    return self.getLocateCacheTime();
                case 'native_param_city_cache_time':
                    return self.getCityCacheTime();
                case 'native_param_addr_cache_time':
                    return self.getAddrCacheTime();
                default:
                    return localStorage.getItem(key);
            }
        } else {
            return localStorage.getItem(key);
        }

    },

    setItemToStorage: function(key, value) {
        var self = this;

        if (self.handler && self.ApiLevel > 2) {
            // self.handler.callHandler('setStorageItem', '{\\"' + key + '\\":\\"' + value + '\\"}', function(response) {
            //     console.log(response)
            // });
            var data = {
                key: key,
                value: value
            }
            if (typeof value === 'string' && value.indexOf('\\') != -1) {
                data = '{' + key + ':' + value + '}';
            } else if (typeof value == 'string') {
                data = JSON.stringify(data);
            } else {
                value = JSON.stringify(value)
                data = '{' + key + ':' + value + '}';
            }
            self.handler.callHandler('setStorageItem', data, function(response) {
                console.log(response)
            });
        }
        localStorage.setItem(key, value);
    },

    removeItemFromStorage: function(key) {
        var self = this;

        if (self.handler && self.ApiLevel <= 2) {
            switch (key) {
                case 'native_param_location':
                case 'native_param_city':
                case 'native_param_addr':
                case 'native_param_locate_cache_time':
                case 'native_param_city_cache_time':
                case 'native_param_addr_cache_time':
                    self.handler.callHandler('removeStorageItem', key, function(response) {
                        // console.log(response);
                        switch (key) {
                            case 'native_param_location':
                                self.Location = null;
                                break;
                            case 'native_param_city':
                                self.City = null;
                                break;
                            case 'native_param_addr':
                                self.Address = null;
                                break;
                            case 'native_param_locate_cache_time':
                                self.LocateCacheTime = null;
                                break;
                            case 'native_param_city_cache_time':
                                self.CityCacheTime = null;
                                break;
                            case 'native_param_addr_cache_time':
                                self.AddrCacheTime = null;
                                break;
                        }
                    });
                default:
                    localStorage.removeItem(key);
            }
            return;
        } else if (self.handler && self.ApiLevel > 2) {
            self.handler.callHandler('removeStorageItem', key, function(response) {});
        }
        localStorage.removeItem(key);
    },

    appendScenarioNode: function(state) {
        var self = this;

        if (self.handler) {
            self.handler.callHandler('appendScenarioNode', state, function(response) {
                console.log(response)
            });
        }
    },

    onUMengRecodeUsage: function(path, key, value) {
        var self = this;

        if (self.handler) {
            var data = {
                path: path,
                key: key,
                value: value
            }
            self.handler.callHandler('recordUsage', JSON.stringify(data), function(response) {
                console.log(response)
            });
        }
    },

    isLocationServiceAvailable: function(data) { // ok
        return true;
       // return this.getValue('LocationServiceAvailable', data);
    },

    isNetworkAvailable: function(data) { // ok
        return this.getValue('NetworkAvailable', data);
    },

    isLogged: function(data) { // ok
        var _logged = !!this.getValue('LoginNumber', data);
        var logged = this.getItemFromStorage('secret') ? true : false;;
        if (logged != _logged) {
            this.setItemToStorage('secret', this.getValue('Secret', data));
        }
        return !!this.getValue('LoginNumber', data);
    },

    setToken: function() {
        var self = this;

        if (self.handler) {
            var serviceDomain = Utils.netService;
            var token = self.getToken();
            var currentToken = Utils.getCookie('auth_token');
            if(currentToken && currentToken !== token){
                Utils.removeCookie('auth_token', { domain : serviceDomain });
            }
            Utils.setCookie('auth_token', token, { domain : serviceDomain });
        }
    },

    login: function(title, phone, callback) { // ok
        var self = this;

        if (self.handler) {
            self.loginCallback = callback;
            var data = {
                title: title,
                phone: phone,
                callback: 'CTK.loginHandler'
            };
            self.handler.callHandler('login', JSON.stringify(data), function(response) {
                console.log(response)
            });
        }
    },

    loginHandler: function(ret) {
        var self = this;

        self.AuthToken = ret['token'];
        self.Secret = ret['secret'];
        self.LoginNumber = ret['loginnumber'];

        switch (ret['isLogged']) {
            case 'true':
                self.Logged = true;
                break;
            case 'false':
                self.Logged = false;
                break;
        }
        window[self.loginCallback](self.Logged);
    },

    alipay: function(info, callback) { // ok
        var self = this;

        info2 = info.slice(0,-1);
        if (self.handler) {
            self.alipayCallback = callback;
            var data = {
                callback: 'CTK.alipayHandler',
                info: info
            };

            info2.split('"&').forEach(function(value) {
                var item = value.split('="');
                data[item[0]] = item[1];
            });
            self.handler.callHandler('alipay', JSON.stringify(data), function(response) {
                console.log(response)
            });
        }
    },

    alipayHandler: function(ret) {
        var result = 'resultStatus={' + ret['resultStatus'] + '};memo={' + ret['memo'] + '};result={' + ret['result'] + '}';
        eval(this.alipayCallback + '(\'' + result + '\')');
    },

    weixinpay: function(info, callback) { // ok
        var self = this;

        if (self.handler) {
            var data = JSON.parse(info);
            data.callback = 'CTK.weixinpayHandler';
            self.weixinpayCallback = callback;
            var ret = self.handler.callHandler('weixinpay', JSON.stringify(data), function(response) {
                console.log(response)
            });
        }
    },

    weixinpayHandler: function(ret) {
        eval(this.weixinpayCallback + '(\'' + ret + '\')');
    },

    locate: function(data) {
        var self = this;
        var coordsDefault = {latitude: -1, longitude: -1};

        var setPosition = function (coords){
            var geoPosition = new Array();
            geoPosition.push(coords.latitude);
            geoPosition.push(coords.longitude);
            console.log("got html position: " + JSON.stringify(geoPosition));
            self.setItemToStorage("native_param_location", JSON.stringify(geoPosition));
        };

        var locationSuccess = function(position) {
            var coords = position.coords;

            if (coords){
                setPosition(coords);
            }
        };

        var locationError = function(error){
            setPosition(coordsDefault);

        };

        if (self.handler) {
            self.handler.callHandler('locate', 'CTK.locateCallback', function(response) {
                console.log(response);
            });
        } else {
            setPosition(coordsDefault);
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(locationSuccess, locationError,{
//                    timeout: 10000,
                    enableHighAccuracy: true
                });
            }
        }
    },

    locateGpsFirst: function(gps) {
        var self = this;

        if (self.handler) {
            var data = {
                gps: gps,
                callback: 'CTK.locateCallback'
            }
            self.handler.callHandler('locateGpsFirst', JSON.stringify(data), function(response) {
                console.log(response);

            });
        }
    },

    locateCallback: function() {
        CTK.getItemFromStorage('native_param_location');
        CTK.getItemFromStorage('native_param_city');
        CTK.getItemFromStorage('native_param_addr');
        CTK.getItemFromStorage('native_param_locate_cache_time');
        CTK.getItemFromStorage('native_param_city_cache_time');
        CTK.getItemFromStorage('native_param_addr_cache_time');
        // console.log('2: ' + CTK.getItemFromStorage('native_param_location'));
        // console.log('2: ' + CTK.getItemFromStorage('native_param_city'));
        // console.log('2: ' + CTK.getItemFromStorage('native_param_addr'));
        // console.log('2: ' + CTK.getItemFromStorage('native_param_locate_cache_time'));
        // console.log('2: ' + CTK.getItemFromStorage('native_param_city_cache_time'));
        // console.log('2: ' + CTK.getItemFromStorage('native_param_addr_cache_time'));
    },

    showToast: function(text) {
        alert(text);
        return;
    },

    getDeviceInfo : function() {
        return '{}';
    },

    goBack: function(data) {
        var self = this;

        if (self.handler && self.ApiLevel >= 3) {
            self.handler.callHandler('backPage', data, function(response) {
                console.log(response);
            });
        } else {
            history.back();
        }
    },

    redirectLink: function(link, source, action) {
        window.location.href = link;
    },

    backWithRefresh: function(flag) {
        return;
    },

    getCellInfo : function() {
        return '[]';
    },

    onUMengEvent : function(key) {
        return;
    },

    getTabHeight: function() {
        return 0;
    },

    setChoosedCity: function(city) {
       return;
    },

    getClientVersion: function(data) {
        var self = this
        // {"channel_code":"010100","app_name":"cootek.contactplus.ios.public","app_version":"5222"}
        if (self.ApiLevel >= 8) {
            var _data = self.getValue('ActivationJsonInfo', data);
            _data = JSON.parse(_data);
            return _data['app_version'] * 1;
        } else {
            return 0;
        }
    },

    openMapAddress: function(address, city, shop, isIOS) {
        if (!city) {
            city = '全国';
        }
        if(isIOS){
            var q = city + address;
            window.location.href = 'http://maps.apple.com/maps?q=' + q;
        }else {
            window.location.href = 'bmap.html?city=' + city + '&address=' + address + '&shop=' + shop;
        }
    },

    makePhoneCall: function(phone_info, name, phone){
        if (phone.indexOf(',') != -1) {
            phone = phone.slice(0, phone.indexOf(','));
        }
        window.location.href = 'tel:' + phone;
    },

    shareInfo: function(params) {
        var self = this;

        if (self.ApiLevel >= 4) {
            if (params['type'] == 'wechat') {
                self.handler.callHandler('shareWXMessage', JSON.stringify(params), function(response) {
                    console.log(response);
                });
            } else if (params['type'] == 'qq' || params['type'] == 'qzone') { //IOS_APILEVEL >= 11;
                self.handler.callHandler('shareMessage', JSON.stringify(params), function(response) {
                    console.log(response);
                }); 
            } else if (params['type'] == 'sms') {
                var msg = params['msg'] + ' ' + params['url'];
                self.handler.callHandler('sendMessage', msg, function(response) {
                    console.log(response);
                });
            } else if (params['type'] == 'copy') {
                var msg = params['msg'] + ' ' + params['url'];
                self.handler.callHandler('copyToClipboard', msg, function(response) {
                    console.log(response);
                });
            }
        }
    },

    shareWechatMoment: function(params) {
        var self = this;
        if (self.ApiLevel >= 4) {
            self.handler.callHandler('shareWXMoment', JSON.stringify(params), function(response) {
                console.log(response);
            });
        }
    },

    pushViewController: function(controller) {
        var self = this;
        var data = {
            controller: controller
        }
        if (self.ApiLevel >= 0) {
            self.handler.callHandler('pushViewController', data, function(response) {
                console.log(response);
            });
        }
    },

    openUrl: function(url) {
        var self = this;
        var data = {
            "url": url
        };
        if (self.ApiLevel >= 12) {
            self.handler.callHandler('openUrl', data, null);
        }
    },

    tryShare: function(params) {
        var self = this;
        var data = {
            "params": JSON.stringify(params)
        };
        if (self.ApiLevel >= 7) {
            self.handler.callHandler('tryShareWithParams', data, null);
        }
    },

    getAccessToken: function() {
        var self = this;
	    var base64 = new Base64();
        if ( self.ApiLevel >= 10) {
            t = self.getValue('AccessToken', data);
        }
        if (t && t.length > 5) {
            return t;
        }
		var session = {
			token: self.getToken(),
			etoken: ''
		}
		return base64.encode(JSON.stringify(session));
	},
};
    
