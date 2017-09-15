//
//  NSString+StringOperation.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/26.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "NSString+StringOperation.h"

@implementation NSString (StringOperation)

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(NSString *)fullWithLengthCount:(NSUInteger)length;
{
    NSString *j=self;
    while (j.length<length) {
        j=[@"0" stringByAppendingString:j];
    }
    return j;
}

-(NSString *)fullWithLengthCountBehide:(NSUInteger)length
{
    NSString *j=self;
    while (j.length<length) {
        j=[j stringByAppendingString:@"0"];
    }
    return j;
}

-(NSString *(^)(NSUInteger))fullWithLengthCountBehide
{
    return ^(NSUInteger length){
        __kindof NSString* _self = (NSString*)self;
        NSString *j=@"";
        while (j.length<length) {
            j=[j stringByAppendingString:@"0"];
        }
        return [_self stringByAppendingString:j];
    };
}



/**
 //将日期转化为锁的字符串

 @param date <#date description#>
 @param isRemote <#isRemote description#>
 @return <#return value description#>
 */
+(NSString *)initWithDate:(NSDate *)date isRemote:(BOOL)isRemote
{
    NSDateFormatter *lockFormatter=[[NSDateFormatter alloc]init];
    lockFormatter.dateFormat=@"yyyyMMddHHmmss";
    NSString *dateFull=[[lockFormatter stringFromDate:date]substringFromIndex:2] ;
    NSString *dateFinal=@"";
    if (isRemote) {
        while (dateFull.length>0) {
            NSString *tempStr=[dateFull substringToIndex:2];
            tempStr=[self ToHex:tempStr.integerValue];
            dateFull=[dateFull substringFromIndex:2];
            tempStr= [tempStr fullWithLengthCount:2];
            dateFinal =[dateFinal stringByAppendingString:tempStr];
        }
    }
    else
    {//单纯把年月日各变成3位
        while (dateFull.length>0) {
            NSString *tempStr=[dateFull substringToIndex:2];
            dateFull=[dateFull substringFromIndex:2];
            NSString *tempConvert=[NSString stringWithFormat:@"%zd",tempStr.integerValue];
            tempConvert= [tempConvert fullWithLengthCount:3];
            dateFinal =[dateFinal stringByAppendingString:tempConvert];
        }
    }

    return dateFinal;
}

-(NSUInteger)ToIntWithHex
{
    NSUInteger finally = 0;
    for (NSInteger i=self.length-1; i>=0; i--) {
        NSInteger j = self.length - i-1;
        NSInteger ascllCode = [self characterAtIndex:i];
        if (ascllCode >=65&&ascllCode<=70) {//大写字母
            finally +=  (ascllCode - 65 + 10)*pow(16, j);
        }
        else if (ascllCode >=97&&ascllCode<=102)
        {
            finally +=  (ascllCode - 97 + 10)*pow(16, j);
        }
        else if (ascllCode >=48&&ascllCode<=57)
        {
            finally +=  (ascllCode - 48)*pow(16, j);
        }
    }
    return finally;
}

+ (NSString *)ToHex:(NSUInteger)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    NSUInteger ttmpig;
    for (NSUInteger i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=@(ttmpig).stringValue;
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;  
        }  
        
    }  
    return str;  
}

+(NSString *)translateDateToDay:(NSDate *)date
{
    NSDateFormatter *lockFormatter=[[NSDateFormatter alloc]init];
    lockFormatter.dateFormat=@"yyyy年MM月dd日";
    return [lockFormatter stringFromDate:date];
}

/**
 将时间转成时分秒
 
 @param date <#date description#>
 @return <#return value description#>
 */
+(NSString *)translateDateToTime:(NSDate *)date
{
    NSDateFormatter *lockFormatter=[[NSDateFormatter alloc]init];
    lockFormatter.dateFormat=@"HH点mm分ss秒";
    return [lockFormatter stringFromDate:date];
}

//讲密码转化为锁的字符串
+(NSString *)convertPassWord:(NSString *)passWord
{
    NSString *passTransform=[NSString new];
    while (passWord.length>0) {
        NSString *partofPassWord=[passWord substringToIndex:2];
        passWord =[passWord substringFromIndex:2];
        
        NSInteger H_partofPassWord=[partofPassWord substringToIndex:1].integerValue;
        NSInteger L_partofPassWord=[partofPassWord substringFromIndex:1].integerValue;
        if (H_partofPassWord==0) {
            H_partofPassWord=10;
        }
        if (L_partofPassWord==0) {
            L_partofPassWord=10;
        }
        NSUInteger partResult=L_partofPassWord+H_partofPassWord*16;
        
        NSString  *partPassWordStr=[NSString new];
        partPassWordStr=[partPassWordStr stringByAppendingString:[NSString stringWithFormat:@"%zd",partResult]];
        while (partPassWordStr.length<3) {
            partPassWordStr=[@"0" stringByAppendingString:partPassWordStr];
        }
        passTransform=[passTransform stringByAppendingString:partPassWordStr];
    }
    return passTransform;
}


/**
 顺序将MAC转BCD码
 如实际地址是1234567890ab，则此处依次填0xab 0x90 0x78 0x56 0x34 0x12 (逆序)

 @param MacID <#MacID description#>
 @return <#return value description#>
 */
+ (NSString *)convertMacID:(NSString *)MacID
{
    return [NSString convertMacID:MacID reversed:NO];
}

+ (NSString *)convertMacID:(NSString *)MacID reversed:(BOOL)isReversed
{
    NSString *passTransform=[NSString new];
    MacID=[MacID uppercaseString];
    NSAssert(MacID.length%2==0, @"MacID错误");
    while (MacID.length>0) {
        NSString *partofMacID = @"";
        if (isReversed) {//逆序
            partofMacID = [MacID substringFromIndex:MacID.length-2];
            MacID =[MacID substringToIndex:MacID.length-2];
        }
        else
        {
            partofMacID=[MacID substringToIndex:2];
            MacID =[MacID substringFromIndex:2];
        }
        

        NSString *H_part=[partofMacID substringToIndex:1];
        NSString *L_part=[partofMacID substringFromIndex:1];
        
        NSInteger H_partofMacID=H_part.integerValue;
        NSInteger L_partofMacID=L_part.integerValue;
        
        if ([H_part characterAtIndex:0]>64) {
            H_partofMacID=[H_part characterAtIndex:0]-65+10;
        }
        
        if ([L_part characterAtIndex:0]>64) {
            L_partofMacID=[L_part characterAtIndex:0]-65+10;
        }//将0替换成a 16进制
        
        NSUInteger partResult=L_partofMacID+H_partofMacID*16;
        
        NSString  *partPassWordStr=[NSString new];
        partPassWordStr=[partPassWordStr stringByAppendingString:[NSString stringWithFormat:@"%zd",partResult]];
        while (partPassWordStr.length<3) {
            partPassWordStr=[@"0" stringByAppendingString:partPassWordStr];
        }
        passTransform=[passTransform stringByAppendingString:partPassWordStr];
    }
    return passTransform;
}


+ (NSString *)ListNameWithPrefix:(NSString *)prefix
{
    __block NSString *deviceName=@"未知设备";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DeviceTypeList" ofType:@"plist"];
    NSDictionary *DeviceTypeList=[NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *dicAllKey=[NSMutableArray array];
    NSMutableArray *dicAllValue=[NSMutableArray array];
    [DeviceTypeList enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSArray *_Nonnull scanObj, BOOL * _Nonnull stop){
        if (![key isEqualToString:@"ScanTypeAll"]) {
            [dicAllKey addObjectsFromArray: [scanObj[0] allKeys]];
            [dicAllValue addObjectsFromArray:[scanObj[0] allValues]];
        }
    }];
    [dicAllKey enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([prefix hasPrefix:obj]) {
            deviceName=dicAllValue[idx];
            *stop=YES;
        }
    }];
    return deviceName;
}

+(Byte *)translateToByte:(NSString *)part
{
    NSString *string=part;
    Byte *result=(Byte *)malloc(string.length/3);
    for (NSInteger i=0; [string length]>0; i++) {
        NSString *partStr=[string substringToIndex:3];
        string=[string substringFromIndex:3];
        result[i]=(Byte)partStr.integerValue;
    }
    return result;
}

+(NSString *)translateRemoteID:(NSString *)remoteID
{
    NSMutableString *translated=[NSMutableString string];
    [remoteID enumerateSubstringsInRange:NSMakeRange(0, remoteID.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSUInteger location=substringRange.location;
        [translated appendString:[NSString stringWithFormat:@"%x",[remoteID characterAtIndex:location]]];
    }];
    
    return [NSString stringWithString:translated];
}

+(NSString *)divideCode:(NSString *)code
{
    NSString *HighBit = [NSString stringWithFormat:@"%zd", code.integerValue / 256];//高位
    HighBit = [HighBit fullWithLengthCount:3];
    NSString *LowBit = [NSString stringWithFormat:@"%zd", code.integerValue % 256];//将高位减去,剩下的低位
    LowBit = [LowBit fullWithLengthCount:3];
    return [NSString stringWithFormat:@"%@%@",HighBit,LowBit];
}

+(NSInteger)dataToInt:(NSData *)data
{
    NSString *dataStr = data.description;
    dataStr=[dataStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    dataStr=[dataStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    dataStr=[dataStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    dataStr = [NSString stringWithFormat:@"%lu",strtoul([dataStr UTF8String], 0, 16)];
    NSLog(@">>>>%@",dataStr);
    return dataStr.integerValue;
}

/**
 将data转string

 @param data <#data description#>
 @return <#return value description#>
 */
+(NSString *)dataToString:(NSData *)data
{
    NSString *dataStr = data.description;
    dataStr=[dataStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    dataStr=[dataStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    dataStr=[dataStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    return dataStr;
}
@end
