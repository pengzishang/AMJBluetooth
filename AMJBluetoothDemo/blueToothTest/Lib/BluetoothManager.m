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

/**
 扫描类型
 
 - ScanTypeSocket: 只扫描插座
 - ScanTypeSwitch: 只扫描开关
 - ScanTypeCurtain: 窗帘
 - ScanTypeWarning: 报警
 - ScanTypeOther: 其他设备
 - ScanTypeWIFIControl: 远程控制器
 - ScanTypeInfraredControl:红外控制器
 - ScanTypeRemoteControl: 遥控器
 - ScanTypeAll: 全部
 */
typedef NS_ENUM(NSUInteger, ScanType) {
    ScanTypeSocket = 0,
    ScanTypeSwitch = 1,
    ScanTypeCurtain = 2,
    ScanTypeWarning = 3,
    ScanTypeOther = 4,
    ScanTypeWIFIControl = 5,
    ScanTypeInfraredControl = 6,
    ScanTypeRemoteControl = 7,
    ScanTypeAll = 8,
};

static BluetoothManager *shareInstance;

typedef void(^localSuccessReturn)(NSUInteger deviceIndex,NSData *feedbackCode);

typedef void(^localFailReturn)(NSUInteger deviceIndex,NSUInteger failCode);

@interface BluetoothManager () {
    BOOL _isDiscoverSuccess;
    BOOL _isWritingSuccess;
    BOOL _isConnectingSuccess;
    BOOL _isGetValueSuccess;
    BOOL _isMannelInterrupt;
    
    
    BOOL _scanFastSpeed;
    NSData *_stateData;
    SendType _sendType;
    NSDate *_dataf;
    NSTimer *_timeOutTimer;
    CBCentralManager *_centralManager;
    CBPeripheral *_curPeripheral;
    
    NSTimer *_refreshTimer;
    NSArray *allAMJDeviceInfo;
    NSTimeInterval _timeInterval;
    NSUInteger _retryTime;
}

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


- (NSMutableArray<NSDictionary<NSString *,id> *> *)peripheralsInfo
{
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
    _retryTime = 3 ;
    _timeInterval = 0;
    NSLogMethodArgs(@"%@", self.centralManager.isScanning?@"载入成功,开始扫描":@"正在载入");
}

- (void)scanPeriherals:(BOOL)isAllowDuplicates AllowPrefix:(NSArray<__kindof NSNumber *> *_Nullable)PrefixArr {
    /*****是否重复scan****/
    //任意扫描
    [self initPreFix:PrefixArr];
    _scanFastSpeed = isAllowDuplicates;
}


/**
 定时刷新

 @param sender <#sender description#>
 */
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
//        if (_curPeripheral) {
            CBPeripheral *peripheral = (CBPeripheral *) sender.userInfo;
            [self.centralManager cancelPeripheralConnection:peripheral];
            [sender invalidate];
//        }
}

- (void)connect2Peripheral:(CBPeripheral *)curPeripheral {
    
    curPeripheral.delegate = self;
    [self setTimeOutWithPeriheral:curPeripheral];
    [self.centralManager connectPeripheral:curPeripheral options:nil];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"Step1:开始连接:%f  id:%@", time1, curPeripheral.name);
}

/**
 中断当前操作(还有问题)
 */
- (void)interruptCurrentOpertion
{
    [self disconnectPeriheral:_timeOutTimer];
    _isMannelInterrupt = YES;
}


-(void)setInterval:(NSTimeInterval)timeInterval
{
    _timeInterval=timeInterval;
}

-(void)setRetryTime:(NSUInteger)retryTime
{
    _retryTime=retryTime;
}


- (void)setScanMode:(BOOL)isFast
{
    _scanFastSpeed = isFast;
    NSDictionary *optionsDic = @{CBCentralManagerScanOptionAllowDuplicatesKey: @(isFast)};
    
    [_refreshTimer invalidate];
    _refreshTimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshNearDevice:) userInfo:optionsDic repeats:YES];
    [_refreshTimer fire];
    
    [self.centralManager scanForPeripheralsWithServices:nil options:optionsDic];
}

- (void)setTimeOutWithPeriheral:(CBPeripheral *)periheral {
    
    _timeOutTimer = nil;
    [_timeOutTimer invalidate];
    _timeOutTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(disconnectPeriheral:) userInfo:periheral repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timeOutTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark 查询命令
- (void)queryDeviceStatus:(NSString *)deviceID
                  success:(void (^ _Nullable)(NSData *_Nullable))success
                     fail:(NSUInteger (^ _Nullable)(NSString *_Nullable))fail
{
    _sendType = SendTypeQuery;
    localSuccessReturn tempSuccess = ^(NSUInteger index ,NSData *data){
        success(data);
    };
    [self sendMutiCommandWithSingleDeviceID:deviceID sendType:_sendType commands:nil success:tempSuccess fail:fail finish:nil];
}

- (void)queryMutiDevices:(NSArray <NSString *>*_Nullable)devices
                  report:(void (^ _Nullable)(NSUInteger index,BOOL isSuccess,id _Nullable obj))report
                  finish:(void(^_Nullable)(BOOL isFinish))finish
{
    [self sendMutiCommands:nil withMutiDevices:devices withSendTypes:nil report:report finish:finish];
}


#pragma mark 发送命令

- (void)sendByteCommandWithString:(NSString *)commandStr
                         deviceID:(NSString *)deviceID
                         sendType:(SendType)sendType
                          success:(void (^)(NSData *_Nullable))success
                             fail:(NSUInteger (^)(NSString *_Nullable))fail
{
    localSuccessReturn tempSuccess = ^(NSUInteger index ,NSData *data){
        success(data);
    };
    [self sendMutiCommandWithSingleDeviceID:deviceID sendType:sendType commands:@[commandStr] success:tempSuccess fail:fail finish:nil];
}


-(void)sendMutiCommandWithSingleDeviceID:(NSString *)deviceID sendType:(SendType)sendType commands:(NSArray<__kindof NSString *> *)commands success:(localSuccessReturn)success fail:(NSUInteger (^)(NSString * _Nullable))fail finish:(void (^)(BOOL))finish

{
    //立一个小block
    //成功:返回设备序列号,如果序列号和传来的最大数量相等,n那么返回大成功
    //失败:返回设备序列号和失败代码,如果传来设备故障,那么立即返回大失败,如果返回写入失败和任何可持续写入的失败代码,继续重复发送
    __block BluetoothManager *blockManger = self;
    _dataf = [NSDate date];
    NSDate *startTime = [NSDate date];
    static NSUInteger failTime = 0;
    NSTimeInterval timeInterval=_timeInterval;
    NSUInteger retryTime = _retryTime;
    self.partSuccess = ^(NSUInteger deviceIndex, NSData *feedbackCode) {
        _isDiscoverSuccess = NO;
        _isWritingSuccess = NO;
        _isConnectingSuccess = NO;
        _isGetValueSuccess = NO;
        if (success) {
            success(deviceIndex,feedbackCode);
        }
        deviceIndex += 1;
        double time1 = [[NSDate date] timeIntervalSinceDate:startTime];
        NSLog(@"\n*******************************成功控制第%zd个,总共花费时间:%f*******************************\n", deviceIndex,time1);
        failTime = 0;
        if (deviceIndex<commands.count) {
            BOOL isLast = (deviceIndex == commands.count-1)?YES:NO;
            
            //加入时间间隔
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"\n*******************************间隔时间时间:%f*******************************\n",timeInterval);
                [NSThread sleepForTimeInterval:timeInterval];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockManger sendCommmandWithDeviceID:deviceID sendType:sendType deviceIndex:deviceIndex command:commands[deviceIndex] isLast:isLast];
                });
            });
        }
        else
        {
            _curPeripheral = nil;
            if (finish) {
                finish(YES);
            }
        }
    };
    self.partFail = ^(NSUInteger deviceIndex, NSUInteger failCode) {
        _isDiscoverSuccess = NO;
        _isWritingSuccess = NO;
        _isConnectingSuccess = NO;
        _isGetValueSuccess = NO;
        NSLog(@"\n*******************************发生错误,错误代码:%zd*******************************\n",failCode);
        
        if (failCode == 403 ||failCode == 404||failCode == 400) {
            failTime = 0 ;
            if (fail) {
                fail([NSString stringWithFormat:@"%zd",failCode]);
            }
            _curPeripheral = nil;
            if (finish) {
                finish(YES);
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
                _curPeripheral = nil;
                if (finish) {
                    finish(YES);
                }
            }
            
        }
    };
    BOOL isLast = (commands.count ==1||commands == nil)?YES:NO;
    _sendType = sendType;
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
    _stateData = nil;
    _isMannelInterrupt = NO;
    _isGetValueSuccess = NO;
    _curPeripheral = nil;

    [self.dataArr removeAllObjects];
    
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


#pragma mark 多个设备多个命令

-(void)sendMutiCommands:(NSArray<NSString *> *)commands
        withMutiDevices:(NSArray<NSString *> *)devices
          withSendTypes:(NSArray<NSNumber *> *)sendTypes
                 report:(void (^)(NSUInteger, BOOL, id _Nullable))report
                 finish:(void (^)(BOOL))finish
{
    NSAssert((commands.count == devices.count&&devices.count==sendTypes.count), @"命令,设备,发送类型数量不一致或者缺失");
    __block BluetoothManager *blockManger = self;
    static NSUInteger failTime = 0;
    _dataf = [NSDate date];
    NSUInteger retryTime = _retryTime;
    self.partSuccess = ^(NSUInteger deviceIndex, NSData *feedbackCode) {
        _isDiscoverSuccess = NO;
        _isWritingSuccess = NO;
        _isConnectingSuccess = NO;
        _isGetValueSuccess = NO;
        if (report) {
            report(deviceIndex,YES,feedbackCode);
        }
        deviceIndex += 1;
        failTime = 0;
        if (deviceIndex<commands.count) {
            SendType type = sendTypes? (SendType)sendTypes[0].integerValue:SendTypeQuery;
            [blockManger sendCommmandWithDeviceID:devices[deviceIndex] sendType:type deviceIndex:deviceIndex command:commands[deviceIndex] isLast:YES];
        }
        else
        {
            _curPeripheral = nil;
            if (finish) {
                finish(YES);
            }
        }
    };
    
    self.partFail = ^(NSUInteger deviceIndex, NSUInteger failCode) {
        _isDiscoverSuccess = NO;
        _isWritingSuccess = NO;
        _isConnectingSuccess = NO;
        _isGetValueSuccess = NO;
        NSLog(@"\n*******************************发生错误,错误代码:%zd*******************************\n",failCode);
        
        if (failCode == 403 ||failCode == 404||failCode == 400) {//代号400,手动终止
            failTime = 0 ;
            if (report) {
                report(deviceIndex,NO,@(failCode));
            }
            deviceIndex ++;
            if (failCode ==400){
                deviceIndex = commands.count;
            }
            
            if (deviceIndex<commands.count) {
                SendType type = sendTypes? (SendType)sendTypes[0].integerValue:SendTypeQuery;
                [blockManger sendCommmandWithDeviceID:devices[deviceIndex] sendType:type deviceIndex:deviceIndex command:commands[deviceIndex] isLast:YES];
                
            }
            else
            {
                _curPeripheral = nil;
                if (finish) {
                    finish(YES);
                }
            }
        }
        else {
            if (failTime < retryTime) {//情况1,出错但是最后一个  情况2:发到一半出错,断开还是不断开?
                failTime ++;
                NSLog(@"\n*******************************第%zd次重试*******************************\n",failTime);
                SendType type = sendTypes? (SendType)sendTypes[0].integerValue:SendTypeQuery;
                [blockManger sendCommmandWithDeviceID:devices[deviceIndex] sendType:type deviceIndex:deviceIndex command:commands[deviceIndex] isLast:YES];
            }
            else
            {
                failTime = 0;
                if (report) {
                    report(deviceIndex,NO,@(failCode));
                }
                deviceIndex ++;
                if (deviceIndex<commands.count) {
                    SendType type = sendTypes? (SendType)sendTypes[0].integerValue:SendTypeQuery;
                    [blockManger sendCommmandWithDeviceID:devices[deviceIndex] sendType:type deviceIndex:deviceIndex command:commands[deviceIndex] isLast:YES];
                }
                else
                {
                    _curPeripheral = nil;
                    if (finish) {
                        finish(YES);
                    }
                }
            }
            
        }
    };
    SendType type = sendTypes? (SendType)sendTypes[0].integerValue:SendTypeQuery;
    [self sendCommmandWithDeviceID:devices[0] sendType:type deviceIndex:0 command:commands[0] isLast:YES];
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

- (void)initCommandWithStr:(NSString *)commandStr UDID:(NSString *)UDID deviceIndex:(NSUInteger)deviceIndex isLast:(BOOL)isLast
{
    NSAssert(commandStr.length%3 ==0, @"命令长度不是3的倍数");
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

- (CBPeripheral *)isAvailableID:(NSString *)opeartionDeviceID {
    opeartionDeviceID = [opeartionDeviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL isAvailable = NO;
    CBPeripheral *curPeripheral;
    for (NSDictionary *perInfo in self.peripheralsInfo) {
        NSDictionary *peripheralInfo = perInfo[AdvertisementData];
        NSString *deviceIDFromAdv = [peripheralInfo[@"kCBAdvDataLocalName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (deviceIDFromAdv.length >= 7) {
            if ([deviceIDFromAdv containsString:opeartionDeviceID]) {
                curPeripheral = perInfo[Peripheral];
                isAvailable = YES;
                break;
            }
        }
    }
    _curPeripheral = isAvailable ? curPeripheral : nil;
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
            [self setScanMode:NO];
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *deviceIDFromAdv = [advertisementData[@"kCBAdvDataLocalName"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([RSSI integerValue] <= -115 ||[RSSI integerValue] == 127||
        [deviceIDFromAdv length] < 6||![self isContainSelectPreFix:deviceIDFromAdv]) {
        return;
    }
    
    NSNumber *stateCodeCurrent = [self getStateCodeCurrent:deviceIDFromAdv];
//    NSLog(@">>>>>>>%@ %@",deviceIDFromAdv,stateCodeCurrent);
    
    NSMutableDictionary *peripheralInfo = [self isContain:peripheral].mutableCopy;
    if (peripheralInfo) {
        //包括
        NSUInteger operationIndex = [self.peripheralsInfo indexOfObject:peripheralInfo];
        NSNumber *stateCodeInStore = @([peripheralInfo[@"stateCode"] integerValue]);
        peripheralInfo = @{Peripheral: peripheral, AdvertisementData: advertisementData, RSSI_VALUE: RSSI, @"stateCode": stateCodeCurrent,@"isContain":@(YES)}.mutableCopy;
        if ([stateCodeCurrent isEqualToNumber:stateCodeInStore] && ![deviceIDFromAdv containsString:@"Lock"]) {
            //含有Lock是开门状态
            if (_scanFastSpeed) {//状态相同情况下,快速扫描一样广播出去
                [[NSNotificationCenter defaultCenter]postNotificationName:BlueToothMangerDidDiscoverNewItem object:nil userInfo:peripheralInfo];
            }
        }
        else
        {//状态不同
            [[NSNotificationCenter defaultCenter] postNotificationName:BlueToothMangerDidItemChangeInfo object:nil userInfo:peripheralInfo];
            NSLogMethodArgs(@"刷新 %@  强度:%@ 原状态:%@ 现状态:%@", deviceIDFromAdv, RSSI, stateCodeInStore, stateCodeCurrent);
        }
        [self.peripheralsInfo replaceObjectAtIndex:operationIndex withObject:peripheralInfo];
    }
    else {
        //不包括
        NSDictionary *peripheralInfo = @{Peripheral: peripheral, AdvertisementData: advertisementData, RSSI_VALUE: RSSI, @"stateCode": stateCodeCurrent,@"isContain":@(NO)};
        [[NSNotificationCenter defaultCenter]postNotificationName:BlueToothMangerDidDiscoverNewItem object:nil userInfo:peripheralInfo];
        [[self mutableArrayValueForKey:@"peripheralsInfo"] addObject:peripheralInfo];//数组,观察者
    }
}

#pragma mark 设备过滤

/**
 是否包含指定前缀

 @param deviceIDFromAdv 设备完整ID
 @return <#return value description#>
 */
-(BOOL)isContainSelectPreFix:(NSString *)deviceIDFromAdv
{
    __block BOOL isSelectPreFix = NO;
    [_scaningPreFix enumerateObjectsUsingBlock:^(__kindof NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([deviceIDFromAdv hasPrefix:obj]) {
            isSelectPreFix = YES;
            *stop = YES;
        }
    }];
    return isSelectPreFix;
}

/**
 如果包括的话,返回数据,不包括的话,返回nil

 @param peripheral <#peripheral description#>
 @return <#return value description#>
 */
- (NSDictionary *)isContain:(CBPeripheral *)peripheral
{
    __block NSDictionary *infoDic = nil;
    [self.peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CBPeripheral *peripheralInStore = obj[Peripheral];
        NSString *pIdentiferInStore = peripheralInStore.identifier.UUIDString;
        NSString *pIdentiferCurrent = peripheral.identifier.UUIDString;
        if ([pIdentiferInStore isEqual:pIdentiferCurrent]) {
            *stop = YES;
            infoDic = obj;
        }
    }];
    return infoDic;
}

-(NSNumber *)getStateCodeCurrent:(NSString *)deviceIDFromAdv
{
    if (deviceIDFromAdv.length <=6) {
        return @(-1);
    }
    NSString *stateCode = [deviceIDFromAdv substringWithRange:NSMakeRange(6, 1)];
    NSString *deviceType = [deviceIDFromAdv substringWithRange:NSMakeRange(4, 2)];
    NSUInteger stateIndex = [stateCode characterAtIndex:0];
    
    if ([deviceIDFromAdv containsString:@"Lock"]) {
        return @(1);//1为开门状态
    }
    if ([stateCode isEqualToString:@":"] || [deviceIDFromAdv hasPrefix:@"WIFI"]) {
        //            stateIndex = 48;//48一个不存在的状态
        return @(-1);
    }
    if ([deviceType isEqualToString:@"00"] || [deviceType isEqualToString:@"01"]|| [deviceType isEqualToString:@"11"]|| [deviceType isEqualToString:@"21"])
    {
        return @(stateIndex & (0x01));
    }
    else if ([deviceType isEqualToString:@"02"]||[deviceType isEqualToString:@"12"]||[deviceType isEqualToString:@"22"])
    {
        return @(stateIndex & (0x03));
    }
    else {
        return @(stateIndex & (0x07));
    }
}


#pragma mark 连接回调

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    _isConnectingSuccess = YES;
    NSLog(@"Step2:连接设备成功,开始寻找服务:%f,ID:%@", time1,peripheral.name);
//    if (peripheral.services.count == 0) {
//        NSLogMethodArgs(@"设备找不到服务");
//        [self.centralManager cancelPeripheralConnection:peripheral];
//    }
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
    [peripheral discoverServices:@[uuid]];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"Step7:断开设备:%f,ID:%@", time1,peripheral.name);
    if (_isMannelInterrupt){
        if (self.partFail) {
            self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 400);
        }
        return;
    }

    if (error) {
//        if (!_stateData) {
//            if (self.partFail) {
//                self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 107);
                NSLogMethodArgs(@"异常断开连接 --- %@,ID:%@", error,peripheral.name);
//            }
//        }
    } else {
        BOOL isResponse = NO;
        if (![[NSString stringWithFormat:@"%@", _stateData] hasPrefix:@"<ef"]) {//如果有ef,证明红外伴侣未响应
            isResponse = YES;
        }
        if (_isDiscoverSuccess && _isWritingSuccess && isResponse &&_isConnectingSuccess) {
            if ((_sendType == SendTypeQuery&&!_isGetValueSuccess)) {
                if (self.partFail) {
                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 105);
                }
            }
            else
            {
                if (self.partSuccess) {
                    self.partSuccess([self returnIndexOfDeviceWithPeripheral:peripheral], _stateData);
                }
            }
            
        } else {
            if (!_isDiscoverSuccess) {//防止未发现服务提前中止造成正常连接的误报
                if (self.partFail) {//已经前面终止了
//                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 103);
                }
            } else if (!_isWritingSuccess) {
                if (self.partFail) {//重写一次就好
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 104);
                }
            } else if (!isResponse) {
                if (self.partFail) {
                    [self.centralManager cancelPeripheralConnection:peripheral];
                    self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 106);
                }
            } else if (!_isConnectingSuccess){
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
        if (self.partFail) {
            self.partFail([self returnIndexOfDeviceWithPeripheral:peripheral], 102);
        }
    }
    NSLogMethodArgs(@"连接失败 --- %@,ID:%@", error.localizedDescription,peripheral.name);
}

#pragma mark -  CBPeripheralDelegate methodes 主要是控制

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"Step3:已经发现服务 寻找特征字:%f,ID:%@", time1,peripheral.name);
//    if (peripheral.services.count == 0) {
//        NSLogMethodArgs(@"设备找不到服务");
//        [self.centralManager cancelPeripheralConnection:peripheral];
//    }
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
    NSLog(@"Step4:已经发现特征字,准备写入值:%f,ID:%@", time1,peripheral.name);
    for (CBCharacteristic *character in service.characteristics) {
        NSString *characterID = character.UUID.UUIDString;
        NSData *controlData = [self returnWithDeviceID:peripheral.identifier.UUIDString];
        if ([characterID isEqualToString:@"FFF1"] && [controlData length] == 1) {//短数据
            NSLog(@"写入1bit数据:%@",controlData);
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
        NSLog(@"Step5:写入特征字成功 等待读取特征值:%f,ID:%@", time1,peripheral.name);
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
    NSLog(@"Step6:已经获取特征值%@,操作成功 单次全程控制时间:%f,ID:%@", _stateData, time1,peripheral.name);
    BOOL isLast = [self.dataArr.firstObject[@"isLast"] boolValue];
    if (isLast) {
        [_timeOutTimer invalidate];
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    else
    {
        [_timeOutTimer invalidate];
//        if (_sendType != SendTypeRemoteNew) {
//            [self.centralManager cancelPeripheralConnection:peripheral];
//        }
        if (self.partSuccess) {
            self.partSuccess([self returnIndexOfDeviceWithPeripheral:peripheral], _stateData);
        }
    }
}

@end
