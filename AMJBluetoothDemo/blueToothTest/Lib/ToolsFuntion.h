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
 得到喜爱频道码组

 @param deviceIndexStr <#deviceIndexStr description#>
 @param deviceType <#deviceType description#>
 @param channel <#channel description#>
 @return <#return value description#>
 */

+ (NSString *)getFavoriteCodeWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType channelIndex:(NSString *)channel;

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


/**
 查询电池电量
 
 @return <#return value description#>
 */
+ (NSString *)queryBatteryPowerCode;

/**
 查询开门时间和方式记录
 
 @return <#return value description#>
 */

+ (NSString *)queryOpenTimeCode;

/**
 F>电子锁失效定时启动
 
 
 cmd： 0x14
 nop：0x00 0x00 0x00 0x00 0x00 0x00
 val：0xA1 0xB2 0xC3
 启动卡启动电子锁内部定时器，90天之后客户未付款，失效功能启动，电子锁进入失效状态，客户付款后用启动卡清除失效功能，电子锁功能正常，同时第二次启动失效功能90天计时。
 未到90天，客户第一次付款，可以用启动命令再次启动一次，过90天之后，客户第二次未付款，电子锁进入失效状态。
 
 @return <#return value description#>
 */

+ (NSString *)lockFailureStart;


/**
 H>电子锁酒店ID、楼栋号、楼层号设置
 
 
 cmd： 0x16
 nop：0x00 0x00 0x00 0x00 0x00 0x00, 保留
 val：酒店ID 1字节 0x01~0xff，楼栋号1字节 0x01~0xff，楼层号1字节 0x01~0xff，3个字节中有一个字节为0x00则无效
 楼栋卡的级别由发卡系统设置、升级，电子锁保存，开锁验证使用
 
 @param hotelID <#hotelID description#>
 @param buildID <#buildID description#>
 @param floorID <#floorID description#>
 @return <#return value description#>
 */

+ (NSString *)lockSetHotelID:(NSUInteger)hotelID buildID:(NSUInteger)buildID floorID:(NSUInteger)floorID;


/**
 I>电子锁房间标识随机数（普通房卡ID）设置
 
 cmd： 0x18
 nop：0x00 0x00 0x00 0x00 0x00 0x00 0x00, 保留
 val：普通房卡ID2字节， 0x0000~0xffff，电子锁普通房卡ID的出厂默认值设为0x0000，
 普通房卡ID由发卡系统设置、更新，电子锁保存，开锁验证使用
 
 @param cardID <#cardID description#>
 @return <#return value description#>
 */

+ (NSString *)roomIdentifySetWithCardID:(NSUInteger)cardID;


/**
 电子锁系统时间查询命令
 
 @return <#return value description#>
 */

+ (NSString *)querySYSTimeCode;

/**
 K>电子锁入住时间查询命令
 
 
 cmd： 0x21
 nop：0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00； 保留
 
 @return <#return value description#>
 */

+ (NSString *)queryCheckInTimeCode;

/**
 L>电子锁退房时间查询命令
 
 cmd： 0x22
 nop：0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00； 保留
 
 @return <#return value description#>
 */

+ (NSString *)queryCheckOutTimeCode;


/**
 2-2、电子门牌
 通知入住信息：
 
 Cmd:0x17
 Cio: 0x01——已入住
 0x00——已退房
 
 @param isCheckOut <#isCheckOut description#>
 @return <#return value description#>
 */

+ (NSString *)doorplateInfoCodeIsCheck:(BOOL)isCheckOut;

@end
