//
//  BluetoothPeripheralLE.m
//  
//
//  Created by Mike Allison on 4/9/14.
//
//

#import "BluetoothPeripheralLE.h"

//Object keys
NSString *const keyStatus = @"status";
NSString *const keyError = @"error";
NSString *const keyAddress = @"address";
NSString *const keyMessage = @"message";

//Status types
NSString *const statusInitialized = @"initialized";
NSString *const statusAdvertising = @"advertising";
NSString *const statusError = @"error";

//Error types
NSString *const errorInitialize = @"initialize";
NSString *const errorCreateService = @"create service";

//Error Messages

//Initialization
NSString *const logPoweredOff = @"Bluetooth powered off";
NSString *const logUnauthorized = @"Bluetooth unauthorized";
NSString *const logUnknown = @"Bluetooth unknown state";
NSString *const logResetting = @"Bluetooth resetting";
NSString *const logUnsupported = @"Bluetooth unsupported";
NSString *const logNotInit = @"Bluetooth not initialized";
//Characteristic
NSString *const logInvalidUuid = @"invalid uuid";
NSString *const logInvalidService = @"Could not link characteristic to service";



@implementation BluetoothPeripheralLE

- (void)pluginInitialize
{
    [super pluginInitialize];
    
    currentService = nil;
    currentCharacteristic = nil;
}

//Actions
- (void)initialize:(CDVInvokedUrlCommand *)command
{
    if (peripheralManager != nil && peripheralManager.state == CBPeripheralManagerStatePoweredOn)
    {
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: statusInitialized, keyStatus, nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
//    
//    activeServices = [NSArray array];
//    activeCharacteristics = [NSArray array];

    initCallback = command.callbackId;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
    if (initCallback == nil)
    {
        return;
    }
    
    //Decide on error message
    NSString* error = nil;
    switch ([peripheralManager state])
    {
        case CBPeripheralManagerStatePoweredOff:
        {
            error = logPoweredOff;
            break;
        }
            
        case CBPeripheralManagerStateUnauthorized:
        {
            error = logUnauthorized;
            break;
        }
            
        case CBPeripheralManagerStateUnknown:
        {
            error = logUnknown;
            break;
        }
            
        case CBPeripheralManagerStateResetting:
        {
            error = logResetting;
            break;
        }
            
        case CBPeripheralManagerStateUnsupported:
        {
            error = logUnsupported;
            break;
        }
            
        case CBPeripheralManagerStatePoweredOn:
        {
            //Bluetooth on!
            break;
        }
    }
    
    NSDictionary* returnObj = nil;
    CDVPluginResult* pluginResult = nil;
    
    if (error != nil)
    {
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorInitialize, keyStatus, error, keyError, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    }
    else
    {
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: statusInitialized, keyStatus, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    }
    
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:initCallback];
    
    initCallback = nil;
    
}

//- (void)createService:(CDVInvokedUrlCommand *)command
//{
// 
//    if ([self isNotInitialized:command])
//    {
//        return;
//    }
//    
//    NSDictionary* obj = [self getArgsObject:command.arguments];
//    
//    if ([self isNotArgsObject:obj :command])
//    {
//        return;
//    }
//    
//    
//    NSString* uuid = [self getUuid:obj];
//    
//    NSDictionary* returnObj = nil;
//    CDVPluginResult* pluginResult = nil;
//    
//    if (uuid == nil || ![self isUUID: uuid] )
//    {
//        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorCreateService, keyError, logInvalidUuid, keyMessage, nil];
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//        return;
//        
//    }
//    
//    
//    CBUUID *serviceUUID = [CBUUID UUIDWithString:uuid];
//    CBMutableService service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
//
//    [services addObject: service ]
//    
//    
//    
//}

- (void)createZombie:(CDVInvokedUrlCommand *)command
{
    
    if ([self isNotInitialized:command])
    {
        return;
    }
    
    NSDictionary* obj = [self getArgsObject:command.arguments];
    
    if ([self isNotArgsObject:obj :command])
    {
        return;
    }
    
    NSString* service_uuid = [self getService:obj];
    NSString* characteristic_uuid = [self getCharacteristic:obj];
    NSData* value = [self getValue:obj];

    NSDictionary* returnObj = nil;
    CDVPluginResult* pluginResult = nil;
    
    if (service_uuid == nil || ![self isUUID: service_uuid] )
    {
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorCreateService, keyError, logInvalidUuid, keyMessage, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
    }
    
    if(characteristic_uuid == nil || ![self isUUID: characteristic_uuid] )
    {
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorCreateService, keyError, logInvalidUuid, keyMessage, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
    }
    (uuid == nil || ![self isUUID: uuid] )
    {
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: errorCreateService, keyError, logInvalidUuid, keyMessage, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
    }

    CBUUID *serviceUUID = [CBUUID UUIDWithString:service_uuid];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristic_uuid];
    
    currentCharacteristic =
    [[CBCharacteristic alloc] initWithType:characteristicUUID
                                properties:CBCharacteristicPropertyRead
                                    value:value
                              permissions:CBAttributePermissionsReadable];
    
    currentService = [[CBService alloc] initWithType:serviceUUID primary:YES];
    
    currentService.characteristics =  @[currentCharacteristic];
    
    operationCallback = command.callbackId;
    
    [peripheralManager addService:currentService];
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    //Successfully connected, call back to end user
    if (operationCallback == nil)
    {
        return;
    }
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: [service.UUID UUIDString], keyAddress, nil];
    
    if(error != nil){
        [returnObj setValue:statusError forKey:keyStatus];
        [returnObj setValue:error.description forKey:keyMessage];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:operationCallback];
        operationCallback = nil;
        return;

    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    //Keep in case device gets disconnected without user initiation
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:connectCallback];
    operationCallback = nil;

}

- (void)advertise:(CDVInvokedUrlCommand *)command
{
    if ([self isNotInitialized:command])
    {
        return;
    }
    operationCallback = command.callbackId;
    [peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey :
                                                 @[currentService.UUID] }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{
    if (operationCallback == nil)
    {
        return;
    }
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: statusAdvertising, keyStatus, nil];
    
    if(error != nil){
        [returnObj setValue:statusError forKey:keyStatus];
        [returnObj setValue:error.description forKey:keyMessage];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:operationCallback];
        operationCallback = nil;
        return;
        
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    //Keep in case device gets disconnected without user initiation
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:connectCallback];
    operationCallback = nil;

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request
{
    if (request.offset > currentCharacteristic.value.length) {
        [peripheralManager respondToRequest:request
                                   withResult:CBATTErrorInvalidOffset];
        return;
    }
    
    request.value = [currentCharacteristic.value
                     subdataWithRange:NSMakeRange(request.offset,
                     currentCharacteristic.value.length - request.offset)];
    
    [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];

}


//utility
- (BOOL)isUUID:(NSString *)inputStr
{
    BOOL isUUID = FALSE;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" options:NSRegularExpressionCaseInsensitive error:nil];
    int matches = [regex numberOfMatchesInString:inputStr options:0 range:NSMakeRange(0, [inputStr length])];
    if(matches == 1)
    {
        isUUID = TRUE;
    }
    return isUUID;
}


@end
