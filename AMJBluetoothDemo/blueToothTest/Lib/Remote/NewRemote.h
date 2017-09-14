//
//  NewRemote.h
//  Smart_home
//
//  Created by 彭子上 on 2017/4/6.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "RemoteObject.h"
@class NewRemote;


@interface NewRemote : NSObject

+ (NewRemote *_Nullable)getInstance;

/**
 发送数据

 @param urlstr <#urlstr description#>
 @param interfaceStr <#interfaceStr description#>
 @param body <#body description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sendDataToServerWithUrlstr:(NSString *__nonnull)urlstr
                         interface:(NSString *__nonnull)interfaceStr
                       requestBody:(NSDictionary *_Nullable)body
                           success:(void (^ _Nullable)(NSDictionary *__nullable requestDic))success
                              fail:(void (^ _Nullable)(NSError *__nullable error))fail;


/**
 发送数据,自带URL

 @param interfaceStr <#interfaceStr description#>
 @param body <#body description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sendDataToServerWithInterface:(NSString *__nonnull)interfaceStr
                       requestBody:(NSDictionary *_Nullable)body
                           success:(void (^ _Nullable)(NSDictionary *__nullable requestDic))success
                              fail:(void (^ _Nullable)(NSError *__nullable error))fail;



/**
 远程控制接口/锁

 @param command <#command description#>
 @param deviceID <#deviceID description#>
 @param type <#type description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)remoteControlWithCommand:(NSString *__nonnull)command
                        deviceID:(NSString *__nonnull)deviceID
                      deviceType:(NSUInteger)type
                         success:(void (^ _Nullable)(id _Nullable data))success
                            fail:(void (^ _Nullable)(NSString *__nullable error))fail __attribute__((deprecated("失效的接口")));


/**
 开锁

 @param password <#password description#>
 @param endtime <#endtime description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)lockControlWithPassword:(NSString *_Nonnull)password
                        deviceID:(NSString *__nonnull)deviceID
                        endtime:(NSString *_Nonnull)endtime
                        success:(void (^ _Nullable)(id _Nullable data))success
                           fail:(void (^ _Nullable)(NSString *__nullable error))fail;

@end
