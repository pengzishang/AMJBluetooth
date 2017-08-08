//
//  NSString+StringOperation.h
//  Smart_home
//
//  Created by 彭子上 on 2016/7/26.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringOperation)

@property (nonatomic,copy,readonly) NSString*        (^fullWithLengthCountBehide)(NSUInteger length);

/**
 *  将字符往首位填0至指定位数
 *
 *  @param length <#length description#>
 *
 *  @return <#return value description#>
 */
-(NSString *)fullWithLengthCount:(NSUInteger)length;

/**
 在后面填充字符0

 @param length <#length description#>

 @return <#return value description#>
 */
-(NSString *)fullWithLengthCountBehide:(NSUInteger)length;



/**
  转成10进制

 @param hexStr <#hexStr description#>
 @return <#return value description#>
 */
-(NSUInteger)ToIntWithHex;




/**
 转16进制

 @param tmpid <#tmpid description#>
 @return <#return value description#>
 */
+(NSString *)ToHex:(NSUInteger)tmpid;

/**
 转化时间为锁指定字符串
 
 @param date     <#date description#>
 @param isRemote <#isRemote description#>
 
 @return <#return value description#>
 */

+(NSString *)initWithDate:(NSDate *)date isRemote:(BOOL)isRemote;



/**
 将时间转成日期

 @param date <#date description#>
 @return <#return value description#>
 */
+(NSString *)translateDateToDay:(NSDate *)date;

/**
 将时间转成时分秒

 @param date <#date description#>
 @return <#return value description#>
 */
+(NSString *)translateDateToTime:(NSDate *)date;

+(NSString *)convertPassWord:(NSString *)passWord;
/**
 顺序将MAC转BCD码
 
 @param MacID <#MacID description#>
 @return <#return value description#>
 */
+(NSString *)convertMacID:(NSString *)MacID;

+(NSString *)convertMacID:(NSString *)MacID reversed:(BOOL)isReversed;

+(NSString *)ListNameWithPrefix:(NSString *)prefix;

+(Byte *)translateToByte:(NSString *)part;

+(NSString *)translateRemoteID:(NSString *)remoteID;

+(NSString *)divideCode:(NSString *)code;

+(NSInteger)dataToInt:(NSData *)data;

+(NSString *)dataToString:(NSData *)data;

@end
