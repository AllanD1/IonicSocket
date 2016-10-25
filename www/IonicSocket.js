var exec = require('cordova/exec');

exports.HelloWorld = function(arg0, success, error) {
    exec(success, error, "IonicSocket", "HelloWorld", [arg0]);
};
