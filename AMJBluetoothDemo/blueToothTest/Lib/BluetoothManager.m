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
#import "BlueToothObject.h"

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

@interface BluetoothManager ()<BlueToothObjectDelegate> {
    BOOL _scanFastSpeed;
    NSDate *_dataf;
    NSTimer *_timeOutTimer;
    NSTimer *_refreshTimer;
    NSTimeInterval _timeInterval;
    NSUInteger _retryTime;
}

@property(copy, nonatomic, nullable) localSuccessReturn partSuccess;
@property(copy, nonatomic, nullable) localFailReturn partFail;


@property(strong, nonatomic, nonnull)CBCentralManager *centralManager;
/**
 扫描的设备种类
 */
@property(strong, nonatomic, nullable) NSMutableArray<__kindof NSString *> *scaningPreFix;
@property(strong, nonatomic, nullable , readwrite) NSMutableArray <__kindof NSDictionary <NSString *,id>*> *peripheralsInfo;
@property(strong, nonatomic, nullable , readwrite) NSMutableArray <__kindof NSDictionary <NSString *,id>*> *onlinePeripheralsInfo;
/**
 全部控制对象信息
 */
@property(strong, nonatomic, nullable) NSMutableArray <BlueToothObject *>*dataArr;
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

-(void)effect
{
    [BluetoothManager getInstance];
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
    _scaningPreFix = [NSMutableArray array];
    _dataArr = [NSMutableArray array];
    _peripheralsInfo = [NSMutableArray array];
    _onlinePeripheralsInfo = [NSMutableArray array];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    NSLogMethodArgs(@"%@", self.centralManager.isScanning?@"载入成功,开始扫描":@"正在载入");
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
    [self sortPeripheral];
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
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
    obj.isTimeOut = YES;
    [self.centralManager cancelPeripheralConnection:peripheral];
    [sender invalidate];
}

- (void)connect2Peripheral:(CBPeripheral *)cureripheral {
    cureripheral.delegate = self;
    [self setTimeOutWithPeriheral:cureripheral];
    [self.centralManager connectPeripheral:cureripheral options:nil];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"Step1:开始连接:%f  id:%@", time1, cureripheral.name);
}

#pragma mark 代理:设备命令超时

- (void)opertionTimeOut:(BlueToothObject *)obj
{
    CBPeripheral *peripheral = obj.peripheral;
    obj.isTimeOut = YES;
    [self.centralManager cancelPeripheralConnection:peripheral];
}



/**
 中断当前操作(还有问题)
 */
//- (void)interruptCurrentOpertion
//{
//    [self disconnectPeriheral:_timeOutTimer];
////    _isMannelInterrupt = YES;
//}

-(void)setInterval:(NSTimeInterval)timeInterval
{
    _timeInterval=timeInterval;
}

-(void)setRetryTime:(NSUInteger)retryTime
{
    _retryTime=retryTime;
}

-(void)sortPeripheral
{
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    NSArray *testArray = [self.peripheralsInfo sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *  _Nonnull obj1, NSDictionary *  _Nonnull obj2) {
        NSInteger rssi1 =  [obj1[RSSI_VALUE] integerValue];
        NSInteger rssi2 =  [obj2[RSSI_VALUE] integerValue];
        if (rssi1 >= rssi2) {
            return NSOrderedSame;
        }
        else
        {
            return NSOrderedDescending;
        }
    }];
    self.peripheralsInfo = [NSMutableArray arrayWithArray:testArray];
    [[NSNotificationCenter defaultCenter]postNotificationName:BlueToothMangerDidRefreshInfo object:self.peripheralsInfo];
    [lock unlock];
}

- (void)openWarning
{
}


-(void)losePeripheral
{
    
}

- (void)setScanMode:(BOOL)isFast
{
    _scanFastSpeed = isFast;
    NSDictionary *optionsDic = @{CBCentralManagerScanOptionAllowDuplicatesKey: @(isFast)};
    
    [_refreshTimer invalidate];
    _refreshTimer=[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(refreshNearDevice:) userInfo:optionsDic repeats:YES];
    [_refreshTimer fire];
    
    [self.centralManager scanForPeripheralsWithServices:nil options:optionsDic];
}

- (void)setTimeOutWithPeriheral:(CBPeripheral *)periheral {
    
    _timeOutTimer = nil;
    [_timeOutTimer invalidate];
    _timeOutTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(disconnectPeriheral:) userInfo:periheral repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timeOutTimer forMode:NSDefaultRunLoopMode];
}

- (void)notifyWithID:(NSString *)deviceID success:(void (^ _Nullable)())success fail:(void (^ _Nullable)(NSString *_Nullable))fail
{
    __block BluetoothManager *blockManger = self;
    NSUInteger retryTime = _retryTime;
    BlueToothObject *obj = [[BlueToothObject alloc]initWithDeviceID:deviceID command:nil sendType:SendTypeSellMachine828];
    obj.isLast = NO;
    obj.deviceIndex = 0 ;
    [self.dataArr removeAllObjects];
    [self.dataArr addObject:obj];
    
    self.partSuccess = ^(NSUInteger deviceIndex, NSData *feedbackCode) {
        if (success) {
            success();
        }
    };
    
    
    self.partFail = ^(NSUInteger deviceIndex, NSUInteger failCode) {
        NSLog(@"\n*******************************发生错误,错误代码:%zd*******************************\n",failCode);
        
        if (failCode == 403 ||failCode == 404||failCode == 400||failCode == 204) {
            if (fail) {
                fail([NSString stringWithFormat:@"%zd",failCode]);
            }
            blockManger.partSuccess = nil;
            blockManger.partFail = nil;
            NSLog(@"\n*******************************控制完成*******************************\n\n");
        }
        
        else {
            BlueToothObject *obj = blockManger.dataArr[deviceIndex];
            if (obj.failTime < retryTime) {//情况1,出错但是最后一个  情况2:发到一半出错,断开还是不断开?
                obj.failTime += 1 ;
                NSLog(@"\n*******************************第%zd次重试*******************************\n",obj.failTime);
                obj.isTimeOut = NO;
                [blockManger sendCommmandWithBlueToothObject:obj];
            }
            else
            {
                obj.failTime = NSUIntegerMax;
                if (fail) {
                    fail([NSString stringWithFormat:@"%zd",failCode]);
                }
                [blockManger.centralManager cancelPeripheralConnection:obj.peripheral];
                blockManger.partSuccess = nil;
                blockManger.partFail = nil;
                NSLog(@"\n*******************************控制完成*******************************\n\n");
            }
        }
};
    
    
    
    
    
    
    [self sendCommmandWithBlueToothObject:obj];
}


#pragma mark 查询命令
- (void)queryDeviceStatus:(NSString *)deviceID
                  success:(void (^ _Nullable)(NSData *_Nullable))success
                     fail:(NSUInteger (^ _Nullable)(NSString *_Nullable))fail
{
    localSuccessReturn tempSuccess = ^(NSUInteger index ,NSData *data){
        success(data);
    };
    [self sendMutiCommandWithSingleDeviceID:deviceID sendType:SendTypeQuery commands:@[@""] success:tempSuccess fail:fail finish:nil];
}

- (void)queryMutiDevices:(NSArray <NSString *>*_Nullable)devices
                  report:(void (^ _Nullable)(NSUInteger index,BOOL isSuccess,id _Nullable obj))report
                  finish:(void(^_Nullable)(BOOL isFinish))finish
{
    NSMutableArray *sendtypes = [NSMutableArray array];
    NSMutableArray *commands = [NSMutableArray array];
    for (NSUInteger i=0; i<devices.count; i++) {
        [commands addObject:@""];
        [sendtypes addObject:@(SendTypeQuery)];
    }
    [self sendMutiCommands:nil withMutiDevices:devices withSendTypes:sendtypes report:report finish:finish];
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
    commandStr = [commandStr fullWithLengthCount:3];
    [self sendMutiCommandWithSingleDeviceID:deviceID sendType:sendType commands:@[commandStr] success:tempSuccess fail:fail finish:nil];
    
}


-(void)sendMutiCommandWithSingleDeviceID:(NSString *)deviceID sendType:(SendType)sendType commands:(NSArray<__kindof NSString *> *)commands success:(localSuccessReturn)success fail:(NSUInteger (^)(NSString * _Nullable))fail finish:(void (^)(BOOL))finish
{
    __block BluetoothManager *blockManger = self;
    _dataf = [NSDate date];
    NSDate *startTime = [NSDate date];
    NSTimeInterval timeInterval=_timeInterval;
    NSUInteger retryTime = _retryTime;
    [self.dataArr removeAllObjects];
    
    self.partSuccess = ^(NSUInteger deviceIndex, NSData *feedbackCode) {
        if (success) {
            success(deviceIndex,feedbackCode);
        }
        deviceIndex = deviceIndex + 1;
        double time1 = [[NSDate date] timeIntervalSinceDate:startTime];
        NSLog(@"\n*******************************成功控制第%zd个,总共花费时间:%f*******************************", deviceIndex,time1);
        if (deviceIndex<self.dataArr.count) {
            //加入时间间隔
            BlueToothObject *obj = blockManger.dataArr[deviceIndex];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"\n*******************************间隔时间时间:%f*******************************\n",timeInterval);
                [NSThread sleepForTimeInterval:timeInterval];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockManger sendCommmandWithBlueToothObject:obj];
                });
            });
        }
        else
        {
            NSLog(@"\n*******************************控制完成*******************************\n\n");
            if (finish) {
                finish(YES);
            }
        }
    };
    self.partFail = ^(NSUInteger deviceIndex, NSUInteger failCode) {
        NSLog(@"\n*******************************发生错误,错误代码:%zd*******************************\n",failCode);
        
        if (failCode == 403 ||failCode == 404||failCode == 400||failCode == 204) {
            if (fail) {
                fail([NSString stringWithFormat:@"%zd",failCode]);
            }
            blockManger.partSuccess = nil;
            blockManger.partFail = nil;
            NSLog(@"\n*******************************控制完成*******************************\n\n");
            if (finish) {
                finish(YES);
            }
        }
        
        else {
            BlueToothObject *obj = blockManger.dataArr[deviceIndex];
            if (obj.failTime < retryTime) {//情况1,出错但是最后一个  情况2:发到一半出错,断开还是不断开?
                obj.failTime += 1 ;
                NSLog(@"\n*******************************第%zd次重试*******************************\n",obj.failTime);
                obj.isTimeOut = NO;
                [blockManger sendCommmandWithBlueToothObject:obj];
            }
            else
            {
                obj.failTime = NSUIntegerMax;
                if (fail) {
                    fail([NSString stringWithFormat:@"%zd",failCode]);
                }
                [blockManger.centralManager cancelPeripheralConnection:obj.peripheral];
                blockManger.partSuccess = nil;
                blockManger.partFail = nil;
                NSLog(@"\n*******************************控制完成*******************************\n\n");
                if (finish) {
                    finish(YES);
                    
                }
            }
        }
    };
    
    //准备命令
    if (sendType == SendTypeSellMachine828) {
        __block BOOL isOnlineDeviceID = NO;
        [self.onlinePeripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary<NSString *,id> * _Nonnull currentDic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *notifyDevice = currentDic[AdvertisementData][@"kCBAdvDataLocalName"];
            if ([notifyDevice containsString:deviceID]) {
                isOnlineDeviceID = YES;
                *stop = YES;
            }
        }];
        
        if (isOnlineDeviceID) {
            [commands enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull command, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([command isEqualToString:@""]) {
                    command = nil;
                }
                BlueToothObject *obj = [[BlueToothObject alloc]initWithDeviceID:deviceID command:command sendType:sendType isNotify:YES];
                obj.isLast = NO;
                obj.deviceIndex = idx;
                [self.dataArr addObject:obj];
            }];
            //订阅设备发送命令
        }
        else
        {//订阅一体化
            if (self.partFail) {
                self.partFail(0, 204);//未订阅设备不能发命令,弹出错误,结束
            }
        }
    }
    else
    {
        [commands enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull command, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([command isEqualToString:@""]) {
                command = nil;
            }
            BlueToothObject *obj = [[BlueToothObject alloc]initWithDeviceID:deviceID command:command sendType:sendType];
            BOOL isLast = (commands.count -1 ==idx)?YES:NO;
            obj.isLast = isLast;
            obj.deviceIndex = idx;
            [self.dataArr addObject:obj];
        }];
    }
    
    if (self.dataArr.count>0) {
        [self sendCommmandWithBlueToothObject:self.dataArr.firstObject];
    }
    
}

/**
  通用发送方法

 @param bluetoothObj <#bluetoothObj description#>
 */
#pragma mark 通用发送方法
- (void)sendCommmandWithBlueToothObject:(BlueToothObject *)bluetoothObj
{

    NSAssert(bluetoothObj.command.length % 3 == 0, @"命令位数不是3的倍数");
    NSLog(@"\n*******************************第%zd个设备(命令)*******************************\n",bluetoothObj.deviceIndex + 1);
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        if (self.partFail) {
            self.partFail(bluetoothObj.deviceIndex, 403);
        }
    }
    CBPeripheral *curPeripheral = bluetoothObj.peripheral;

    if (curPeripheral) {
//        bluetoothObj.delegate = self;
//        [bluetoothObj startRunningTime];
        [self connect2Peripheral:curPeripheral];
        
    } else {
        if (self.partFail) {
            self.partFail(bluetoothObj.deviceIndex, 404);
        }
    }

}


#pragma mark 多个设备多个命令
//对于包含一个设备多个指令,这种情况还有BUG
-(void)sendMutiCommands:(NSArray<NSString *> *)commands
        withMutiDevices:(NSArray<NSString *> *)devices
          withSendTypes:(NSArray<NSNumber *> *)sendTypes
                 report:(void (^)(NSUInteger, BOOL, id _Nullable))report
                 finish:(void (^)(BOOL))finish
{
    NSAssert((commands.count == devices.count&&devices.count==sendTypes.count), @"命令,设备,发送类型数量不一致或者缺失");
    __block BluetoothManager *blockManger = self;
    _dataf = [NSDate date];
    NSUInteger retryTime = _retryTime;
    [self.dataArr removeAllObjects];
    [commands enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull command, NSUInteger idx, BOOL * _Nonnull stop) {
        BlueToothObject *obj = [[BlueToothObject alloc]initWithDeviceID:devices[idx] command:command sendType:(SendType)sendTypes[idx].integerValue];
        obj.isLast = YES;
        obj.deviceIndex = idx;
        [self.dataArr addObject:obj];
    }];

    
    self.partSuccess = ^(NSUInteger deviceIndex, NSData *feedbackCode) {
        if (report) {
            report(deviceIndex,YES,feedbackCode);
        }
        deviceIndex += 1;
        
        if (deviceIndex<commands.count) {
            BlueToothObject *obj = blockManger.dataArr[deviceIndex];
            [blockManger sendCommmandWithBlueToothObject:obj];
        }
        else
        {
            blockManger.partSuccess = nil;
            blockManger.partFail = nil;
            NSLog(@"\n*******************************控制完成*******************************\n");
            if (finish) {
                finish(YES);
            }
        }
    };
    
    self.partFail = ^(NSUInteger deviceIndex, NSUInteger failCode) {
        NSLog(@"\n*******************************发生错误,错误代码:%zd*******************************\n",failCode);
        BlueToothObject *obj = blockManger.dataArr[deviceIndex];
        if (failCode == 403 ||failCode == 404||failCode == 400) {//代号400,手动终止
            
            obj.failTime = NSUIntegerMax;
            if (report) {
                report(deviceIndex,NO,@(failCode));
            }
            deviceIndex ++;
            if (deviceIndex<commands.count) {
                BlueToothObject *objCurrent = blockManger.dataArr[deviceIndex];
                [blockManger sendCommmandWithBlueToothObject:objCurrent];
            }
            else
            {
                blockManger.partSuccess = nil;
                blockManger.partFail = nil;
                NSLog(@"\n*******************************控制完成*******************************\n");
                if (finish) {
                    finish(YES);
                }
            }
        }
        else {
            if (obj.failTime < retryTime) {//情况1,出错但是最后一个  情况2:发到一半出错,断开还是不断开?
                obj.failTime ++;
                NSLog(@"\n*******************************第%zd次重试*******************************\n",obj.failTime);
                [blockManger sendCommmandWithBlueToothObject:obj];
            }
            else
            {
                obj.failTime = NSUIntegerMax;
                if (report) {
                    report(deviceIndex,NO,@(failCode));
                }
                deviceIndex ++;
                
                if (deviceIndex<commands.count) {
                    BlueToothObject *objCurrent = blockManger.dataArr[deviceIndex];
                    [blockManger sendCommmandWithBlueToothObject:objCurrent];
                }
                else
                {
                    blockManger.partSuccess = nil;
                    blockManger.partFail = nil;
                    NSLog(@"\n*******************************控制完成*******************************\n");
                    if (finish) {
                        finish(YES);
                    }
                }
            }
            
        }
    };
    if (self.dataArr.count>0) {
        [self sendCommmandWithBlueToothObject:self.dataArr.firstObject];
    }
}


#pragma mark 多线程版 多个命令多个设备

//-(void)GCDSendMutiCommands:(NSArray<NSString *> *)commands
//        withMutiDevices:(NSArray<NSString *> *)devices
//          withSendTypes:(NSArray<NSNumber *> *)sendTypes
//                 report:(void (^)(NSUInteger, BOOL, id _Nullable))report
//                 finish:(void (^)(BOOL))finish

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


#pragma mark -  CBPeripheralDelegate methodes 主要是控制

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"Step3:已经发现服务 寻找特征字:%f,ID:%@", time1,peripheral.name);
    for (CBService *service in peripheral.services) {
        NSString *serviceID = service.UUID.UUIDString;
        if ([serviceID isEqualToString:obj.seviceID]) {
            CBUUID * characterID = [CBUUID UUIDWithString:obj.characterID];
            NSArray *characteristics = @[characterID];
            [peripheral discoverCharacteristics:characteristics forService:service];
            break;
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
    obj.isDiscoverSuccess = YES;
    //订阅服务在此有所区别
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    NSLog(@"Step4:已经发现特征字,准备写入值:%f,ID:%@", time1,peripheral.name);
    for (CBCharacteristic *character in service.characteristics) {
        NSString *characterID = character.UUID.UUIDString;
        if (![characterID isEqualToString:obj.characterID]) {
            continue;
        }
        NSData *controlData = obj.commandData;
        obj.isWritingSuccess = YES;
        if (obj.sendType ==SendTypeSellMachine828)
        {
            if (obj.isNotifySuccess) {
                NSLog(@"订阅模式写入%zdbit长数据Data:%@", controlData.length,controlData);
                [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
                obj.isGetValueSuccess = YES;
                obj.isMarkedDevice = YES;
                [_timeOutTimer invalidate];//写成功再结束,这里要改
            }
            else
            {//没订阅成功就订阅
                [peripheral setNotifyValue:YES forCharacteristic:character];
            }
        }
        else
        {
            if ([controlData length] == 1) {//短数据
                NSLog(@"普通写入1bit数据:%@",controlData);
                [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithResponse];
                break;
            }
            else if ([controlData length] == 10||[controlData length] == 20||[controlData length] == 19) {
                //进行长数据写入
                    NSLog(@"普通模式写入%zdbit长数据Data:%@", controlData.length,controlData);
                    [peripheral writeValue:controlData forCharacteristic:character type:CBCharacteristicWriteWithResponse];
            }
            else if(!controlData){
                NSLog(@"进行查询数据");
                [peripheral readValueForCharacteristic:character];
            }
        }
        break;
    }
}


- (BlueToothObject *)returnWithPeripheral:(CBPeripheral *)peripheral
{
    __block BlueToothObject *item  = nil;
    [self.dataArr enumerateObjectsUsingBlock:^(BlueToothObject  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isMarkedDevice) {
            *stop = YES;
            item = obj;
        }
        else if ([obj.peripheral isEqual:peripheral]) {
            if (obj.sendType == SendTypeSellMachine828&&!obj.isNotifySuccess) {
                *stop = YES;
                item = obj;
            }
            else if(!obj.isGetValueSuccess&&obj.failTime!=NSUIntegerMax){
                *stop = YES;
                item = obj;
            }
        }
    }];
    return item;
}



- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        [peripheral readValueForCharacteristic:characteristic];
        double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
        NSLog(@"Step5:写入特征字成功 等待回调:%f,ID:%@", time1,peripheral.name);
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
    //正常控制完成
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
        obj.stateCode = characteristic.value;
    NSLog(@"收到新的信息:%@",obj.stateCode);
    if (error) {
        NSLog(@"捕捉到错误:%@",error);
    }
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];

    if (obj.sendType == SendTypeSellMachine828) {
        [[NSNotificationCenter defaultCenter]postNotificationName:BlueToothMangerNotifyNewData object:characteristic.value userInfo:@{@"Type":@"SellMachine"}];
        if (self.partSuccess) {
            self.partSuccess(obj.deviceIndex, obj.stateCode);
        }
    }
    else
    {
        if (obj.stateCode) {
            obj.isGetValueSuccess = YES;
            NSLog(@"Step6:已经获取特征值%@,操作成功 单次全程控制时间:%f,ID:%@", obj.stateCode, time1,peripheral.name);
        }
        //    [obj stopRunningTime];
        [_timeOutTimer invalidate];
        
        if (obj.isLast) {
            obj.isMarkedDevice = YES;
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
        
        if (self.partSuccess) {
            self.partSuccess(obj.deviceIndex, obj.stateCode);
        }
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
    obj.isGetValueSuccess = YES;
    if (!error) {
        [_timeOutTimer invalidate];//连接时钟停止计时
        obj.isNotifySuccess = YES;
        __block BOOL isContain = NO;
        [self.onlinePeripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary<NSString *,id> * _Nonnull onlineObj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *deviceID = onlineObj[AdvertisementData][@"kCBAdvDataLocalName"];
            if ([deviceID isEqualToString:obj.deviceID]) {
                isContain = YES;
                *stop = YES;
            }
        }];
        if (!isContain) {
            [self.peripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary<NSString *,id> * _Nonnull currentDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *deviceID = currentDic[AdvertisementData][@"kCBAdvDataLocalName"];
                if ([deviceID isEqualToString:obj.deviceID]) {
                    [self.onlinePeripheralsInfo addObject:currentDic];
                    *stop = YES;
                }
            }];
        }
        if (self.partSuccess) {
            self.partSuccess(obj.deviceIndex, nil);
        }
        NSLog(@"成功订阅!控制字:%@",obj.characterID);
    }
    else
    {
        NSLog(@"订阅时候发生错误:%@",error);//错误201
        [_timeOutTimer invalidate];
        obj.isMarkedDevice = YES;
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
}


#pragma mark 连接回调

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
    obj.isConnectingSuccess = YES;
    NSLog(@"Step2:连接设备成功,开始寻找服务:%f,ID:%@", time1,peripheral.name);
    CBUUID *uuid = [CBUUID UUIDWithString:obj.seviceID];
    [peripheral discoverServices:@[uuid]];
}



- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    double time1 = [[NSDate date] timeIntervalSinceDate:_dataf];
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
    obj.delegate = nil;
    if (error) {
        if (obj.sendType == SendTypeSellMachine828) {//从在线设备中删除
            obj.isNotifySuccess = NO;
            [self.onlinePeripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary<NSString *,id> * _Nonnull onlineObj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *deviceID = onlineObj[AdvertisementData][@"kCBAdvDataLocalName"];
                if ([deviceID isEqualToString:obj.deviceID]) {
                    [self.onlinePeripheralsInfo removeObject:onlineObj];
                    *stop = YES;
                }
            }];
        }
        if (!obj.isGetValueSuccess) {
            if (self.partFail) {
                self.partFail(obj.deviceIndex, 102);
            }
        }
        NSLogMethodArgs(@"异常断开连接 --- %@,ID:%@", error,peripheral.name);
    }
    else {//有隐藏错误的时候才进来
        NSLog(@"正在断开设备:%f,ID:%@", time1,peripheral.name);
        BOOL isResponse = NO;
        if (![[NSString stringWithFormat:@"%@", obj.stateCode] hasPrefix:@"<ef"]) {//如果有ef,证明红外伴侣未响应
            isResponse = YES;
        }
        if (obj.isTimeOut)
        {
            NSLog(@"超时");
            if (self.partFail) {//超时
                self.partFail(obj.deviceIndex, 101);
            }
        } else if (!obj.isWritingSuccess) {
            if (self.partFail) {//重写一次就好
                self.partFail(obj.deviceIndex, 104);
            }
        } else if (!obj.isDiscoverSuccess) {//防止未发现服务提前中止造成正常连接的误报
            if (self.partFail) {//已经前面终止了
                self.partFail(obj.deviceIndex, 103);
            }
        } else if (!isResponse) {
            if (self.partFail) {
                [self.centralManager cancelPeripheralConnection:peripheral];
                self.partFail(obj.deviceIndex, 106);
            }
        } else if (!obj.isConnectingSuccess){
            if (self.partFail) {
                self.partFail(obj.deviceIndex, 102);
            }
        } else if (!obj.isGetValueSuccess){
            if (self.partFail) {
                self.partFail(obj.deviceIndex, 105);
            }
        } else if (obj.sendType == SendTypeSellMachine828&&!obj.isNotifySuccess){
            if (self.partFail) {
                self.partFail(obj.deviceIndex, 201);//订阅失败
            }
        }
    }
    obj.isMarkedDevice = NO;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BlueToothObject *obj = [self returnWithPeripheral:peripheral];
//    [obj stopRunningTime];
    if (error) {
        NSLogMethodArgs(@"连接失败 --- %@,ID:%@", error.localizedDescription,peripheral.name);
        if (self.partFail) {
            self.partFail(obj.deviceIndex, 102);
        }
    }
    else
    {
        NSLogMethodArgs(@"无错误的102");
    }
}


-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
{
    NSLog(@"willRestoreState");
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(10_9, 6_0)
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(10_9, 7_0)
{
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(10_7, 10_13, 5_0, 8_0)
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(10_13, 8_0)
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral
{
    
}
@end
