//
//  ToolsFuntion.m
//  blueToothTest
//
//  Created by pzs on 2017/8/2.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "ToolsFuntion.h"
#import "NSString+StringOperation.h"
@implementation ToolsFuntion


+ (NSDictionary *)getJsonDicWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType
{
    NSString *typeString = nil;
    switch (deviceType) {
        case RemoteDeviceTV:
        {
            typeString = @"TV";
        }
            break;
        case RemoteDeviceDVD:
        {
            typeString = @"DVD";
        }
            break;
        case RemoteDeviceAUX:
        {
            typeString = @"AUX";
        }
            break;
        case RemoteDeviceSAT:
        {
            typeString = @"SAT";
        }
            break;
        default:
            break;
    }
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:typeString ofType:@"json"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:dataPath];
    NSArray <NSDictionary *>*jsonArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    __block NSUInteger dataIndex = NSUIntegerMax;
    [jsonArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"CODE_NUM"] isEqualToString:deviceIndexStr]) {
            dataIndex = idx;
            *stop = YES;
        }
    }];
    NSAssert(dataIndex != NSUIntegerMax, @"错误的设备序号");
    NSDictionary *dataDic = jsonArr[dataIndex];
    return dataDic;
}


//快速发码,0xfe,0xa8,device_num,format_num,custom_byte,use_byte,custom_data,use_data[use_byte],..................  //19个字节
//1
+ (NSString *)getFastCodeDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType keynum:(NSUInteger)keynum
{
    NSString *typeString = nil;
    NSString *device_num = nil;
    switch (deviceType) {
        case RemoteDeviceTV:
        {
            typeString = @"TV";
            device_num = @"001";
        }
            break;
        case RemoteDeviceDVD:
        {
            typeString = @"DVD";
            device_num = @"002";
        }
            break;
        case RemoteDeviceAUX:
        {
            typeString = @"AUX";
            device_num = @"003";
        }
            break;
        case RemoteDeviceSAT:
        {
            typeString = @"SAT";
            device_num = @"004";
        }
            break;
        default:
            break;
    }
    NSDictionary *dataDic = [ToolsFuntion getJsonDicWithDeviceIndex:deviceIndexStr deviceType:deviceType];
    
    NSString *custom_byte = [dataDic[@"custom_byte"] fullWithLengthCount:3];
    NSString *use_byte = [dataDic[@"use_byte"] fullWithLengthCount:3];
    NSString *format_num = [dataDic[@"format_num"] fullWithLengthCount:3];
    
    NSArray *custom_dataStr = [dataDic[@"format_num"] componentsSeparatedByString:@","];
    NSMutableArray <NSString *>*custom_data = [NSMutableArray array];
    [custom_dataStr enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [custom_data addObject:[@([obj ToIntWithHex]).stringValue fullWithLengthCount:3]];
    }];
    
    NSArray <NSString *>*use_data = [ToolsFuntion getUseDataWithDeviceIndexStr:deviceIndexStr deviceType:deviceType keynum:keynum];
    __block NSString *fastCodeStr = [NSString stringWithFormat:@"254168%@%@%@%@",device_num,format_num,custom_byte,use_byte];
    [custom_data enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        fastCodeStr = [fastCodeStr stringByAppendingString:obj];
    }];
    
    [use_data enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        fastCodeStr = [fastCodeStr stringByAppendingString:obj];
    }];
    fastCodeStr = [fastCodeStr fullWithLengthCountBehide:57];
    return fastCodeStr;
}

/**
 拼接一条供计算userdata的字串
 //快速发码,0xfe,0xa8,device_num,format_num,custom_byte,use_byte,custom_data,use_data[use_byte],..................  //19个字节
 1.0xfe,0xa8,device_num,format_num,custom_byte,use_byte,custom_data,查表去
 2.当use_byte=1,
 use_data[0] = data_table[3 + custom_byte + (key_change[device_num - 1][key_num - 1]]- 1) *1]
 如果use_byte=2.那么
 use_data[0] = data_table[3 + custom_byte + (key_change[device_num - 1][key_num - 1]]- 1) *2]
 use_data[1] = data_table[3 + custom_byte + (key_change[device_num - 1][key_num - 1]]- 1) *2+1]

 */

//3
+ (NSString *)getSelectStringWithDeviceType:(RemoteDevice)deviceType  dataDic:(NSDictionary *)dataDic
{
    NSArray <NSString *>*originOrder = nil;
    switch (deviceType) {
        case RemoteDeviceTV:{
            originOrder = @[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"电源",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"频道+",@"频道-",@"音量+",@"音量-",@"静音",@"菜单",@"UP",@"DOWN",@"RIGHT",@"LEFT",@"确认",@"退出",@"返回",@"RED",@"GREEN",@"YELLOW",@"BLUE",@"上一首",@"下一首",@"声音",@"喜爱",@"节目单",@"电视/视频",@"信号源",@"-/--",@"静相(STILL)",@"回看",@"图像",@"屏显",@"时间",@"功能",@"双画面",@"日历",@"游戏",@"SYS"];
        }
            break;
        case RemoteDeviceDVD:{
            originOrder =@[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"电源",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"音量+",@"音量-",@"菜单",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"静音",@"确认",@"返回",@"+10",@"进/出仓",@"播放",@"暂停",@"停止",@"快退",@"快进",@"上一曲",@"下一曲",@"屏显",@"制式",@"设置",@"声道",@"字幕",@"语言",@"标题",@"编程",@"缩放",@"切换",@"重复",@"角度",@"清除",@"A-B"];
        }
            break;
        case RemoteDeviceAUX:{
            originOrder = @[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"ENTER(-/--)",@"CH+",@"CH-",@"VOL+",@"VOL-",@"MUTE",@"MENU",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"OK",@"REW",@"PLAY",@"FF",@"PAUSE",@"STOP",@"RESET",@"SLEEP",@"6CH INPUT",@"声道模式",@"声场+",@"声场－"];
        }
            break;
        case RemoteDeviceSAT:{
            originOrder = @[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"VOL+",@"VOL-",@"MUTE",@"CH+",@"CH-",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"OK",@"PLAY",@"PAUSE/时移",@"REW",@"FF",@"STOP",@"上页",@"下页",@"输入法/*/状态",@"退出",@"声道",@"喜爱",@"菜单/主页",@"节目单/导视",@"电视/视讯",@"信息/#",@"设置/预订",@"点播",@"邮件/邮箱",@"返回",@"回看",@"资讯/SUB",@"指南/预告",@"帮助",@"证券/股票"];
        }
            break;
        default:
            break;
    }
    __block NSString *strSelect = @"";
    
    [originOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * temp = [dataDic[obj] stringByReplacingOccurrencesOfString:@"," withString:@""];
        strSelect = [strSelect stringByAppendingString:temp];
    }];
    
    NSLog(@"%@",strSelect);
    return strSelect;
}

//2
+ (NSArray *)getUseDataWithDeviceIndexStr:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType keynum:(NSUInteger)keynum
{
    NSUInteger device_num = (NSUInteger)deviceType;
    NSDictionary *dataDic = [ToolsFuntion getJsonDicWithDeviceIndex:deviceIndexStr deviceType:deviceType];
    
    NSUInteger custom_byte = [dataDic[@"custom_byte"] integerValue];
    NSUInteger use_byte = [dataDic[@"use_byte"] integerValue];
    static const uint8_t key_change[4][56] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,0,0,32,33,34,35,36,37,38,0,0,0,0,0,0,0,39,40,41,42,43,44,45,46,
        //tv 1  key_change
        0,1,2,0,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,0, 0,31,32,33,0,34,35,36,0,0,0,0,0,0,0,37,38,39,40,41,42,43,44,
        //dvd key_change
        0,1,2,3,4,5,0,7,0,9,10,11,12,13, 0,15,16,17,18,19,20,21,22,23,24, 0,26,27,28,29, 0,31, 0, 0,32,33,34,35,36, 0, 0,0,0,0,0,0,0,0,39,40,41,42,43,44,45,34,
        //aux key_change
        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31, 0, 0,32,33,34,35,36,37,38,0,0,0,0,0,0,0,39, 0,40,41,42,43,44,45,
        //sat key_change
    };
    uint8_t keyNumValue = key_change[device_num - 1][keynum - 1];
    NSMutableArray *use_data_array = [NSMutableArray array];
    if (use_byte == 1) {
        NSUInteger strPostion = 3 + custom_byte + (keyNumValue - 1);
        NSString *selectStr = [ToolsFuntion getSelectStringWithDeviceType:deviceType dataDic:dataDic];
        [use_data_array addObject:[selectStr substringWithRange:NSMakeRange(strPostion * 2, 2)]];
    }
    else if (use_byte == 2){
        NSUInteger strPostion = 3 + custom_byte + (keyNumValue- 1) *2 ;
        NSString *selectStr = [ToolsFuntion getSelectStringWithDeviceType:deviceType dataDic:dataDic];
        [use_data_array addObject:[selectStr substringWithRange:NSMakeRange(strPostion * 2, 2)]];
        [use_data_array addObject:[selectStr substringWithRange:NSMakeRange((strPostion +1) * 2, 2)]];
    }
    
    return use_data_array;
}

//确认码组下载



/**
 //例如：发码为tv设备，use_byte= 1，则 i =  （4 + custom_byte + 46 * use_byte）/ 17    = 3 ,//这个地方进制不清晰
 
 //例如：发码为sat设备，use_byte = 2 ，则 i = （4 + custom_byte + 45 * use_byte）/ 17 = 5

 @param custom_byte <#custom_byte description#>
 @param use_byte <#use_byte description#>
 @return <#return value description#>
 */
+(NSUInteger)getCountOfCommandWithCustom_byte:(NSUInteger)custom_byte use_byte:(NSUInteger)use_byte deviceType:(RemoteDevice)deviceType
{

    NSUInteger device_byte = 0;
    switch (deviceType) {
        case RemoteDeviceTV:
            device_byte = 46;
            break;
        case RemoteDeviceDVD:
            device_byte = 44;
            break;
        case RemoteDeviceAUX:
            device_byte = 34;
            break;
        case RemoteDeviceSAT:
            device_byte = 45;
            break;
        default:
            break;
    }
    NSUInteger i = (4 + custom_byte +device_byte * use_byte) / 17;
    return i;
}

//usedata内容,
+(NSArray <NSString *>*)getTotalStringWithJsonDic:(NSDictionary *)jsonDic deviceType:(RemoteDevice)deviceType device_num:(NSString *)device_num
{
    NSArray <NSString *>*originOrder = nil;
    switch (deviceType) {
        case RemoteDeviceTV:{
            originOrder = @[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"ENTER(-/--)",@"CH+",@"CH-",@"VOL+",@"VOL-",@"MUTE",@"MENU",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"OK",@"REW",@"PLAY",@"FF",@"PAUSE",@"STOP",@"RESET",@"SLEEP",@"6CH INPUT",@"声道模式",@"声场+",@"声场－"];
        }
            break;
        case RemoteDeviceDVD:{
            originOrder =@[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"电源",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"音量+",@"音量-",@"菜单",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"静音",@"确认",@"返回",@"+10",@"进/出仓",@"播放",@"暂停",@"停止",@"快退",@"快进",@"上一曲",@"下一曲",@"屏显",@"制式",@"设置",@"声道",@"字幕",@"语言",@"标题",@"编程",@"缩放",@"切换",@"重复",@"角度",@"清除",@"A-B"];
        }
            break;
        case RemoteDeviceAUX:{
            originOrder = @[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"ENTER(-/--)",@"CH+",@"CH-",@"VOL+",@"VOL-",@"MUTE",@"MENU",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"OK",@"REW",@"PLAY",@"FF",@"PAUSE",@"STOP",@"RESET",@"SLEEP",@"6CH INPUT",@"声道模式",@"声场+",@"声场－"];
        }
            break;
        case RemoteDeviceSAT:{
            originOrder = @[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"VOL+",@"VOL-",@"MUTE",@"CH+",@"CH-",@"UP",@"DOWN",@"LEFT",@"RIGHT",@"OK",@"PLAY",@"PAUSE/时移",@"REW",@"FF",@"STOP",@"上页",@"下页",@"输入法/*/状态",@"退出",@"声道",@"喜爱",@"菜单/主页",@"节目单/导视",@"电视/视讯",@"信息/#",@"设置/预订",@"点播",@"邮件/邮箱",@"返回",@"回看",@"资讯/SUB",@"指南/预告",@"帮助",@"证券/股票"];
        }
            break;
        default:
            break;
    }
    
    NSMutableArray *allCodeStrings = [NSMutableArray array];
    device_num = [@(device_num.integerValue).stringValue fullWithLengthCount:2];
    [allCodeStrings addObject:device_num];
    [originOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *partStr = jsonDic[obj];
        NSArray *partStrs = [partStr componentsSeparatedByString:@","];
        [allCodeStrings addObjectsFromArray:partStrs];
    }];
    
    return allCodeStrings;
    
}


/**
 下载完整数据

 @param deviceIndexStr <#deviceIndexStr description#>
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray <NSString *>*)getDownloadCodeWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType
{
    
    NSString *typeString = nil;
    NSUInteger device_num = 0;
    switch (deviceType) {
        case RemoteDeviceTV:
        {
            typeString = @"TV";
            device_num = 1;
        }
            break;
        case RemoteDeviceDVD:
        {
            typeString = @"DVD";
            device_num = 2;
        }
            break;
        case RemoteDeviceAUX:
        {
            typeString = @"AUX";
            device_num = 3;
        }
            break;
        case RemoteDeviceSAT:
        {
            typeString = @"SAT";
            device_num = 4;
        }
            break;
        default:
            break;
    }
    NSDictionary *dataDic = [ToolsFuntion getJsonDicWithDeviceIndex:deviceIndexStr deviceType:deviceType];
    NSString *device_numStr = [@(device_num).stringValue fullWithLengthCount:3];
    
    NSArray <NSString *>*totalStrings =  [ToolsFuntion getTotalStringWithJsonDic:dataDic deviceType:deviceType device_num:device_numStr];
    
    NSMutableArray *finallyCodeStrings = [NSMutableArray array];
    __block NSUInteger i=0;
    __block NSString *partString = @"254";
    [totalStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = [@([obj ToIntWithHex]).stringValue fullWithLengthCount:3];
        if (i<18) {
            i++;
        }
        else if (i == 18)
        {
            [finallyCodeStrings addObject:partString];
            partString = @"254";
            i=0;
        }
        partString = [partString stringByAppendingString:obj];
        if (idx == totalStrings.count - 1) {
            [finallyCodeStrings addObject:partString];
        }
    }];
    [finallyCodeStrings.lastObject fullWithLengthCountBehide:57];
    return finallyCodeStrings;
    
}

/**
 得到设备码组
 
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray <NSString *>*)getAllDeviceNumWithDeviceType:(RemoteDevice)deviceType
{
    NSString *typeString = nil;
    switch (deviceType) {
        case RemoteDeviceTV:
        {
            typeString = @"TV";
        }
            break;
        case RemoteDeviceDVD:
        {
            typeString = @"DVD";
        }
            break;
        case RemoteDeviceAUX:
        {
            typeString = @"AUX";
        }
            break;
        case RemoteDeviceSAT:
        {
            typeString = @"SAT";
        }
            break;
        default:
            break;
    }
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:typeString ofType:@"json"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:dataPath];
    NSArray <NSDictionary *>*jsonArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSMutableArray *dev_nums = [NSMutableArray array];
    [jsonArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dev_nums addObject: obj[@"CODE_NUM"]];
    }];
    
    return dev_nums;
    
}

@end
