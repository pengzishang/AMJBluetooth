//
//  BlueToothMethoes.h
//  blueToothTest
//
//  Created by pzs on 2017/8/28.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BlueToothMethoes;
typedef void (^success)(NSData *_Nullable data);
typedef void (^fail)(NSString * __nonnull statusCode);

//NSString * _Nonnull const SellMachineUpdataValue = @"SellMachineUpdataValue";
#define SellMachineUpdataValue @"SellMachineUpdataValue"
@interface BlueToothMethoes : NSObject




+ (BlueToothMethoes * _Nonnull)getInstance;


/**
 补货

 @param deviceID <#deviceID description#>
 @param goodIndexs <#goodIndexs description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sellMachine_initGoodsWithID:(NSString * _Nonnull)deviceID includeIndex:(NSArray <NSNumber *> *_Nonnull)goodIndexs success:(success _Nullable )success fail:(fail _Nullable )fail;




/**
 买东西

 @param deviceID <#deviceID description#>
 @param goodIndex <#goodIndex description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sellMachine_buyGoodWithID:(NSString * _Nonnull)deviceID goodIndex:(NSUInteger)goodIndex success:(success _Nullable )success fail:(fail _Nullable )fail;


/**
 查询货

 @param deviceID <#deviceID description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */
- (void)sellMachine_queryWithID:(NSString * _Nonnull)deviceID success:(success _Nullable )success fail:(fail _Nullable )fail;


@end
