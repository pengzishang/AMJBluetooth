//
//  BlueToothObject.m
//  blueToothTest
//
//  Created by pzs on 2017/8/15.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "BlueToothObject.h"
#import "NSString+StringOperation.h"

@implementation BlueToothObject



-(instancetype _Nonnull )initWithDeviceID:(NSString *_Nonnull)deviceID command:(NSString * _Nullable)command sendType:(SendType)sendType;
{
    self = [super init];
    if (self) {
        _deviceID = deviceID;
        _peripheral = [self isAvailable];
        _UUID = _peripheral.identifier.UUIDString;
        _failTime  = 0;
        _deviceIndex = NSUIntegerMax ;
        _sendType = sendType;
        _command = command;
        _commandData = [self commandDataWithObject];
        _timeOutTimer = [self setTimeOutTimer];
        
    }
    return self;
}

- (instancetype)initWithDeviceID:(NSString *)deviceID command:(NSString *)command sendType:(SendType)sendType isNotify:(BOOL)isNotify
{
    self.isNotifySuccess = isNotify;
    return [self initWithDeviceID:deviceID command:command sendType:sendType];
}


- (CBPeripheral *_Nullable)isAvailable
{
    NSString * opeartionDeviceID = _deviceID;
    BOOL isAvailable = NO;
    CBPeripheral *curPeripheral;
    for (NSDictionary *perInfo in [BluetoothManager getInstance].peripheralsInfo) {
        NSDictionary *peripheralInfo = perInfo[AdvertisementData];
        NSString *deviceIDFromAdv = peripheralInfo[@"kCBAdvDataLocalName"];
        if ([deviceIDFromAdv containsString:opeartionDeviceID]) {
            curPeripheral = perInfo[Peripheral];
            isAvailable = YES;
            break;
        }
    }
    return isAvailable ? curPeripheral : nil;
}


- (NSData *)commandDataWithObject
{
    NSAssert(_command.length % 3 ==0, @"命令长度不是3的倍数");
    NSData *commandData = nil;
    if (_sendType==SendTypeLock)
    {//无验证码,校验
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnLockControl:_command];
    }
    else if (_sendType==SendTypeInfrared)
    {//有校验位
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnInfrareControl:_command];
    }
    else if (_sendType==SendTypeSingle)
    {
        self.seviceID = @"FFF0";
        self.characterID = @"FFF1";
        commandData = [self returnSwitchControl:_command];
    }
    else if (_sendType==SendTypeRemote)
    {
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnRemote:_command length:20];
    }
    else if (_sendType==SendTypeRemoteTemp)
    {
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnRemote:_command length:10];
    }
    else if (_sendType==SendTypeSellMachine)
    {
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnRemote:_command length:10];
    }
    else if (_sendType==SendTypeRemoteNew)
    {
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnRemote:_command length:19];
    }
    else if (_sendType==SendTypeQuery)
    {
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = nil;
    }
    else if (_sendType==SendTypeWithNoVerify)
    {//无验证码,校验
        self.seviceID = @"FFF0";
        self.characterID = @"FFF6";
        commandData = [self returnLockControl:_command];
    }
    else if (_sendType==SendTypeSellMachine828)
    {//无验证码,校验
        if (!_isNotifySuccess) {
            self.seviceID = @"FF00";
            self.characterID = @"FF02";
            commandData = nil;
        }
        else
        {
            self.seviceID = @"FF00";
            self.characterID = @"FF01";
            commandData = [self returnLockControl:_command];
        }
        
    }
    return commandData;
}


-(NSData *)returnLockControl:(NSString *)commandStr
{
    return  [NSData dataWithBytes:[NSString translateToByte:commandStr] length:10];
}

-(NSData *)returnSwitchControl:(NSString *)commandStr
{
    Byte commamd = (Byte) [commandStr integerValue];
    return  [NSData dataWithBytes:&commamd length:1];
}

-(NSData *)returnInfrareControl:(NSString *)commandStr
{
    Byte *byte1to9 = [NSString translateToByte:commandStr];
    Byte byteCommand[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    for (NSInteger i = 0; i < 9; i++) {
        byteCommand[i] = byte1to9[i];
    }
    byteCommand[9] = byte1to9[1] ^ byte1to9[2] ^ byte1to9[3];//第10个字节
    return  [NSData dataWithBytes:byteCommand length:10];
}

-(NSData *)returnRemote:(NSString *)commandStr length:(NSUInteger)length
{
    if (length ==20) {//需要校验
        Byte *byte1to20 = [NSString translateToByte:commandStr];
        Byte byteCommand[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        for (NSInteger i = 0; i < 19; i++) {
            byteCommand[i] = byte1to20[i];
            byteCommand[19]=(i==0?byteCommand[0]:byteCommand[19] ^ byteCommand[i]);
        }
        return  [NSData dataWithBytes:byteCommand length:20];
    }
    else if (length ==19){//新遥控器的命令
        Byte *byte1to19 = [NSString translateToByte:commandStr];
        return  [NSData dataWithBytes:byte1to19 length:19];
    }
    else {//(length==10)
        Byte *byte1to10 = [NSString translateToByte:commandStr];
        Byte byteCommand[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        for (NSInteger i = 0; i < 9; i++) {
            byteCommand[i] = byte1to10[i];
            byteCommand[9]=i==0?byteCommand[i]:byteCommand[9] ^ byteCommand[i];
        }
        return  [NSData dataWithBytes:byteCommand length:10];
    }
}

- (NSTimer *)setTimeOutTimer{
//    NSTimer *timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(timeOUT) userInfo:nil repeats:NO];
    NSTimer *timers = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer invalidate];
        [_delegate opertionTimeOut:self];
    }];
    return timers;
}

-(void)timeOUT
{
    [self.timeOutTimer invalidate];
    [_delegate opertionTimeOut:self];
}


-(void)startRunningTime
{
//    [self.timeOutTimer fire];
    [[NSRunLoop currentRunLoop] addTimer:self.timeOutTimer forMode:NSDefaultRunLoopMode];
}

-(void)stopRunningTime
{
    [self.timeOutTimer invalidate];
}


@end
