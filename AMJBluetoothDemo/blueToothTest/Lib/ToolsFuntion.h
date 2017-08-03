//
//  ToolsFuntion.h
//  blueToothTest
//
//  Created by pzs on 2017/8/2.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RemoteDevice) {
    RemoteDeviceTV      =   0,
    RemoteDeviceDVD,
    RemoteDeviceAUX,
    RemoteDeviceSAT,
};

@interface ToolsFuntion : NSObject

//搞清楚远程控制的全过程

/**
 得到快速发码的命令字符串

 @param deviceIndexStr <#deviceIndexStr description#>
 @param deviceType <#deviceType description#>
 @param keynum <#keynum description#>
 @return <#return value description#>
 */
+ (NSString *)getFastCodeDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType keynum:(NSUInteger)keynum;


/**
 下载完整数据

 @param deviceIndexStr <#deviceIndexStr description#>
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray <NSString *>*)getDownloadCodeWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType;


/**
 得到相应设备的字典

 @param deviceIndexStr <#deviceIndexStr description#>
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSDictionary *)getJsonDicWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType;


/**
 得到设备码组

 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray <NSString *>*)getAllDeviceNumWithDeviceType:(RemoteDevice)deviceType;
@end
