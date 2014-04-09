var bluetoothleName = "BluetoothPeripheralLE";
var bluetoothperipheral = {
  initialize: function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "initialize", []); 
  },
  createZombie: function(params, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "initialize", [params]); 
  },
  advertise: function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "initialize", []); 
  }
}
module.exports = bluetoothperipheral;