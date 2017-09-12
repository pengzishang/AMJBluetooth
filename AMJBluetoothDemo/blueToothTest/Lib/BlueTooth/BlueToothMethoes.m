//
//  BlueToothMethoes.m
//  blueToothTest
//
//  Created by pzs on 2017/8/28.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "BlueToothMethoes.h"
#import "BluetoothManager.h"
#import "NSString+StringOperation.h"
@interface BlueToothMethoes()

@property(strong,nonatomic)BlueToothMethoes *manger;

@end

@implementation BlueToothMethoes




+ (BlueToothMethoes *)getInstance
{
    static BlueToothMethoes *shareInstance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[BlueToothMethoes alloc]init];
        [[NSNotificationCenter defaultCenter]addObserverForName:BlueToothMangerNotifyNewData object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSString *type =  note.userInfo[@"Type"];
            if ([type isEqualToString:@"SellMachine"]) {
                [self sellMachineNotify:note];
            }
        }];
    });
    return shareInstance;
}


#pragma mark 售货机

+ (void)sellMachineNotify:(NSNotification *)note
{
    NSString *dataString = [NSString dataToString:note.object];
    dataString = [dataString substringWithRange:NSMakeRange(10, 6)];
    NSUInteger i = [dataString ToIntWithHex];
    NSUInteger offset = 0;
    NSMutableArray *openedBox = [NSMutableArray array];
    while (i!=0) {
        if (i%2==0) {
            [openedBox addObject:@(offset+1)];
        }
        offset+=1;
        i/=2;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:SellMachineUpdataValue object:openedBox];
}

- (NSString *)sellIndexs:(NSArray<NSNumber *> * _Nonnull)goodIndexs {
    NSString *indexString = @"";
    __block NSUInteger total = 0;
    NSInteger i = pow(2, 8);
    [goodIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        total += pow(2, obj.integerValue - 1);//因为板子的序号是从1开始
    }];
    while (total>0) {
        NSString *lowest8Bit = @(total%i).stringValue;
        lowest8Bit = [lowest8Bit fullWithLengthCount:3];
        indexString =[lowest8Bit stringByAppendingString:indexString];
        total /= i;
    }
    if (indexString.length < 9) {
        indexString = [indexString fullWithLengthCount:9];
    }
    return indexString;
}

- (BOOL)isOnlineDeviceID:(NSString *)deviceID
{
    __block BOOL isOnlineDeviceID = NO;
    [[BluetoothManager getInstance].onlinePeripheralsInfo enumerateObjectsUsingBlock:^(__kindof NSDictionary<NSString *,id> * _Nonnull currentDic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *notifyDevice = currentDic[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([notifyDevice containsString:deviceID]) {
            isOnlineDeviceID = YES;
            *stop = YES;
        }
    }];
    return isOnlineDeviceID;
}

/**
 APP发送的控制指令如下：
 
 其中，Ctrl_num为随机数字，可以是一直累加，也可以随机产生，用于重发指令时区别上次操作指令；
 Ctrl_type为对应开门的类型，0x01为补货码，0x02为购买商品码，0x03为查询对应售货柜对应柜门状态，当Ctrl_type为0x03时，不管后面的Ctrl_val为何值，柜门均不会打开，售货柜会返回柜门状态给APP，其他拓展待以后添加；
 Ctrl_val为对应柜门操作，每一个BIT对应一个控制柜门，当对应位为0时，此柜门保持关闭状态，为1时表示打开此柜门；其中暂时只有17个柜子，第一个字节只用到最后一个BIT。
 保留字节为以后扩展使用。

 @param deviceID <#deviceID description#>
 @param success <#success description#>
 @param fail <#fail description#>
 */

-(void)sellMachine_initGoodsWithID:(NSString *)deviceID includeIndex:(NSArray<NSNumber *> * _Nonnull)goodIndexs success:(success _Nullable)success fail:(fail _Nullable)fail
{
    
    NSString *head = @"203237038";
    NSString *Ctrl_num = @"000";
    NSString *openType = @"001";
    NSString * indexString = [self sellIndexs:goodIndexs];
    
    NSString *instruction =  [[NSString stringWithFormat:@"%@%@%@%@",head,Ctrl_num,openType,indexString] fullWithLengthCountBehide:30];
    __block BOOL isOnlineDeviceID = [self isOnlineDeviceID:deviceID];
    if (!isOnlineDeviceID)
    {
        [[BluetoothManager getInstance]
         notifyWithID:deviceID
         success:^{
             [[BluetoothManager getInstance]
              sendByteCommandWithString:instruction deviceID:deviceID sendType:SendTypeSellMachine828
              success:^(NSData * _Nullable stateData) {
                  if (success) {
                      success(stateData);
                  }
              }
              fail:^NSUInteger(NSString * _Nullable stateCode) {
                  if (fail) {
                      fail(stateCode);
                  }
                  return 0;
              }];
         }
         fail:^(NSString * _Nullable failCode) {
             if (fail) {
                 fail(failCode);
             }
         }];
    }
    else
    {
        [[BluetoothManager getInstance]
         sendByteCommandWithString:instruction deviceID:deviceID sendType:SendTypeSellMachine828
         success:^(NSData * _Nullable stateData) {
             if (success) {
                 success(stateData);
             }
         }
         fail:^NSUInteger(NSString * _Nullable stateCode) {
             if (fail) {
                 fail(stateCode);
             }
             return 0;
         }];
    }
}


- (void)sellMachine_buyGoodWithID:(NSString * _Nonnull)deviceID goodIndex:(NSUInteger)goodIndex success:(success _Nullable )success fail:(fail _Nullable )fail;
{
    NSString *head = @"203237038";
    NSString *Ctrl_num = @"000";
    NSString *openType = @"002";
    NSArray *goodIndexs = @[@(goodIndex)];
    NSString * indexString = [self sellIndexs:goodIndexs];
    
    NSString *instruction =  [[NSString stringWithFormat:@"%@%@%@%@",head,Ctrl_num,openType,indexString] fullWithLengthCountBehide:30];
    __block BOOL isOnlineDeviceID = [self isOnlineDeviceID:deviceID];
    if (!isOnlineDeviceID)
    {
        [[BluetoothManager getInstance]
         notifyWithID:deviceID
         success:^{
             [[BluetoothManager getInstance]
              sendByteCommandWithString:instruction deviceID:deviceID sendType:SendTypeSellMachine828
              success:^(NSData * _Nullable stateData) {
                  if (success) {
                      success(stateData);
                  }
              }
              fail:^NSUInteger(NSString * _Nullable stateCode) {
                  if (fail) {
                      fail(stateCode);
                  }
                  return 0;
              }];
         }
         fail:^(NSString * _Nullable failCode) {
             if (fail) {
                 fail(failCode);
             }
         }];
    }
    else
    {
        [[BluetoothManager getInstance]
         sendByteCommandWithString:instruction deviceID:deviceID sendType:SendTypeSellMachine828
         success:^(NSData * _Nullable stateData) {
             if (success) {
                 success(stateData);
             }
         }
         fail:^NSUInteger(NSString * _Nullable stateCode) {
             if (fail) {
                 fail(stateCode);
             }
             return 0;
         }];
    }
}

-(void)sellMachine_queryWithID:(NSString *)deviceID success:(success)success fail:(fail)fail
{
    NSString *head = @"203237038";
    NSString *Ctrl_num = @"000";
    NSString *openType = @"003";
    NSString *instruction = [[NSString stringWithFormat:@"%@%@%@",head,Ctrl_num,openType] fullWithLengthCountBehide:30];
    __block BOOL isOnlineDeviceID = [self isOnlineDeviceID:deviceID];
    if (!isOnlineDeviceID)
    {
        [[BluetoothManager getInstance]
         notifyWithID:deviceID
         success:^{
             [[BluetoothManager getInstance]
              sendByteCommandWithString:instruction deviceID:deviceID sendType:SendTypeSellMachine828
              success:^(NSData * _Nullable stateData) {
                  if (success) {
                      success(stateData);
                  }
              }
              fail:^NSUInteger(NSString * _Nullable stateCode) {
                  if (fail) {
                      fail(stateCode);
                  }
                  return 0;
              }];
         }
         fail:^(NSString * _Nullable failCode) {
             if (fail) {
                 fail(failCode);
             }
         }];
    }
    else
    {
        [[BluetoothManager getInstance]
         sendByteCommandWithString:instruction deviceID:deviceID sendType:SendTypeSellMachine828
         success:^(NSData * _Nullable stateData) {
             if (success) {
                 success(stateData);
             }
         }
         fail:^NSUInteger(NSString * _Nullable stateCode) {
             if (fail) {
                 fail(stateCode);
             }
             return 0;
         }];
    }
}

@end
