//
//  BluetoothPeripheralLE.h
//
//
//  Created by Mike Allison on 4/9/14.
//
//


#import <Cordova/CDV.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothPeripheralLE : CDVPlugin <CBPeripheralDelegate>
{
    NSString* initCallback;
    NSString* operationCallback;
    
    // NSArray* activeServices;
    //NSArray* activeCharacteristics;
    CBMutableService* currentService;
    CBMutableCharacteristic* currentCharacteristic;
    CBDescriptor* currentDescriptor;
    CBPeripheralManager* peripheralManager;
}

- (void)initialize:(CDVInvokedUrlCommand *)command;

- (void)createZombie:(CDVInvokedUrlCommand *)command;

- (void)advertise:(CDVInvokedUrlCommand *)command;

- (void)isInitialized:(CDVInvokedUrlCommand *)command;


- (BOOL) isNotInitialized:(CDVInvokedUrlCommand *)command;

//- (void)createService:(CDVInvokedUrlCommand *)command;
//- (void)deleteService:(CDVInvokedUrlCommand *)command;
//
//- (void)createCharacteristic:(CDVInvokedUrlCommand *)command;
//- (void)deleteCharacteristic:(CDVInvokedUrlCommand *)command;
//
//- (void)linkCharacteristicToService:(CDVInvokedUrlCommand *)command;
//- (void)unlinkCharacteristicFromService:(CDVInvokedUrlCommand *)command;
//
//- (void)addServiceToAdvertiseQueue:(CDVInvokedUrlCommand *)command;
//- (void)removeServiceToAdvertiseQueue:(CDVInvokedUrlCommand *)command;
//
//- (void)advertise:(CDVInvokedUrlCommand *)command;
//- (void)stopAdvertising:(CDVInvokedUrlCommand *)command;
//
//- (void)updateSubscribers:(CDVInvokedUrlCommand *)command;
//- (void)countSubscribers:(CDVInvokedUrlCommand *)command;
//- (void)hasSubscribers:(CDVInvokedUrlCommand *)command;
//
//- (void)handleRead:(CDVInvokedUrlCommand *)command;
//- (void)handleWrite:(CDVInvokedUrlCommand *)command;

//utility
- (BOOL)isUUID:(NSString *)inputStr;

@end


@interface CBUUID (StringExtraction)

- (NSString *)representativeString;

@end

@implementation CBUUID (StringExtraction)

- (NSString *)representativeString;
{
    NSData *data = [self data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

@end

