//
//  BluetoothManager.h
//  ttsBluetooth_iPhone
//
//  Created by tts on 14-10-10.
//  Copyright (c) 2014年 tts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


#define Peripheral         @"peripheral"
#define AdvertisementData  @"advertisementData"
#define RSSI_VALUE         @"RSSI"
#define Note_Refresh_State  @"Note_Refresh_State"//刷新
#define NSLogMethodArgs(format, ...)    NSLog(@"\n---方法:%s---\n---行号:%d\n---内容:\n%@\n ", __PRETTY_FUNCTION__, __LINE__ , [NSString stringWithFormat:format, ##__VA_ARGS__] );

#define BlueToothMangerDidDiscoverNewItem  @"BlueToothMangerDidDiscoverNewItem"
#define BlueToothMangerDidItemChangeInfo  @"BlueToothMangerDidItemChangeInfo"

/**
 控制类型方式

 - SendTypeSingle: 单个控制指令
 - SendTypeMuti: 多个控制指令
 - SendTypeSyncdevice: 同步设备状态
 - SendTypeInfrared: 控制红外设备
 - SendTypeLock: 控制锁
 - SendTypeQuery: 查询锁
 SendTypeRemote = 遥控器指令 //20个字符
 SendTypeRemoteTemp = 7
 SendTypeSellMachine 售货机
 SendTypeRemoteNew 最新无需升级硬件的对吗机
 */
typedef NS_ENUM(NSUInteger, SendType) {
    SendTypeSingle = 0,
    SendTypeMuti = 1,
    SendTypeSyncdevice = 2,
    SendTypeInfrared = 3,
    SendTypeLock = 4,
    SendTypeQuery = 5,
    SendTypeRemote = 6,
    SendTypeRemoteTemp = 7,
    SendTypeSellMachine = 8,
    SendTypeRemoteNew = 9
};


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

typedef void(^detectDevice)(NSDictionary *__nullable infoDic);

@interface BluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>


/**
 周围设备
 */
@property(strong, nonatomic, nullable , readonly) NSMutableArray <__kindof NSDictionary <NSString *,id>*> *peripheralsInfo;

/**
 初始化

 @return <#return value description#>
 */
+ (nullable BluetoothManager *)getInstance;

/**
 启用
 */
- (void)effect;

/**
 设定间隔

 @param timeInterval <#timeInterval description#>
 */
- (void)setInterval:(NSTimeInterval)timeInterval;

/**
 设定重试次数

 @param retryTime <#retryTime description#>
 */
- (void)setRetryTime:(NSUInteger)retryTime;

/**
 用这个block触发发现设备
 */
@property(copy, nonatomic, nullable) detectDevice detectDevice;//发现设备

/**
 扫描设备

 @param isAllowDuplicates NO的时候是低功耗扫描 YES为快速扫描
 @param PrefixArr 一个列表,包括设备类型的NSNumber
 */
- (void)scanPeriherals:(BOOL)isAllowDuplicates AllowPrefix:(NSArray <__kindof NSNumber *> *_Nullable)PrefixArr;


/**
 查询设备设备状态

 @param deviceID <#deviceInfo description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */


- (void)queryDeviceStatus:(nonnull NSString *)deviceID
                  success:(void (^ _Nullable)(NSData *_Nullable data))success
                     fail:(NSUInteger(^ _Nullable)(NSString * __nonnull statusCode))fail;


/**
 查询多个设备

 @param devices <#devices description#>
 @param report <#report description#>
 @param finish <#finish description#>
 */
- (void)queryMutiDevices:(NSArray <NSString *>*_Nullable)devices
                  report:(void (^ _Nullable)(NSUInteger index,BOOL isSuccess,id _Nullable obj))report
                  finish:(void(^_Nullable)(BOOL isFinish))finish;

/**
 发送单个控制指令

 @param commandStr <#commandStr description#>
 @param deviceID <#deviceID description#>
 @param sendType <#sendType description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sendByteCommandWithString:(NSString *__nonnull)commandStr
                         deviceID:(NSString *__nonnull)deviceID
                         sendType:(SendType)sendType
                          success:(void (^ _Nullable)(NSData *__nullable stateData))success
                             fail:(NSUInteger (^ _Nullable)(NSString *__nullable stateCode))fail;


/**
 向一个设备发送多个指令

 @param deviceID <#deviceID description#>
 @param sendType <#sendType description#>
 @param commands <#commands description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sendMutiCommandWithSingleDeviceID:(NSString *__nonnull)deviceID
                                 sendType:(SendType)sendType
                                 commands:(NSArray <__kindof NSString *>* _Nullable)commands
                                  success:(void (^ _Nullable)(NSData *__nullable stateData))success
                                     fail:(NSUInteger (^ _Nullable)(NSString *__nullable stateCode))fail;



/**
 控制多个设备

 @param commands <#commands description#>
 @param devices <#devices description#>
 @param report <#report description#>
 @param finish <#finish description#>
 */
- (void)sendMutiCommands:(NSArray <NSString *>*_Nullable)commands
         withMutiDevices:(NSArray <NSString *>*_Nullable)devices
           withSendTypes:(NSArray <NSNumber *>*_Nullable)sendTypes
                  report:(void (^ _Nullable)(NSUInteger index,BOOL isSuccess,id _Nullable obj))report
                  finish:(void(^_Nullable)(BOOL isFinish))finish;


@end
