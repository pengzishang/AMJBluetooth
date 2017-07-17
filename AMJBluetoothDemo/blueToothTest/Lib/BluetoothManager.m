//
//  BluetoothManager.m
//  ttsBluetooth_iPhone
//
//  Created by tts on 14-10-10.
//  Copyright (c) 2014年 tts. All rights reserved.
//


//如果寻找设备过久,很容易导致控制失败
#import "BluetoothManager.h"
#import "NSString+StringOperation.h"

static BluetoothManager *shareInstance;

typedef void(^stateValueFailReturn)(NSInteger);

typedef void(^stateValueSuccessReturn)(NSData *);

typedef void(^localSuccessReturn)(NSUInteger deviceIndex,NSData *feedbackCode);

typedef void(^localFailReturn)(NSUInteger deviceIndex,NSUInteger failCode);

@interface BluetoothManager () {
    BOOL _isDiscoverSuccess;
    BOOL _isWritingSuccess;
    BOOL _isConnectingSuccess;
    BOOL _isGetValueSuccess;
    BOOL _scanFastSpeed;
    NSData *_stateData;
    SendType _sendType;
    NSDate *_dataf;
    NSTimer *_timeOutTimer;
    CBCentralManager *_centralManager;
    CBPeripheral *_curPeripheral;
    
    NSTimer *_refreshTimer;
    NSArray *allAMJDeviceInfo;
    
}

@property(copy, nonatomic, nonnull) stateValueSuccessReturn successControl;
@property(copy, nonatomic, nonnull) stateValueFailReturn failControl;

@property(copy, nonatomic, nonnull) localSuccessReturn partSuccess;
@property(copy, nonatomic, nonnull) localFailReturn partFail;

/**
 扫描的设备种类
 */
@property(strong, nonatomic, nullable) NSMutableArray<__kindof NSString *> *scaningPreFix;
@property(strong, nonatomic, nullable , readwrite) NSMutableArray <__kindof NSDictionary <NSString *,id>*> *peripheralsInfo;
@property(strong,nonatomic,nullable)NSMutableArray <__kindof NSDictionary *>*dataArr;
@end

@implementation BluetoothManager

NSString *_Nonnull const ScanTypeDescription[] = {
        [ScanTypeSocket]            =   @"ScanTypeSocket",
        [ScanTypeSwitch]            =   @"ScanTypeSwitch",
        [ScanTypeCurtain]           =   @"ScanTypeCurtain",
        [ScanTypeWarning]           =   @"ScanTypeWarning",
        [ScanTypeOther]             =   @"ScanTypeOther",
        [ScanTypeWIFIControl]       =   @"ScanTypeWIFIControl",
        [ScanTypeInfraredControl]   =   @"ScanTypeInfraredControl",
        [ScanTypeRemoteControl]     =   @"ScanTypeRemoteControl",
        [ScanTypeAll]               =   @"ScanTypeAll",
};

+ (BluetoothManager *)getInstance {
    if (shareInstance == nil) {
        shareInstance = [[BluetoothManager alloc] init];
        [shareInstance initData];
    }
    return shareInstance;
}


- (NSMutableArray<NSString *> *)scaningPreFix {
    if (!_scaningPreFix) {
        _scaningPreFix = [NSMutableArray array];
    }
    return _scaningPreFix;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)peripheralsInfo {
    if (!_peripheralsInfo) {
        _peripheralsInfo = [NSMutableArray array];
    }
    return _peripheralsInfo;
}

- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

-(void)effect
{
    [[BluetoothManager getInstance] initData];
}

//+ (void)load
//{
//    __block id observer = [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        [BluetoothManager getInstance];
//        
//        [[NSNotificationCenter defaultCenter] removeObserver:observer];
//    }];
//}


- (void)initData {
    NSLogMethodArgs(@"%@", self.centralManager.isScanning?@"载入成功,开始扫描":@"正在载入");
}

- (void)scanPeriherals:(BOOL)isAllowDuplicates AllowPrefix:(NSArray<__kindof NSNumber *> *_Nullable)PrefixArr {
    /*****是否重复scan****/
    //任意扫描
    [self initPreFix:PrefixArr];
    _scanFastSpeed = isAllowDuplicates;
    NSDictionary *optionsDic = @{CBCentralManagerScanOptionAllowDuplicatesKey: @(isAllowDuplicates)};
    //代理触发更新了
    [_refreshTimer invalidate];
    _refreshTimer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(refreshNearDevice:) userInfo:optionsDic repeats:YES];
    [_refreshTimer fire];
}

-(void)refreshNearDevice:(NSTimer *)sender
{
    [self.centralManager scanForPeripheralsWithServices:nil options:sender.userInfo];
}

- (void)initPreFix:(NSArray <__kindof NSNumber *> *)PrefixArr {
    [self.scaningPreFix removeAllObjects];
    if (PrefixArr.count == 0) {
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DeviceTypeList" ofType:@"plist"];
    NSDictionary *DeviceTypeList = [NSDictionary dictionaryWithContentsOfFile:path];
    [PrefixArr enumerateObjectsUsingBlock:^(__kindof NSNumber *_Nonnull scanTypeNum, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *deviceTypeStr = [self getScanTypeString:(ScanType) scanTypeNum.integerValue];
        if ([[DeviceTypeList allKeys] containsObject:deviceTypeStr]) {
            [_scaningPreFix addObjectsFromArray:[DeviceTypeList[deviceTypeStr][0] allKeys]];
        }
    }];
}

- (NSString *)getScanTypeString:(ScanType)scan {
    return ScanTypeDescription[scan];
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)disconnectPeriheral:(NSTimer *)sender {
    CBPeripheral *peripheral = (CBPeripheral *) sender.userInfo;
    [self.centralManager cancelPeripheralConnection:peripheral];
    [sender invalidate];
}

- (void)connect2Peripheral:(CBPeripheral *)curPeripheral {
    
    curPeripheral.delegate = self;
    
    //    NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnConnectionKey: @NO,
    //            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @NO,
    //            CBConnectPeripheralOptionNotifyOnNotificationKey: @NO};
    
        [self setTimeOutWithPeriheral:curPeripheral];
    
    
    //    [self.centralManager connectPeripheral:curPeripheral options:options];
    [self.centralManager connectPeripheral:curPeripheral options:nil];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"STEP1:开始连接:%f  id:%@", time1, curPeripheral.name);
}

- (void)queryDeviceStatus:(NSString *)deviceID
                  success:(void (^ _Nullable)(NSData *_Nullable))success
                     fail:(NSUInteger (^ _Nullable)(NSString *_Nullable))fail
{
//    [self queryDeviceStatus:deviceID retryTime:3 success:success fail:fail];
    _sendType = SendTypeQuery;
    [self sendMutiCommandWithSingleDeviceID:deviceID sendType:_sendType retryTime:3 commands:nil success:success fail:fail];
}

- (void)queryDeviceStatus:(nonnull NSString *)deviceID retryTime:(NSUInteger)retryTime
                  success:(void (^ _Nullable)(NSData *_Nullable data))success
                     fail:(NSUInteger(^ _Nullable)(NSString * __nonnull statusCode))fail
{
    _sendType = SendTypeQuery;
    _isWritingSuccess = YES;
    _isConnectingSuccess = NO;
    _isDiscoverSuccess = NO;
    [self.dataArr removeAllObjects];
    _dataf = [NSDate date];
    if (success) {
        __block BluetoothManager *blockManger = self;
        blockManger.successControl = ^(NSData *stateData) {
            //返回成功
            success(stateData);
        };
    }
    
    if (fail) {
        __block BluetoothManager *blockManger = self;
        blockManger.failControl = ^(NSInteger stateCode) {
            NSString *stateCodeStr = @(stateCode).stringValue;
            //返回错误状态码
//            fail(stateCodeStr);
            static NSUInteger failRetryTime = 0;
            if (failRetryTime<retryTime) {
                failRetryTime +=1;
            }
            else{
                failRetryTime = 0;
            }
            if (failRetryTime != 0 && [stateCodeStr integerValue] != 404 && [stateCodeStr integerValue] != 403) {
                CBPeripheral *curPeripheral = [self isAvailableID:deviceID];
                [self connect2Peripheral:curPeripheral];
            } else {
                fail(stateCodeStr);
                NSLog(@"重试次数为0或者不在范围,错误代码:%@",stateCodeStr);
            }
        };
    }
    
    
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        if (self.failControl) {
            _failControl(403);
        }
    }
    
    CBPeripheral *curPeripheral = [self isAvailableID:deviceID];
    
    if (curPeripheral) {
        [self connect2Peripheral:curPeripheral];
    } else {//超出范围
        if (self.failControl) {
            self.failControl(404);
        }
    }

}



- (void)setTimeOutWithPeriheral:(CBPeripheral *)periheral {

    _timeOutTimer = nil;
        [_timeOutTimer invalidate];
    _timeOutTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(disconnectPeriheral:) userInfo:periheral repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timeOutTimer forMode:NSDefaultRunLoopMode];
}


- (void)sendByteCommandWithString:(NSString *)commandStr
                         deviceID:(NSString *)deviceID
                         sendType:(SendType)sendType
                          success:(void (^)(NSData *_Nullable))success
                             fail:(NSUInteger (^)(NSString *_Nullable))fail
{
//    [self sendByteCommandWithString:commandStr deviceID:deviceID sendType:sendType retryTime:3 success:success fail:fail];
    
    [self sendMutiCommandWithSingleDeviceID:deviceID sendType:sendType retryTime:3 commands:@[commandStr] success:success fail:fail];
}

- (void)sendByteCommandWithString:(NSString *__nonnull)commandStr
                         deviceID:(NSString *__nonnull)deviceID
                         sendType:(SendType)sendType retryTime:(NSUInteger)retryTime
                          success:(void (^ _Nullable)(NSData *__nullable stateData))success
                             fail:(NSUInteger (^ _Nullable)(NSString *__nullable stateCode))fail
{
    //命令处理
    _isDiscoverSuccess = NO;
    _isWritingSuccess = NO;
    _isConnectingSuccess = NO;
    NSLog(@"当前的DeviceID:%@   命令:%@", deviceID, commandStr);
    _sendType = sendType;
    [self.dataArr removeAllObjects];
    
    //计时器
    _dataf = [NSDate date];
    
    if (success) {
        __block BluetoothManager *blockManger = self;
        blockManger.successControl = ^(NSData *stateData) {
            //返回成功
            success(stateData);
        };
    }
    if (fail) {
        __block BluetoothManager *blockManger = self;
        blockManger.failControl = ^(NSInteger stateCode) {
            NSString *stateCodeStr = @(stateCode).stringValue;
            //返回错误状态码
//            NSUInteger failRetryTime = fail(stateCodeStr);
            
            static NSUInteger failRetryTime = 0;
            if (failRetryTime<retryTime) {
                failRetryTime +=1;
            }
            else{
                failRetryTime = 0;
            }

            if (failRetryTime != 0 && [stateCodeStr integerValue] != 404 && [stateCodeStr integerValue] != 403) {
                CBPeripheral *curPeripheral = [self isAvailableID:deviceID];
                if (curPeripheral) {
                    [self connect2Peripheral:curPeripheral];
                }
            } else {
                fail(stateCodeStr);
                NSLog(@"重试次数为0或者不在范围,错误代码:%@",stateCodeStr);
            }
        };
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        if (self.failControl) {
            _failControl(403);
        }
    }
    
    CBPeripheral *curPeripheral = [self isAvailableID:deviceID];
    if (curPeripheral) {
        NSString *udid = curPeripheral.identifier.UUIDString;
        [self initCommandWithStr:commandStr UDID:udid];
        [self connect2Peripheral:curPeripheral];
    } else {
        if (self.failControl) {
            self.failControl(404);
        }
    }
}

- (void)sendMutiCommandWithSingleDeviceID:(NSString *__nonnull)deviceID
                                 sendType:(SendType)sendType
                                retryTime:(NSUInteger)retryTime
                                 commands:(NSArray<__kindof NSString *> * _Nullable)commands
                                  success:(void (^ _Nullable)(NSData * _Nullable))success
                                     fail:(NSUInteger (^ _Nullable)(NSString * _Nullable))fail

{
    //立一个小block
    //成功:返回设备序列号,如果序列号和传来的最大数量相等,n那么返回大成功
    //失败:返回设备序列号和失败代码,如果传来设备故障,那么立即返回大失败,如果返回写入失败和任何可持续写入的失败代码,继续重复发送
    __block BluetoothManager *blockManger = self;
    static NSUInteger failTime = 0;
    self.partSuccess = ^(NSUInteger deviceIndex, NSData *feedbackCode) {
        _isDiscoverSuccess = NO;
        _isWritingSuccess = NO;
        _isConnectingSuccess = NO;
        deviceIndex += 1;
        failTime = 0;
        if (deviceIndex<commands.count) {
            BOOL isLast = (deviceIndex == commands.count-1)?YES:NO;
            [blockManger sendCommmandWithDeviceID:deviceID sendType:sendType deviceIndex:deviceIndex command:commands[deviceIndex] isLast:isLast];
        }
        else
        {
            if (success) {
                success(feedbackCode);
            }
        }
    };
    self.partFail = ^(NSUInteger deviceIndex, NSUInteger failCode) {
        _isDiscoverSuccess = NO;
        _isWritingSuccess = NO;
        _isConnectingSuccess = NO;
        NSLog(@"\n*******************************发生错误,错误代码:%zd*******************************\n",failCode);
        
        if (failCode == 403 ||failCode == 404) {
            failTime = 0 ;
            if (fail) {
                fail([NSString stringWithFormat:@"%zd",failCode]);
            }
        }
        else {
            if (failTime < retryTime) {//情况1,出错但是最后一个  情况2:发到一半出错,断开还是不断开?
                failTime ++;
                NSLog(@"\n*******************************第%zd次重试*******************************\n",failTime);
                deviceIndex =(deviceIndex == NSUIntegerMax)?0:deviceIndex;
                BOOL isLast = (deviceIndex == commands.count-1)?YES:NO;
                [blockManger sendCommmandWithDeviceID:deviceID sendType:sendType deviceIndex:deviceIndex command:commands[deviceIndex] isLast:isLast];
            }
            else
            {
                failTime = 0;
                if (fail) {
                    fail([NSString stringWithFormat:@"%zd",failCode]);
                }
            }
            
        }
    };
    BOOL isLast = (commands.count ==1)?YES:NO;
    if (_sendType == SendTypeQuery) {
        [self sendCommmandWithDeviceID:deviceID sendType:sendType deviceIndex:0 command:nil isLast:isLast];
    } else {
        [self sendCommmandWithDeviceID:deviceID sendType:sendType deviceIndex:0 command:commands.firstObject isLast:isLast];
    }
    
    
    
    
}


/**
 通用发送方法

 @param deviceID <#deviceID description#>
 @param deviceIndex <#deviceIndex description#>
 @param command <#command description#>
 */
- (void)sendCommmandWithDeviceID:(NSString *__nonnull)deviceID  sendType:(SendType)sendType deviceIndex:(NSUInteger)deviceIndex command:(NSString *)command isLast:(BOOL)isLast
{
    _sendType = sendType;
    [self.dataArr removeAllObjects];
    _dataf = [NSDate date];
    NSLog(@"\n*******************************第%zd个设备(命令)*******************************\n",deviceIndex+1);
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        if (self.partFail) {
            self.partFail(deviceIndex, 403);
        }
    }
    CBPeripheral *curPeripheral = [self isAvailableID:deviceID];
    if (curPeripheral) {
        NSString *udid = curPeripheral.identifier.UUIDString;
        [self initCommandWithStr:command UDID:udid deviceIndex:deviceIndex isLast:isLast];
        [self connect2Peripheral:curPeripheral];
    } else {
        if (self.partFail) {
            self.partFail(deviceIndex, 404);
        }
    }
}


- (void)mutiCommandControlWithStringArr:(NSArray <NSDictionary <NSString *,id>*> *__nullable)commandArr resultList:(void (^ _Nullable)(NSArray *_Nullable))resultList; {
    _dataf = [NSDate date];
    NSUInteger totalCount = commandArr.count;
    if (commandArr.count == 0) {
        return;
    }

    __block NSUInteger operationIndex = 0;
    __block NSMutableDictionary *operationDic = [NSMutableDictionary dictionaryWithDictionary:commandArr[operationIndex]];
    __block NSString *operationDeviceID = commandArr[operationIndex][@"deviceID"];
    __block NSString *operationCommand = commandArr[operationIndex][@"deviceCommand"];
    __block NSUInteger operationDeviceType = [commandArr[operationIndex][@"deviceType"] integerValue];
    __block NSMutableArray *requestArr = [NSMutableArray array];

    [self
     sendByteCommandWithString:operationCommand
     deviceID:operationDeviceID
     sendType:SendTypeSingle
     success:^(NSData *_Nullable stateData) {
         operationDic = [NSMutableDictionary dictionaryWithDictionary:commandArr[operationIndex]];
         operationDic[@"stateCode"] = [self returnStateCodeWithData:stateData btnCount:operationDeviceType];
         [requestArr addObject:operationDic];
         if (operationIndex + 1 < totalCount) {
             operationIndex++;
             operationDeviceID = commandArr[operationIndex][@"deviceID"];
             operationCommand = commandArr[operationIndex][@"deviceCommand"];
             operationDeviceType = [commandArr[operationIndex][@"deviceType"] integerValue];
             [self sendByteCommandWithString:operationCommand deviceID:operationDeviceID sendType:SendTypeSingle success:nil fail:nil];
         }
         else
         {
             operationIndex = 0;
             if (resultList) {
                 resultList(requestArr);
             }
         }
     }
     fail:^NSUInteger(NSString *_Nullable stateCode) {
         
         operationDic = [NSMutableDictionary dictionaryWithDictionary:commandArr[operationIndex]];
         operationDic[@"stateCode"] = @(stateCode.integerValue);//待修改
         [requestArr addObject:operationDic];
         if (operationIndex + 1 < totalCount) {
             operationIndex++;
             operationDeviceID = commandArr[operationIndex][@"deviceID"];
             operationCommand = commandArr[operationIndex][@"deviceCommand"];
             operationDeviceType = [commandArr[operationIndex][@"deviceType"] integerValue];
             [self sendByteCommandWithString:operationCommand deviceID:operationDeviceID sendType:SendTypeSingle success:nil fail:nil];
         } else {
             operationIndex = 0;
             if (resultList) {
                 resultList(requestArr);
             }
         }
         return 0;
     }];
    
}


- (NSNumber *)returnStateCodeWithData:(NSData *)data btnCount:(NSUInteger)btnCount {
    Byte byte;
    [data getBytes:&byte length:1];
    if (btnCount == 0 || btnCount == 1) {
        byte = byte & 0x01;
    } else if (btnCount == 2) {
        byte = byte & 0x03;
    } else if (btnCount == 3) {
        byte = byte & 0x07;
    } else if (btnCount == 4 || btnCount == 5) {
    }
    return @(byte);
}

- (void)initCommandWithStr:(NSString *)commandStr UDID:(NSString *)UDID
{
    [self initCommandWithStr:commandStr UDID:UDID deviceIndex:NSUIntegerMax isLast:YES];
}

- (void)initCommandWithStr:(NSString *)commandStr UDID:(NSString *)UDID deviceIndex:(NSUInteger)deviceIndex isLast:(BOOL)isLast
{
    if (_sendType==SendTypeLock) {//无验证码,校验
        [self.dataArr addObject:@{@"Data": [self returnLockControl:commandStr], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeInfrared)
    {//有校验位
        [self.dataArr addObject:@{@"Data": [self returnInfrareControl:commandStr], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeSingle)
    {
        [self.dataArr addObject:@{@"Data": [self returnSwitchControl:commandStr], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeRemote)
    {
        [self.dataArr addObject:@{@"Data": [self returnRemote:commandStr length:20], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeRemoteTemp)
    {
        [self.dataArr addObject:@{@"Data": [self returnRemote:commandStr length:10], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeSellMachine)
    {
        [self.dataArr addObject:@{@"Data": [self returnRemote:commandStr length:10], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeRemoteNew)
    {
        [self.dataArr addObject:@{@"Data": [self returnRemote:commandStr length:19], @"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
    else if (_sendType==SendTypeQuery)
    {
        [self.dataArr addObject:@{@"ID": UDID,@"deviceIndex":@(deviceIndex),@"isLast":@(isLast)}];
    }
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
    if (length ==20) {
        Byte *byte1to20 = [NSString translateToByte:commandStr];
        Byte byteCommand[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        for (NSInteger i = 0; i < 19; i++) {
            byteCommand[i] = byte1to20[i];
            byteCommand[19]=(i==0?byteCommand[0]:byteCommand[19] ^ byteCommand[i]);
        }
        return  [NSData dataWithBytes:byteCommand length:20];
    }
    else if (length ==19){
        Byte *byte1to19 = [NSString translateToByte:commandStr];
        Byte byteCommand[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        for (NSInteger i = 0; i < 19; i++) {
            byteCommand[i] = byte1to19[i];
            byteCommand[18]=(i==0?byteCommand[0]:byteCommand[18] ^ byteCommand[i]);
        }
        return  [NSData dataWithBytes:byteCommand length:19];
    }
    else {//(length==10)
        Byte *byte1to10 = [NSString translateToByte:commandStr];
        Byte byteCommand[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        for (NSInteger i = 0; i < 19; i++) {
            byteCommand[i] = byte1to10[i];
            byteCommand[9]=i==0?byteCommand[i]:byteCommand[9] ^ byteCommand[i];
        }
        return  [NSData dataWithBytes:byteCommand length:10];
    }
}


- (void)refreshMutiDeviceInfo:(CBPeripheral *)peripheral {
    _sendType = SendTypeSyncdevice;
    _curPeripheral = peripheral;
    _curPeripheral.delegate = self;
    _dataf = [NSDate date];
    NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
            CBConnectPeripheralOptionNotifyOnNotificationKey: @YES};
    [self.centralManager connectPeripheral:_curPeripheral options:options];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"time1 sync:%f", time1);
}


- (CBPeripheral *)isAvailableID:(NSString *)opeartionDeviceID {
    BOOL isAvailable = NO;
    CBPeripheral *curPeripheral;
    for (NSDictionary *perInfo in self.peripheralsInfo) {
        NSDictionary *peripheralInfo = perInfo[AdvertisementData];
        NSString *deviceIDFromAdv = [peripheralInfo[@"kCBAdvDataLocalName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (deviceIDFromAdv.length > 7) {
            if ([deviceIDFromAdv containsString:opeartionDeviceID]) {
                curPeripheral = perInfo[Peripheral];
                isAvailable = YES;
                break;
            }
        }
    }
    return isAvailable ? curPeripheral : nil;
}


#pragma mark -  CBCentralManagerDelegate methodes   主要是发现,主设备动作


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown: {
        }
            break;
        case CBManagerStateResetting: {
            NSLog(@"蓝牙重置");
        }
            break;
        case CBManagerStatePoweredOff: {
            NSLog(@"蓝牙关闭");
        }
            break;
        case CBManagerStatePoweredOn: {
            NSLog(@"蓝牙打开");
            [self scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *deviceIDFromAdv = [advertisementData[@"kCBAdvDataLocalName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *deviceIDFromPeripheral = [peripheral.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([RSSI integerValue] <= -115 || [RSSI integerValue] == 127) {
        return;
    }
    if ([deviceIDFromAdv length] < 15 && deviceIDFromPeripheral.length < 15) {
        return;
    }
    __block BOOL isSelectPreFix = NO;
    //检查前缀是否符合条件
    [_scaningPreFix enumerateObjectsUsingBlock:^(__kindof NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([deviceIDFromAdv hasPrefix:obj]) {
            isSelectPreFix = YES;
            *stop = YES;
        }
    }];
    if (!isSelectPreFix) {
        return;
    }
    //慢速,监测扫描,
    if (!_scanFastSpeed) {
        if (deviceIDFromAdv.length < 6) {
            return;
        }
        NSString *stateCode = [deviceIDFromAdv substringWithRange:NSMakeRange(6, 1)];
        NSString *deviceType = [deviceIDFromAdv substringWithRange:NSMakeRange(5, 1)];//这个以后可能出问题.面对两位的类型
        NSInteger stateIndex = [stateCode characterAtIndex:0];

        NSNumber *stateCodeCurrent = [[NSNumber alloc] init];
        if ([deviceType isEqualToString:@"0"] || [deviceType isEqualToString:@"1"]) {
            stateCodeCurrent = @(stateIndex & (0x01));
        } else if ([deviceType isEqualToString:@"2"]) {
            stateCodeCurrent = @(stateIndex & (0x03));
        } else {
            stateCodeCurrent = @(stateIndex & (0x07));
        }
        if ([stateCode isEqualToString:@":"] || [deviceIDFromAdv hasPrefix:@"WIFI"]) {
//            stateIndex = 48;//48一个不存在的状态
            stateCodeCurrent = @(-1);
            //老设备
        }
        __block BOOL isContain = NO;
        __block BOOL isStatusSame = NO;
        __block NSUInteger operationIndex = 0;
        [self.peripheralsInfo enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            CBPeripheral *peripheralInStore = obj[Peripheral];
            NSString *pIdentiferInStore = peripheralInStore.identifier.UUIDString;
            NSString *pIdentiferCurrent = peripheral.identifier.UUIDString;
            if ([pIdentiferInStore isEqual:pIdentiferCurrent]) {
                isContain = YES;
                NSNumber *stateCodeInStore = @([obj[@"stateCode"] integerValue]);
                if ([stateCodeCurrent isEqualToNumber:stateCodeInStore] && ![deviceIDFromAdv containsString:@"Lock"]) {//含有Lock是开门状态
                    isStatusSame = YES;
                } else {
                    operationIndex = idx;
                    NSLogMethodArgs(@"刷新 %@  强度:%@ 原状态:%@ 现状态:%@", deviceIDFromAdv, RSSI, stateCodeInStore, stateCodeCurrent);
                }

            }
        }];


        //如果没有与现有或者新发现的设备重复,那么加入全局的周边设备库
        if (!isContain) {
            NSDictionary *peripheralInfo = @{Peripheral: peripheral, AdvertisementData: advertisementData, RSSI_VALUE: RSSI, @"stateCode": stateCodeCurrent};
            [[NSNotificationCenter defaultCenter]postNotificationName:BlueToothMangerDidDiscoverNewItem object:nil userInfo:peripheralInfo];
            [[self mutableArrayValueForKey:@"peripheralsInfo"] addObject:peripheralInfo];//数组,观察者
        } else if (isContain && !isStatusSame) {
            //不一样
            if ([deviceIDFromAdv containsString:@"Lock"]) {
                stateCodeCurrent = @(1);//1为开门状态
            }
            
            NSDictionary *peripheralInfo = @{Peripheral: peripheral, AdvertisementData: advertisementData, RSSI_VALUE: RSSI, @"stateCode": stateCodeCurrent};
            [self.peripheralsInfo replaceObjectAtIndex:operationIndex withObject:peripheralInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:BlueToothMangerDidItemChangeInfo object:nil userInfo:peripheralInfo];
        }
    }

        //快速扫描,耗资源
    else if (_scaningPreFix.count != 0 && _scanFastSpeed) {
        if (deviceIDFromAdv.length < 6) {
            return;
        }
        NSString *stateCode = [deviceIDFromAdv substringWithRange:NSMakeRange(6, 1)];
        NSString *deviceType = [deviceIDFromAdv substringWithRange:NSMakeRange(5, 1)];
        NSUInteger stateIndex = [stateCode characterAtIndex:0];

        NSNumber *stateCodeCurrent = [[NSNumber alloc] init];
        if ([deviceType isEqualToString:@"0"] || [deviceType isEqualToString:@"1"]) {
            stateCodeCurrent = @(stateIndex & (0x01));
        } else if ([deviceType isEqualToString:@"2"]) {
            stateCodeCurrent = @(stateIndex & (0x03));
        } else {
            stateCodeCurrent = @(stateIndex & (0x07));
        }

        if ([stateCode isEqualToString:@":"] || [deviceIDFromAdv hasPrefix:@"WIFI"]) {
            stateIndex = 48;//48一个不存在的状态
            stateCodeCurrent = @(-1);
            //老设备
        }
        NSLog(@"快速扫描 %@|  强度:%@  状态:%@", deviceIDFromAdv, RSSI, stateCodeCurrent);
        NSDictionary *peripheralInfo = @{Peripheral: peripheral, AdvertisementData: advertisementData, RSSI_VALUE: RSSI, @"stateCode": stateCodeCurrent};
        if (_detectDevice) {
            _detectDevice(peripheralInfo);
        }

    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    _isConnectingSuccess = YES;
    NSLog(@"STEP2:连接设备成功,开始寻找服务:%f,ID:%@", time1,peripheral.name);
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
    [peripheral discoverServices:@[uuid]];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLogMethodArgs(@"STEP7:断开设备:%f,ID:%@", time1,peripheral.name)
    if (error) {
        if (self.failControl) {
            //结束失败
            self.failControl(107);
            NSLogMethodArgs(@"异常断开连接 --- %@,ID:%@", error,peripheral.name);
        }
        if (self.partFail) {
            self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 107);
        }
        
    } else {
        BOOL isResponse = NO;
        if (![[NSString stringWithFormat:@"%@", _stateData] hasPrefix:@"<ef"]) {//如果有ef,证明红外伴侣未响应
            isResponse = YES;
        }
        if (_isDiscoverSuccess && _isWritingSuccess && isResponse &&_isConnectingSuccess) {
            if ((_sendType == SendTypeQuery&&!_isGetValueSuccess)) {
                if (self.failControl) {
                    self.failControl(105);
                }
                if (self.partFail) {
                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 105);
                }
            }
            else
            {
                if (self.successControl) {
                    self.successControl(_stateData);
                    NSLogMethodArgs(@"正常断开,ID:%@",peripheral.name);
                }
                if (self.partSuccess) {
                    self.partSuccess([self returnIndexOfDeviceWithPeripheral:peripheral], _stateData);
                }
            }
            
        } else {
            if (!_isDiscoverSuccess) {//防止未发现服务提前中止造成正常连接的误报
                if (self.failControl) {
                    self.failControl(103);
                }
                if (self.partFail) {
                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 103);
                }
            } else if (!_isWritingSuccess) {
                if (self.failControl) {
                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.failControl(104);
                }
                if (self.partFail) {
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 104);
                }
            } else if (!isResponse) {
                if (self.failControl) {
                    self.failControl(106);
                }
                if (self.partFail) {
                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 106);
                }
            } else if (!_isConnectingSuccess){
                if (self.failControl) {
                    self.failControl(102);
                }
                if (self.partFail) {
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 102);
                }
            }
        }
    }
}

-(NSUInteger)returnIndexOfDeviceWithPeripheral:(CBPeripheral *)peripheral
{
    NSDictionary *data = self.dataArr[0];
    return [data[@"deviceIndex"] integerValue];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        if (self.failControl) {
            self.failControl(102);
        }
        if (self.partFail) {
            self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 102);
        }
    }
    NSLogMethodArgs(@"连接失败 --- %@,ID:%@", error.localizedDescription,peripheral.name);
}


#pragma mark -  CBPeripheralDelegate methodes 主要是控制

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"STEP3:已经发现服务 寻找特征字:%f,ID:%@", time1,peripheral.name);
    if (peripheral.services.count == 0) {
        NSLogMethodArgs(@"设备找不到服务");
        [self.centralManager cancelPeripheralConnection:peripheral];
//        if (self.failControl) {
//            [self.centralManager cancelPeripheralConnection:peripheral];
//        }
//        if (self.partFail) {
//            self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 103);
//        }
    }
    for (CBService *service in peripheral.services) {
        NSString *serviceID = service.UUID.UUIDString;
        if ([serviceID isEqualToString:@"FFF0"]) {
            CBUUID *FFF1 = [CBUUID UUIDWithString:@"FFF1"];
            CBUUID *FFF6 = [CBUUID UUIDWithString:@"FFF6"];
            NSArray *characteristics = @[FFF1, FFF6];
            [peripheral discoverCharacteristics:characteristics forService:service];
            break;
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    _isDiscoverSuccess = YES;
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"STEP4:已经发现特征字,准备写入值:%f,ID:%@", time1,peripheral.name);
    for (CBCharacteristic *character in service.characteristics) {
        NSString *characterID = character.UUID.UUIDString;
        NSData *controlData = [self returnWithDeviceID:peripheral.identifier.UUIDString];
        if ([characterID isEqualToString:@"FFF1"] && [controlData length] == 1) {//短数据
            NSLog(@"写入1bit数据");
            [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            _isWritingSuccess = YES;
            break;
        }
        else if ([characterID isEqualToString:@"FFF6"]) {
            if ([controlData length] == 10||[controlData length] == 20||[controlData length] == 19) {//长数据
                //进行长数据写入
                NSLog(@"写入%zdbit长数据Data:%@", controlData.length,controlData);
                [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
            else {
                //进行查询数据
                [peripheral readValueForCharacteristic:character];
            }
            _isWritingSuccess = YES;
            break;
        }
    }
}

- (NSData *)returnWithDeviceID:(NSString *)deviceID {
    if (_sendType == SendTypeQuery) {
        return nil;
    }
    __block NSData *data = [[NSData alloc] init];
    [_dataArr enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj[@"ID"] isEqualToString:deviceID]) {
            data = obj[@"Data"];
            *stop = YES;
        }
    }];
    return data;
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        [peripheral readValueForCharacteristic:characteristic];
        _isWritingSuccess = YES;
        double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
        NSLog(@"STEP5:写入特征字成功 等待读取特征值:%f,ID:%@", time1,peripheral.name);
    } else {
        NSLogMethodArgs(@"写操作失败");
    }
}

/**
 * 读取到特征值
 更新完特征值后运行
 这里不影响开关控制了
 **/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        _stateData = characteristic.value;
    }
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    _isGetValueSuccess = YES;
    NSLog(@"STEP6:已经获取特征值%@,操作成功,准备断开:%f,ID:%@", _stateData, time1,peripheral.name);
    BOOL isLast = [self.dataArr.firstObject[@"isLast"] boolValue];
    if (isLast) {
        [_timeOutTimer invalidate];
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    else
    {
        [_timeOutTimer invalidate];
        if (self.partSuccess) {
            if (_sendType == SendTypeQuery) {
                self.partSuccess(0, _stateData);
            } else {
                self.partSuccess([self returnIndexOfDeviceWithPeripheral:peripheral], _stateData);
            }
            
        }
//        if (self.partFail) {
//            self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 888);
//        }
    }
}

@end
