var exec = require('cordova/exec');

exports.sendInfo = function (ip, port, info, successCallBack, errorCallBack) {
   exec(successCallBack, errorCallBack, "IonicSocket", "sendInfo", [ip, port, info]);
};
