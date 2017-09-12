//
//  BlueToothObject.h
//  blueToothTest
//
//  Created by pzs on 2017/8/15.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothManager.h"
@class BlueToothObject;


@protocol BlueToothObjectDelegate <NSObject>

@required

- (void)opertionTimeOut:(BlueToothObject *_Nonnull)obj;

@end

@interface BlueToothObject : NSObject
/**
 每一个字典里面应该包含 当前设备控制的
 BOOL _isDiscoverSuccess;
 BOOL _isWritingSuccess;
 BOOL _isConnectingSuccess;
 BOOL _isGetValueSuccess;
 SendType _sendType;
 NSTimer *_timeOutTimer;
 失败次数
 设备序号
 设备对象
 */

@property (nonatomic,assign)BOOL isDiscoverSuccess;

@property (nonatomic,assign)BOOL isWritingSuccess;

@property (nonatomic,assign)BOOL isConnectingSuccess;

@property (nonatomic,assign)BOOL isGetValueSuccess;

@property (nonatomic,assign)BOOL isTimeOut;

@property (nonatomic,assign)BOOL isControlSuccess;

/**
 是否是本设备最后一个指令
 */
@property (nonatomic,assign)BOOL isLast;


/**
 用来标记断开的设备
 */
@property (nonatomic,assign)BOOL isMarkedDevice;

/**
 订阅设备
 */
@property (nonatomic,assign)BOOL isNotifySuccess;

@property (nonatomic,assign)SendType sendType;

@property (nonatomic,assign)NSUInteger failTime;

@property (nonatomic,assign)NSUInteger deviceIndex;

@property (nonatomic,nullable,strong)NSTimer * timeOutTimer;

@property (nonatomic,nonnull,strong)CBPeripheral *peripheral;

@property (nonatomic,nullable,strong)NSData *stateCode;

@property (nonatomic,nullable,strong)NSString *failCode;

@property (nonatomic,nullable,strong)NSString *command;

@property (nonatomic,nullable,strong)NSData *commandData;

@property (nonatomic,nonnull,strong)NSString *deviceID;

@property (nonatomic,nonnull,strong)NSString *UUID;

@property (nonatomic,nonnull,strong)NSString *seviceID;

@property (nonatomic,nonnull,strong)NSString *characterID;

@property (nonatomic,weak,nullable)id <BlueToothObjectDelegate> delegate;

- (instancetype _Nonnull )initWithDeviceID:(NSString *_Nonnull)deviceID command:(NSString *_Nullable)command sendType:(SendType)sendType;

- (instancetype _Nonnull )initWithDeviceID:(NSString *_Nonnull)deviceID command:(NSString *_Nullable)command sendType:(SendType)sendType isNotify:(BOOL)isNotify;

- (void)startRunningTime;

- (void)stopRunningTime;


@end
