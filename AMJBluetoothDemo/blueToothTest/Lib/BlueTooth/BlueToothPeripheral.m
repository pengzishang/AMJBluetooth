//
//  BlueToothPeripheral.m
//  blueToothTest
//
//  Created by pzs on 2017/8/29.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "BlueToothPeripheral.h"

static NSString *const ServiceUUID1 =  @"AFF0";
static NSString *const notiyCharacteristicUUID =  @"AFF1";
static NSString *const readwriteCharacteristicUUID =  @"AFF2";
static NSString *const ServiceUUID2 =  @"AFE0";
static NSString *const readCharacteristicUUID =  @"AFE1";
static NSString * const LocalNameKey =  @"PZSDE";

@interface BlueToothPeripheral()<CBPeripheralManagerDelegate>

@property (nonatomic,strong)CBPeripheralManager *peripheralManager;

@end


@implementation BlueToothPeripheral

//-(CBPeripheralManager *)peripheralManager
//{
//    if (!_peripheralManager) {
//        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
//
//    }
//    return _peripheralManager;
//}

+ (BlueToothPeripheral *)getInstance
{
    static BlueToothPeripheral *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[BlueToothPeripheral alloc]init];
        [shareInstance initData];
    });
    return shareInstance;
}

-(void)initData
{
    _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}

- (void)effect
{
    [BlueToothPeripheral getInstance];
//    NSLog(@"%@",self.peripheralManager.isAdvertising);
}

- (void)startAdvise
{
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    /*
     可以通知的Characteristic
     properties：CBCharacteristicPropertyNotify
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:notiyCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    /*
     可读写的characteristics
     properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
     */
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readwriteCharacteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    
    
    /*
     只读的Characteristic
     properties：CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    
    //service1初始化并加入两个characteristics
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID1] primary:YES];
    
    [service1 setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];
    
    //service2初始化并加入一个characteristics
    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID2] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
    [_peripheralManager addService:service1];
    [_peripheralManager addService:service2];
    [self.peripheralManager startAdvertising:@{
                                               CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:ServiceUUID1],[CBUUID UUIDWithString:ServiceUUID2]],
                                               CBAdvertisementDataLocalNameKey : LocalNameKey
                                               }];
    
}


- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
        {
//            NSLog(@">>>>>>>%zd",self.peripheralManager.isAdvertising);
        }
            break;
        case CBManagerStateResetting:
        {
            
        }
            break;
        case CBPeripheralManagerStatePoweredOff:
        {
            NSLog(@"powered off");
        }
            break;
        default:
        {
            
        }
            break;
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didAddService");
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"in peripheralManagerDidStartAdvertisiong");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"订阅了 %@的数据",characteristic.UUID);
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"订阅了 %@的数据",characteristic.UUID);
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"didReceiveReadRequest");
    NSData *data = request.characteristic.value;
    [request setValue:data];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSLog(@"didReceiveWriteRequests:%@",requests.firstObject.value);
    
}

@end
