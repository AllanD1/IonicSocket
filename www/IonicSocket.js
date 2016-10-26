var exec = require('cordova/exec');

exports.SendInfo = function (ip, port, sendInfo, success, error) {
    exec(success, error, "IonicSocket", "SendInfo", [ip, port, sendInfo]);
};
