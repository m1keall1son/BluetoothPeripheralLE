var bluetoothleName = "BluetoothPeripheralLE";
var bluetoothperipheral = {
  initialize: function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "initialize", []); 
  },
  createZombie: function(params, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "createZombie", [params]); 
  },
  advertise: function(params, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "advertise", [params]); 
  },
  stopAdvertising: function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, bluetoothleName, "stopAdvertise", []); 
  }
}
module.exports = bluetoothperipheral;