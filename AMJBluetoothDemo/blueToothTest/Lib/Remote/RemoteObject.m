//
//  RemoteObject.m
//  Smart_home
//
//  Created by pzs on 2017/9/8.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "RemoteObject.h"
#import "NSString+StringOperation.h"
@implementation RemoteObject

//设备deviceType判断
/*
 21  窗帘
 22  空调
 23  电视         对应type为SendTypeInfrared
 
 10  房灯
 11  房灯1
 12  房灯2
 13  房灯3
 14  廊灯1/2/3    对应type为SendTypeSingle
 
 24  门锁         对应type为SendTypeLock
 */
-(instancetype)initWithControlCommand:(NSString *)command type:(NSUInteger)type deviceID:(NSString * _Nonnull)deviceID
{
    self = [super init];
    if (self) {
        self.deviceType = type;
        self.deviceID = deviceID;
        self.commandCode = [self getCommandCode:command];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    return self;
}


- (NSString *)getCommandCode:(NSString *)command
{
    NSUInteger commandCode = command.integerValue;
    if (self.deviceType == 21) {
        commandCode-=24;
    }
    else if(self.deviceType == 24) {
        
    }
    NSString * commandCodeStr = [@(commandCode).stringValue fullWithLengthCount:2];
    NSString * commandData =[NSString stringWithFormat:@"FA07%@01%@", self.deviceID, commandCodeStr] ;//取反
    return commandData;
}

@end
