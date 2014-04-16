//
//  BluetoothPeripheralLE.m
//
//
//  Created by Mike Allison on 4/9/14.
//
//

#import "BluetoothPeripheralLE.h"

//Object keys
NSString *const mKeyStatus = @"status";
NSString *const mKeyError = @"error";
NSString *const mKeyAddress = @"address";
NSString *const mKeyMessage = @"message";
NSString *const mKeyValue = @"value";
NSString *const mKeyUUID = @"UUID";
NSString *const mKeyService = @"service";
NSString *const mKeyCharacteristic = @"characteristic";
NSString *const mKeyName = @"name";

//Status types
NSString *const mStatusInitialized = @"initialized";
NSString *const mStatusAdvertising = @"advertising";
NSString *const mStatusSuccess = @"success";
NSString *const mStatusError = @"error";

//Error types
NSString *const mErrorInitialize = @"error initialize";
NSString *const mErrorCreateService = @"create service";
NSString *const mErrorArguments = @"arguments";

//Error Messages

//Initialization
NSString *const mLogPoweredOff = @"Bluetooth powered off";
NSString *const mLogUnauthorized = @"Bluetooth unauthorized";
NSString *const mLogUnknown = @"Bluetooth unknown state";
NSString *const mLogResetting = @"Bluetooth resetting";
NSString *const mLogUnsupported = @"Bluetooth unsupported";
NSString *const mLogNotInit = @"Bluetooth not initialized";
//Characteristic
NSString *const mLogInvalidUuid = @"invalid uuid";
NSString *const mLogInvalidService = @"Could not link characteristic to service";
NSString *const mLogNoArgObj = @"Argument object not found";
NSString *const mLogAlreadyAdvertising = @"Already Advertising";



@implementation BluetoothPeripheralLE

- (void)pluginInitialize
{
    [super pluginInitialize];
    
    currentService = nil;
    currentCharacteristic = nil;
    peripheralManager = nil;
    currentDescriptor = nil;
}

//Actions
- (void)initialize:(CDVInvokedUrlCommand *)command
{
    if (peripheralManager != nil && peripheralManager.state == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"failed to initialize, why?");
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mStatusInitialized, mKeyStatus, nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    initCallback = command.callbackId;
    peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    //
    //    activeServices = [NSArray array];
    //    activeCharacteristics = [NSArray array];
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
    if (initCallback == nil)
    {
        NSLog(@"no initCallback");
        return;
    }
    //Decide on error message
    NSString* error = nil;
    switch ([peripheralManager state])
    {
        case CBPeripheralManagerStatePoweredOff:
        {
            error = mLogPoweredOff;
            break;
        }
            
        case CBPeripheralManagerStateUnauthorized:
        {
            error = mLogUnauthorized;
            break;
        }
            
        case CBPeripheralManagerStateUnknown:
        {
            error = mLogUnknown;
            break;
        }
            
        case CBPeripheralManagerStateResetting:
        {
            error = mLogResetting;
            break;
        }
            
        case CBPeripheralManagerStateUnsupported:
        {
            error = mLogUnsupported;
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
        NSLog(@"an error in intialization");
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mErrorInitialize, mKeyStatus, error, mKeyError, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    }
    else
    {
        NSLog(@"no error in intialization");
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mStatusInitialized, mKeyStatus, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    }
    
    NSLog(@"initializing bluetooth peripheral");
    
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
//        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mErrorCreateService, mKeyError, mLogInvalidUuid, mKeyMessage, nil];
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
    NSLog(@"creating zombie");
    
    //get rid of this check
    if([peripheralManager isAdvertising]){
        
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mStatusAdvertising, mKeyStatus,
                                   mStatusError, mKeyStatus,
                                   mLogAlreadyAdvertising, mKeyMessage,
                                   nil];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    if ([self isNotInitialized:command ])
    {
        NSLog(@"returned not initialized");
        return;
    }
    
    NSDictionary* obj = [self getArgsObject:command.arguments];
    
    if ([self isNotArgsObject:obj :command])
    {
        NSLog(@"returned not an object");
        return;
    }
    
    NSString* service_uuid = [obj objectForKey:mKeyService];
    NSString* characteristic_uuid = [obj objectForKey:mKeyCharacteristic];
    NSData* value = [self getValue:obj];
    
    NSDictionary* returnObj = nil;
    CDVPluginResult* pluginResult = nil;
    
    if (service_uuid == nil ) //|| ![self isUUID: service_uuid]
    {
        NSLog(@"returned service was nil or not a UUID");
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mErrorCreateService, mKeyError, mLogInvalidUuid, mKeyMessage, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
    }
    
    if(characteristic_uuid == nil  ) //|| ![self isUUID: characteristic_uuid]
    {
        NSLog(@"returned characteristic was nil or not a UUID");
        returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mErrorCreateService, mKeyError, mLogInvalidUuid, mKeyMessage, nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
    }
    
    
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:service_uuid];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristic_uuid];
    
    currentCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
                                                               properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify
                                                                    value:value
                                                              permissions:CBAttributePermissionsReadable];
    
    CBUUID *userDescriptionUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];//or set it to the actual UUID->2901
    
    currentDescriptor = [[CBMutableDescriptor alloc]initWithType:userDescriptionUUID value:@"WHAT"];
    
    currentCharacteristic.descriptors = @[currentDescriptor];
    
    currentService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    currentService.characteristics =  @[currentCharacteristic];
    
    operationCallback = command.callbackId;
    
    [peripheralManager addService:currentService];
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    NSLog(@"adding service to peripheral manager");
    //Successfully connected, call back to end user
    if (operationCallback == nil)
    {
        NSLog(@"operation callback is nil");
        return;
    }
    
    
    
    if(error != nil){
        NSLog(@"error in add service");
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: service.UUID.representativeString , mKeyAddress,
                                   mStatusError, mKeyStatus,
                                   error.description, mKeyMessage,
                                   nil];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:operationCallback];
        operationCallback = nil;
        return;
        
    }
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: service.UUID.representativeString , mKeyAddress,
                               mStatusSuccess, mKeyStatus,
                               nil];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    //Keep in case device gets disconnected without user initiation
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:operationCallback];
    operationCallback = nil;
    
}

- (void)advertise:(CDVInvokedUrlCommand *)command
{
    
    if ([self isNotInitialized:command ])
    {
        NSLog(@"returned not initialized");
        return;
    }
    
    NSDictionary* obj = [self getArgsObject:command.arguments];
    
    if ([self isNotArgsObject:obj :command])
    {
        NSLog(@"returned not an object");
        return;
    }
    
    NSString* localName = [obj objectForKey:mKeyName ];
    
    if(localName == nil){
        NSLog(@"name is empty");
        return;
    }
    
    if([peripheralManager isAdvertising]){
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mStatusAdvertising, mKeyStatus,
                                   mStatusError, mKeyStatus,
                                   mLogAlreadyAdvertising, mKeyMessage,
                                   nil];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        operationCallback = nil;
        return;
    }
    
    NSLog(@"attempting to advertise");
    
    operationCallback = command.callbackId;
    [peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : localName }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{
    if (operationCallback == nil)
    {
        return;
    }
    
    NSLog(@"We started advertising!");
    
    
    if(error != nil){
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mStatusAdvertising, mKeyStatus,
                                   mStatusError, mKeyStatus,
                                   error.description, mKeyMessage,
                                   nil];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:operationCallback];
        operationCallback = nil;
        return;
        
    }
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mStatusAdvertising, mKeyStatus, nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
    //Keep in case device gets disconnected without user initiation
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:operationCallback];
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
    
    request.value = [currentCharacteristic.value subdataWithRange:NSMakeRange(request.offset,
                                                                              currentCharacteristic.value.length - request.offset)];
    
    [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    
}

- (void)isInitialized:(CDVInvokedUrlCommand *)command
{
    BOOL result = (peripheralManager != nil && peripheralManager.state == CBPeripheralManagerStatePoweredOn);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (BOOL) isNotInitialized:(CDVInvokedUrlCommand *)command
{
    if (peripheralManager == nil || peripheralManager.state != CBPeripheralManagerStatePoweredOn)
    {
        NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mErrorInitialize, mKeyStatus, mLogNotInit, mKeyError, nil];
        CDVPluginResult *pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnObj];
        [pluginResult setKeepCallbackAsBool:false];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return true;
    }
    
    return false;
}


//utility

-(NSDictionary*) getArgsObject:(NSArray *)args
{
    //TODO Not sure how cast typing works in objective c
    NSLog(@"getting args as object");
    if (args.count == 1)
    {
        return (NSDictionary *)[args objectAtIndex:0];
    }
    return nil;
}

-(NSData*) getValue:(NSDictionary *) obj
{
    NSLog(@"getting value and turing it into data");
    
    NSString* string = [obj objectForKey:mKeyValue];
    
    NSLog(string);
    
    if (string == nil)
    {
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    
    if (data == nil || data.length == 0)
    {
        return nil;
    }
    
    return data;
}

-(CBUUID*) getUuid:(NSDictionary *)obj
{
    NSLog(@"getting a UUID");
    
    NSString* checkUuid = [obj valueForKey:(mKeyUUID)];
    
    CBUUID* uuid;
    
    if (uuid == nil || ![self isUUID:checkUuid])
    {
        return nil;
    }
    uuid = [CBUUID UUIDWithString:checkUuid];
    
    return uuid;
}

- (BOOL) isNotArgsObject:(NSDictionary*) obj :(CDVInvokedUrlCommand *)command
{
    NSLog(@"checking if this is an args object");
    
    if (obj != nil)
    {
        NSLog(@"object is nil");
        return false;
    }
    
    NSDictionary* returnObj = [NSDictionary dictionaryWithObjectsAndKeys: mErrorArguments, mKeyError, mLogNoArgObj, mKeyMessage, nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnObj];
    [pluginResult setKeepCallbackAsBool:false];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    return true;
}


- (BOOL)isUUID:(NSString *)inputStr
{
    NSLog(@"checking if this is a UUID or not");
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
