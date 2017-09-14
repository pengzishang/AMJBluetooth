//
//  RemoteObject.h
//  Smart_home
//
//  Created by pzs on 2017/9/8.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewRemote.h"


//typedef NS_ENUM(NSUInteger, RemoteDeviceType) {
//    RemoteDeviceTypeSwitch   =   0,
//    RemoteDeviceTypeCurtain  =   1,
//    RemoteDeviceTypeLock     =   2,
//};

@interface RemoteObject : NSObject

@property (nonatomic,strong,nonnull) NSString *commandCode;
@property (nonatomic,strong,nonnull) NSString *deviceID;
@property (nonatomic,strong,nonnull) NSDictionary *requestBody;
@property (nonatomic,strong,nonnull) NSString *interface;
@property (nonatomic,assign) NSUInteger deviceType;
@property (nonatomic,assign) NSUInteger objIndex;
@property (nonatomic,assign) NSUInteger failTime;



/**
 远程控制初始化控制对象

 @param command <#command description#>
 @param type <#type description#>
 @param deviceID <#deviceID description#>
 @return <#return value description#>
 */
- (instancetype _Nonnull )initWithControlCommand:(NSString *_Nonnull)command type:(NSUInteger)type deviceID:(NSString *_Nonnull)deviceID;


- (instancetype _Nonnull )init ;

@end
