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


#pragma mark 共有方法

+ (void)openErrorAlertWithTarget:(UIViewController *)target errorCode:(NSString *)errorCode
{
    NSDictionary *errDic = @{@"403":@"蓝牙未开启",@"404":@"设备没有广播或者不在附近",@"101":@"设备连接超时断开",@"102":@"断开时候发生异常",@"103":@"设备服务列表加载失败",@"104":@"命令写入失败",@"105":@"设备没有获得反馈值",@"106":@"红外设备回应失败"};
    NSString *note = [NSString stringWithFormat:@"错误代码:%@\n%@",errorCode,errDic[errorCode]] ;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:note preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [target presentViewController:alert animated:YES completion:nil];
}

+ (NSString *)getTypeString:(RemoteDevice)deviceType {
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
    return typeString;
}

+ (NSString *)getDeviceNum:(RemoteDevice)deviceType {
    return [@((NSUInteger)deviceType+1).stringValue fullWithLengthCount:3];
}

/**
 得到一条编码顺序
 
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray<NSString *> *)getOriginOrder:(RemoteDevice)deviceType
{
    
    NSString *typeString =  [self getTypeString:deviceType];
    NSDictionary *titleList = @{
                                @"TV":@[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"电源",@"频道-",@"音量-",@"静相(STILL)",@"双画面",@"YELLOW",@"回看",@"菜单",@"1",@"4",@"7",@"0",@"节目单",@"静音",@"LEFT",@"DOWN",@"2",@"5",@"8",@"返回",@"RED",@"UP",@"确认",@"退出",@"3",@"6",@"9",@"BLUE",@"电视/视频",@"时间",@"RIGHT",@"频道+",@"音量+",@"喜爱",@"信号源",@"屏显",@"SYS",@"GREEN",@"日历",@"功能",@"图像",@"声音",@"游戏",@"-/--",@"下一首",@"上一首"],
                                @"DVD":@[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"电源",@"音量-",@"A-B",@"语言",@"暂停",@"重复",@"菜单",@"1",@"4",@"7",@"0",@"角度",@"静音",@"LEFT",@"DOWN",@"2",@"5",@"8",@"返回",@"快退",@"UP",@"确认",@"清除",@"3",@"6",@"9",@"快进",@"切换",@"停止",@"RIGHT",@"音量+",@"字幕",@"缩放",@"屏显",@"进/出仓",@"播放",@"标题",@"设置",@"制式",@"声道",@"编程",@"+10",@"下一曲",@"上一曲"],
                                @"AUX":@[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"CH-",@"VOL-",@"6CH INPUT",@"PAUSE",@"MENU",@"1",@"4",@"7",@"0",@"MUTE",@"LEFT",@"DOWN",@"2",@"5",@"8",@"RESET",@"REW",@"UP",@"OK",@"3",@"6",@"9",@"FF",@"STOP",@"RIGHT",@"CH+",@"VOL+",@"PLAY",@"SLEEP",@"声道模式",@"ENTER(-/--)",@"声场+",@"声场－"],
                                @"SAT":@[@"format_num",@"custom_byte",@"use_byte",@"custom_data",@"POWER",@"CH-",@"VOL-",@"输入法/*/状态",@"指南/预告",@"PAUSE/时移",@"回看",@"菜单/主页",@"1",@"4",@"7",@"0",@"节目单/导视",@"MUTE",@"LEFT",@"DOWN",@"2",@"5",@"8",@"返回",@"REW",@"UP",@"OK",@"退出",@"3",@"6",@"9",@"FF",@"电视/视讯",@"STOP",@"RIGHT",@"CH+",@"VOL+",@"喜爱",@"点播",@"资讯/SUB",@"PLAY",@"证券/股票",@"设置/预订",@"帮助",@"声道",@"邮件/邮箱",@"信息/#",@"下页",@"上页"]
                                };
    return titleList[typeString];
}


/**
 得到功能序号
 
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray<NSString *> *)getfuntionOrder:(RemoteDevice)deviceType
{
    NSString *typeString =  [self getTypeString:deviceType];
    NSDictionary *funOrderList = @{
                                   @"TV":@[@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56"],
                                   @"DVD":@[@"2",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"36",@"37",@"38",@"39",@"40",@"41",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56"],
                                   @"AUX":@[@"2",@"3",@"4",@"5",@"7",@"9",@"10",@"11",@"12",@"13",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"26",@"27",@"28",@"29",@"31",@"32",@"35",@"36",@"41",@"50",@"52",@"54",@"55",@"56"],
                                   @"SAT":@[@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"35",@"36",@"37",@"38",@"39",@"41",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56"]};
    return funOrderList[typeString];
}


/**
 得到所有本设备的码组
 
 @param deviceType <#deviceType description#>
 @return <#return value description#>
 */
+ (NSArray <NSString *>*)getAllDeviceNumWithDeviceType:(RemoteDevice)deviceType
{
    NSString * typeString = [self getTypeString:deviceType];
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:typeString ofType:@"json"];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:dataPath];
    NSArray <NSDictionary *>*jsonArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSMutableArray *dev_nums = [NSMutableArray array];
    [jsonArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dev_nums addObject: obj[@"CODE_NUM"]];
    }];
    
    return dev_nums;
    
}

+ (NSDictionary *)getJsonDicWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType
{
    NSString *typeString = [self getTypeString:deviceType];
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


#pragma mark 快速发码

//快速发码,0xfe,0xa8,device_num,format_num,custom_byte,use_byte,custom_data,use_data[use_byte],..................  //19个字节
//1
+ (NSString *)getFastCodeDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType keynum:(NSUInteger)keynum
{
    NSString * device_num = [self getDeviceNum:deviceType];
    NSDictionary *dataDic = [ToolsFuntion getJsonDicWithDeviceIndex:deviceIndexStr deviceType:deviceType];
    
    NSString *custom_byte = [dataDic[@"custom_byte"] fullWithLengthCount:3];
    NSString *use_byte = [dataDic[@"use_byte"] fullWithLengthCount:3];
//    NSString *format_num = [dataDic[@"format_num"] fullWithLengthCount:3] ;
    NSString *format_num = [[@([dataDic[@"format_num"] ToIntWithHex]) stringValue] fullWithLengthCount:3];

    NSArray *custom_dataStr = [dataDic[@"custom_data"] componentsSeparatedByString:@","];
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
        obj = [[@([obj ToIntWithHex]) stringValue] fullWithLengthCount:3];
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
+ (NSString *)getSelectStringWithDeviceType:(RemoteDevice)deviceType  dataDic:(NSDictionary *)dataDic use_byte:(NSUInteger)use_byte
{
    NSArray<NSString *> * originOrder = [self getOriginOrder:deviceType];
    __block NSString *strSelect = @"";
    
    [originOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * temp = [dataDic[obj] stringByReplacingOccurrencesOfString:@"," withString:@""];
        if (use_byte == 2&& idx>3&&[temp isEqualToString: @"FF"]) {
            temp =@"FFFF";
        }
        strSelect = [strSelect stringByAppendingString:temp];
    }];
    
//    NSLog(@"%@",strSelect);
    return strSelect;
}

//2
+ (NSArray *)getUseDataWithDeviceIndexStr:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType keynum:(NSUInteger)keynum
{
    NSDictionary *dataDic = [ToolsFuntion getJsonDicWithDeviceIndex:deviceIndexStr deviceType:deviceType];
    
    NSUInteger custom_byte = [dataDic[@"custom_byte"] integerValue];
    NSUInteger use_byte = [dataDic[@"use_byte"] integerValue];
    NSArray *keyNumValues = nil;
    switch (deviceType) {
        case RemoteDeviceTV:
        {
            keyNumValues = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"0",@"0",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46"];
        }
            break;
        case RemoteDeviceDVD:
        {
            keyNumValues = @[@"0",@"1",@"2",@"0",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"0",@"0",@"31",@"32",@"33",@"0",@"34",@"35",@"36",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44"];
        }
            break;
        case RemoteDeviceAUX:
        {
            keyNumValues = @[@"0",@"1",@"2",@"3",@"4",@"0",@"5",@"0",@"6",@"7",@"8",@"9",@"10",@"0",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"0",@"21",@"22",@"23",@"24",@"0",@"25",@"26",@"0",@"0",@"27",@"28",@"0",@"0",@"0",@"0",@"29",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"30",@"0",@"31",@"0",@"32",@"33",@"34"];
        }
            break;
        case RemoteDeviceSAT:
        {
            keyNumValues = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"0",@"0",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"39",@"0",@"40",@"41",@"42",@"43",@"44",@"45"];
        }
            break;
        default:
            break;
    }

    NSUInteger keyNumValue = [keyNumValues[keynum - 1] integerValue];
    NSMutableArray *use_data_array = [NSMutableArray array];
    NSUInteger strPostion = 3 + custom_byte + (keyNumValue - 1)*use_byte;
    NSString *selectStr = [ToolsFuntion getSelectStringWithDeviceType:deviceType dataDic:dataDic use_byte:use_byte];
    if (use_byte == 1) {
        [use_data_array addObject:[selectStr substringWithRange:NSMakeRange(strPostion * 2, 2)]];
    }
    else if (use_byte == 2){
        [use_data_array addObject:[selectStr substringWithRange:NSMakeRange(strPostion * 2, 2)]];
        [use_data_array addObject:[selectStr substringWithRange:NSMakeRange((strPostion +1) * 2, 2)]];
    }
    
    return use_data_array;
}


#pragma mark 下载完整码组

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
    if ((4 + custom_byte +device_byte * use_byte) % 17 >0) {
        i +=1;
    }
    return i;
}

//usedata内容
+(NSArray <NSString *>*)getTotalStringWithJsonDic:(NSDictionary *)jsonDic deviceType:(RemoteDevice)deviceType device_num:(NSString *)device_num
{
    NSArray <NSString *>*originOrder = [self getOriginOrder:deviceType];;
    NSMutableArray *allCodeStrings = [NSMutableArray array];
    device_num = [@(device_num.integerValue).stringValue fullWithLengthCount:3];
    [allCodeStrings addObject:device_num];
    [originOrder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *partStr = jsonDic[obj];
        NSArray *partStrs = [partStr componentsSeparatedByString:@","];
        [partStrs enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj = [@([obj ToIntWithHex]).stringValue fullWithLengthCount:3];
            [allCodeStrings addObject:obj];
        }];
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

    NSDictionary *dataDic = [ToolsFuntion getJsonDicWithDeviceIndex:deviceIndexStr deviceType:deviceType];
    NSString *device_num = [self getDeviceNum:deviceType];
    
    NSArray <NSString *>*totalStrings =  [ToolsFuntion getTotalStringWithJsonDic:dataDic deviceType:deviceType device_num:device_num];
    NSMutableArray *finallyCodeStrings = [NSMutableArray array];
    __block NSUInteger i=0;
    
    NSInteger custom_byte = [dataDic[@"custom_byte"] integerValue];
    NSInteger use_byte = [dataDic[@"use_byte"] integerValue];
    //总组数
    __block NSInteger d = [ToolsFuntion getCountOfCommandWithCustom_byte:custom_byte use_byte:use_byte deviceType:deviceType] - 1;
    __block NSString *partString = [@"254" stringByAppendingString:[[@(d+208) stringValue] fullWithLengthCount:3]];
    [totalStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (i<17) {
            i++;
        }
        else if (i == 17)
        {
            [finallyCodeStrings addObject:partString];
            d-=1;
            NSAssert(d>=0, @"d值有误");
            partString = [@"254" stringByAppendingString:[[@(d+208) stringValue] fullWithLengthCount:3]];
            i=1;
        }
        partString = [partString stringByAppendingString:obj];
        if (idx == totalStrings.count - 1) {
            [finallyCodeStrings addObject:partString];
        }
    }];
    NSString *temp =[finallyCodeStrings.lastObject fullWithLengthCountBehide:57];
    [finallyCodeStrings removeLastObject];
    [finallyCodeStrings addObject:temp];
    return finallyCodeStrings;
}

#pragma mark 喜爱频道

+ (NSString *)getFavoriteCodeWithDeviceIndex:(NSString *)deviceIndexStr deviceType:(RemoteDevice)deviceType channelIndex:(NSString *)channel
{
    NSString *prefix = @"254";
    NSString *mode_num = @"161";
    NSString *dev_num = [self getDeviceNum:deviceType];
    NSUInteger highBit =[@(channel.integerValue/100).stringValue ToIntWithHex];
    NSString *highBitStr = [@(highBit).stringValue fullWithLengthCount:3];
    NSUInteger lowBit =[@(channel.integerValue%100).stringValue ToIntWithHex];
    NSString *lowBitString =[@(lowBit).stringValue fullWithLengthCount:3];
    
    NSUInteger highDeviceIndexBit =[@(deviceIndexStr.integerValue/100).stringValue ToIntWithHex];
    NSString *highDeviceIndexBitStr = [@(highDeviceIndexBit).stringValue fullWithLengthCount:3];
    NSUInteger lowDeviceIndexBit =[@(deviceIndexStr.integerValue%100).stringValue ToIntWithHex];
    NSString *lowDeviceIndexBitString =[@(lowDeviceIndexBit).stringValue fullWithLengthCount:3];
    
    return [[NSString stringWithFormat:@"%@%@%@%@%@%@%@",prefix,mode_num,dev_num,highDeviceIndexBitStr,lowDeviceIndexBitString,highBitStr,lowBitString] fullWithLengthCountBehide:57];
    
}

#pragma mark 锁

/**
 查询电池电量

 @return <#return value description#>
 */
+ (NSString *)queryBatteryPowerCode
{
    return [@"018" fullWithLengthCountBehide:30];
}


/**
 查询开门时间和方式记录

 @return <#return value description#>
 */
+ (NSString *)queryOpenTimeCode
{
    return [@"019" fullWithLengthCountBehide:30];
}



/**
 F>电子锁失效定时启动
 
 
 cmd： 0x14
 nop：0x00 0x00 0x00 0x00 0x00 0x00
 val：0xA1 0xB2 0xC3
 启动卡启动电子锁内部定时器，90天之后客户未付款，失效功能启动，电子锁进入失效状态，客户付款后用启动卡清除失效功能，电子锁功能正常，同时第二次启动失效功能90天计时。
 未到90天，客户第一次付款，可以用启动命令再次启动一次，过90天之后，客户第二次未付款，电子锁进入失效状态。

 @return <#return value description#>
 */
+ (NSString *)lockFailureStart
{
    return [[@"020" fullWithLengthCountBehide:21] stringByAppendingString:@"161178195"];
}


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
+ (NSString *)lockSetHotelID:(NSUInteger)hotelID buildID:(NSUInteger)buildID floorID:(NSUInteger)floorID
{
    NSString *hotelIDStr = [@(hotelID).stringValue fullWithLengthCount:3];
    NSString *buildIDStr = [@(buildID).stringValue fullWithLengthCount:3];
    NSString *floorIDStr = [@(floorID).stringValue fullWithLengthCount:3];
    return [[@"022"fullWithLengthCountBehide:21] stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",hotelIDStr,buildIDStr,floorIDStr]];
}

/**
 I>电子锁房间标识随机数（普通房卡ID）设置
 
 cmd： 0x18
 nop：0x00 0x00 0x00 0x00 0x00 0x00 0x00, 保留
 val：普通房卡ID2字节， 0x0000~0xffff，电子锁普通房卡ID的出厂默认值设为0x0000，
 普通房卡ID由发卡系统设置、更新，电子锁保存，开锁验证使用

 @param cardID <#cardID description#>
 @return <#return value description#>
 */
+ (NSString *)roomIdentifySetWithCardID:(NSUInteger)cardID
{
    NSString *cardIDStr = [NSString ToHex:cardID];
    cardID = [cardIDStr ToIntWithHex];
    cardIDStr = [@(cardID).stringValue fullWithLengthCountBehide:6];
    return [[@"024" fullWithLengthCountBehide:24] stringByAppendingString:cardIDStr];
}


/**
电子锁系统时间查询命令

 @return <#return value description#>
 */
+ (NSString *)querySYSTimeCode
{
    return [@"025" fullWithLengthCountBehide:30];
}


/**
 K>电子锁入住时间查询命令
 
 
 cmd： 0x21
 nop：0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00； 保留

 @return <#return value description#>
 */
+ (NSString *)queryCheckInTimeCode
{
    return [@"033" fullWithLengthCountBehide:30];
}


/**
 L>电子锁退房时间查询命令
 
 cmd： 0x22
 nop：0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00； 保留

 @return <#return value description#>
 */
+ (NSString *)queryCheckOutTimeCode
{
    return [@"034" fullWithLengthCountBehide:30];
}


/**
 2-2、电子门牌
 通知入住信息：
 
 Cmd:0x17
 Cio: 0x01——已入住
 0x00——已退房

 @param isCheckOut <#isCheckOut description#>
 @return <#return value description#>
 */
+ (NSString *)doorplateInfoCodeIsCheck:(BOOL)isCheckOut
{
    NSString *isCheckString = isCheckOut?@"001":@"000";
    return [[@"023" stringByAppendingString:isCheckString] fullWithLengthCountBehide:30];
}


/**
 查询电量

 @param date <#date description#>
 @return <#return value description#>
 */
//+ (NSString *)BatteryPower:(NSDate *)date
//{
//    NSString *dateString =  [NSString initWithDate:date isRemote:NO];
//#warning wws
//    return [@"008001" stringByAppendingString:dateString];
//}






@end
