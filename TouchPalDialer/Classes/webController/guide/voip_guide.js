var init = function() {
    iOS.initPage(initPageCallBack);
};

var initPageCallBack = function(message, response) {
    Util.init(message, response);
};

$(document).ready(function(){
	init();
	$("#reward").on('click', function () {
// 		iOS.share(['wechat','timeline','qq'],'0','分享nowweb',
// 			'sharetitle','content','http://www.baidu.com','web');
		iOS.doTask(26);
//		iOS.popToRoot();
	});
});