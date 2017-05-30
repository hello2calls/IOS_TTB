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
    fixFixed('.other-questions-container');


    (function(){
        //bind for entry containers
        var entryContainers = $('.q-title'); //title container
        entryContainers.each(function(index, elem){
            // init every item to be not checked
            elem.checked = false;
            
            $(elem).click(function(){
                iterateCheck(elem);
            });
            
        }); // end: each
    })();
    
    (function(){
        // bind for submit button
        var submitButton = $('.other-questions');
        var submitButtonElem = submitButton[0];
        var BUTTON_DISABLED = "button-disabled"
            , BUTTON_NORMAL = "button-normal"
            , BUTTON_HIGHLIGHTED = "button-highlighted";
        submitButton.click(function(){
            if (!this.enabled) {
                return;
            } 
            var entryContainers = $('.q-title');
            var checkedContainer = null;
            entryContainers.each(function(index, elem){
                if (elem.checked) {
                    checkedContainer = elem;
                    return false;
                }
            });
            if (checkedContainer) {
                goToPage(checkedContainer);
                var reason = $(checkedContainer).attr('reason');
                if (reason) {
                    AKLog.alert('reason: ' +reason + ', iOSFunction.voipFeedback: ' + iOSFunction.voipFeedback);
                    iOSFunction.voipFeedback(parseInt(reason));
                    AKLog.alert('reason over');
                }
            }
            
        }).bind('touchstart', function(){
            // to highlight
            if (submitButtonElem.enabled) {
                submitButton.removeClass(BUTTON_NORMAL).addClass(BUTTON_HIGHLIGHTED);
            }
            
        }).bind('touchend', function(){
            // back to normal
            if (submitButtonElem.enabled) {
                submitButton.removeClass(BUTTON_HIGHLIGHTED).addClass(BUTTON_NORMAL);
            }
        });
    })();
}

function fixFixed(selector) {
    if (!selector) {
        return;
    }
    
    var fixedContainer = $(selector + '');
    if (!fixedContainer || fixedContainer.length < 1) {
        return;
    }
    
    iOSFunction.getOSVersion(null, function(version){
        if (!version) return;
        
        var versionFloat = parseFloat(version);
        if (versionFloat >= 7.0) {
            return;
        }
        var normalBottomString = fixedContainer.css('bottom');
        var rdigit = /(\d+)/;
        var normalBottom = normalBottomString.match(rdigit)[1];
        fixedContainer.css('bottom', (parseFloat(normalBottom) + 20) + 'px');
    });
}

function goToPage(checkedContainer) {
    var checkedEntry = $(checkedContainer);
    var json = {
        "msg":"反馈成功，会尽快解决您的问题"
    };
    iOSFunction.showToast(json);
    iOSFunction.popToRoot();
}
 
function iterateCheck(targetContainer) {
    if (targetContainer.checked) {
        //only need to uncheck this 
        targetContainer.checked = false;
        setChecked(targetContainer, false);
        enableSubmit(false);
        
    } else {
        //check this
        setChecked(targetContainer, true)
        enableSubmit(true);
        
        // uncheck others
        var entryContainers = $('.q-title');
        entryContainers.each(function(i, container){
            if (container != targetContainer && container.checked) {
                setChecked(container, false);
            }
        });
    }
} // function: iterateCheck

function setChecked(container, checked) {
    var CLZ_ARROW_DOWN = 'arrow-down', CLZ_ARROW_UP= 'arrow-up', CLZ_ARROW = '.arrow';
    if (checked) {
        // set to be checked
        $(container).find(CLZ_ARROW).removeClass(CLZ_ARROW_DOWN).addClass(CLZ_ARROW_UP);
    } else {
        $(container).find(CLZ_ARROW).removeClass(CLZ_ARROW_UP).addClass(CLZ_ARROW_DOWN);
    }
    container.checked = checked;
} // setChecked

function enableSubmit(enabled) {
    var qItem = $('.other-questions'), elem = qItem[0];
    elem.enabled = enabled;
    var BUTTON_DISABLED = "button-disabled"
        , BUTTON_NORMAL = "button-normal"
        , BUTTON_HIGHLIGHTED = "button-highlighted";
    if (enabled) {
        qItem.removeClass(BUTTON_DISABLED).addClass(BUTTON_NORMAL);
    } else {
        qItem.removeClass(BUTTON_NORMAL).addClass(BUTTON_DISABLED);
    }
} // enableSubmit


function fixFixed(selector) {
    if (!selector) {
        return;
    }
    
    var fixedContainer = $(selector + '');
    if (!fixedContainer || fixedContainer.length < 1) {
        return;
    }
    
    iOSFunction.getOSVersion(null, function(version){
        if (!version) return;
        
        var versionFloat = parseFloat(version);
        if (versionFloat >= 7.0) {
            return;
        }
        var normalBottomString = fixedContainer.css('bottom');
        var rdigit = /(\d+)/;
        var normalBottom = normalBottomString.match(rdigit)[1];
        fixedContainer.css('bottom', (parseFloat(normalBottom) + 20) + 'px');
    });
}

