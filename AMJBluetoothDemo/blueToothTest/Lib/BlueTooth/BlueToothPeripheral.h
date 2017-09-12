//
//  BlueToothPeripheral.h
//  blueToothTest
//
//  Created by pzs on 2017/8/29.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlueToothPeripheral : NSObject


/**
 初始化
 
 @return <#return value description#>
 */
+ (nullable BlueToothPeripheral *)getInstance;

- (void)effect;

- (void)startAdvise;

@end
