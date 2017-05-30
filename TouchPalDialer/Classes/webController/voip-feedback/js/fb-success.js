// for debugging and logging
var AKLog = {
    debug: false,
    enalbeNative: true,
    log: function(input) {
        if (!this.debug) return;
        console.log(input + '');
    },
    alert: function(msg) {
        if (!this.debug) return;
        alert(msg + '');
    },
}

var PATH_FEEDBACK = 'path_feedback';

/**
 * callback start point
 * 
 */
if (AKLog.enalbeNative) {
    $(document).ready(function(){
        initEnvironment(holyCallback); 
    });
} else {
    $(window).load(holyCallback);
}

function holyCallback() {
    var bgColors = {'normal': '#1f92ef', 'highlighted': '#1975bf'};
    bindTouchable('#link-contact-us', bgColors, 'color');
    bindTouchable('#try-voip-callback', bgColors);
    
    $('#link-contact-us').click(function(){
        iOSFunction.dialerRecord(PATH_FEEDBACK, {'tucao_callback_contact_us':1});
        window.location.href = 'http://dialer-cdn.cootekservice.com/iphone/web/faq/faq.html';
    });
    
    $('#try-voip-callback').click(function(){
        iOSFunction.dialerRecord(PATH_FEEDBACK, {'tucao_callback_pop_to_root':1});
        iOSFunction.getKey('feedback_last_voip_call', '', 'string', function(infoString){
            if (!infoString) return;
            
            var info = JSON.parse(infoString);
            if (!info) return;
            
            var rawNumber = info.number;
            if (!rawNumber) return;
            
            iOSFunction.makeCall({
                'number': rawNumber,
                 'callMode': 'CallModeBackCall',
                 'removeSelf': 'true',
            }, null);
        });
                   
    });
}


function bindTouchable(selectorStr, bgColors, targetAttr) {
    if (!selectorStr || !bgColors) return;
    if (!targetAttr) {
        targetAttr = 'background-color';
    }
    $(selectorStr).each(function(i, elem){
        var qItem = $(elem);
        qItem.bind('touchstart', function(){
            var settings = {};
            settings[targetAttr] = bgColors.highlighted;
            qItem.css(settings);
        }).bind('touchend', function(){
            var settings = {};
            settings[targetAttr] = bgColors.normal;
            qItem.css(settings);
        })
    });
}
