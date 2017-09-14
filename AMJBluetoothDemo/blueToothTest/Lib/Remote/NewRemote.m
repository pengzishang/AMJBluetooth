//
//  NewRemote.m
//  Smart_home
//
//  Created by 彭子上 on 2017/4/6.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "NewRemote.h"
#import "NSString+StringOperation.h"

typedef void(^localSuccessReturn)(NSUInteger deviceIndex,NSString *feedbackCode);

typedef void(^localFailReturn)(NSUInteger deviceIndex,NSString * failCode);

@interface NewRemote()

@property(copy, nonatomic, nullable) localSuccessReturn partSuccess;
@property(copy, nonatomic, nullable) localFailReturn partFail;
@property(strong, nonatomic, nonnull) NSMutableArray *dataArray;
@property(strong, nonatomic, nonnull) NSTimer *timeoutTimer;
@property(assign, nonatomic) NSUInteger thresholdValue;//超时阈值

@end

@implementation NewRemote

-(NSMutableArray *)dataArray
{
    if (_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

+ (NewRemote *)getInstance
{
    static NewRemote *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[NewRemote alloc]init];
    });
    return shareInstance;
}


-(void)sendDataToServerWithInterface:(NSString *)interfaceStr requestBody:(NSDictionary *)body success:(void (^)(NSDictionary * _Nullable))success fail:(void (^)(NSError * _Nullable))fail
{
    NSString *urlStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"servicesURL"];
    if (!urlStr) {
        urlStr = @"http://120.24.223.86/PMSWebService/services/";//默认正式服
    }
    NSString *url = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@?wsdl", interfaceStr]];
    [self sendDataToServerWithUrlstr:url interface:interfaceStr requestBody:body success:success fail:fail];
}


- (void)sendDataToServerWithUrlstr:(NSString *)urlstr interface:(NSString *)interfaceStr requestBody:(NSDictionary *)body success:(void (^ _Nullable)(NSDictionary *_Nullable))success fail:(void (^ _Nullable)(NSError *_Nullable))fail {
    
    NSString *url = [urlstr stringByAppendingString:[NSString stringWithFormat:@"%@?wsdl", interfaceStr]];
    NSString *requestStr = [self makeRequestStrWithBody:body interface:interfaceStr];
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    session.requestSerializer.timeoutInterval = 3.0;
    //得到头信息
    [session.requestSerializer setQueryStringSerializationWithBlock:
     ^NSString * _Nonnull(NSURLRequest *
                          _Nonnull request, id _Nonnull parameters, NSError
                          * _Nullable __autoreleasing *
                          _Nullable error) {
         return requestStr;
     }];
    
    __block NSDictionary *dict = [NSDictionary dictionary];
    [session POST:url parameters:requestStr progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        //成功解析则回调成功信息        //正则解析
        dict = [self translateFromData:responseObject];
        if (success) {
            success(dict);
        }
    }     failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        if (fail) {
            NSLog(@"错误原因:%@", error.description);
            fail(error);
        }
    }];
}

/**
 *  从接口名获取回应请求体
 *
 *  @param body          <#body description#>
 *  @param interfaceName <#interfaceName description#>
 *
 *  @return 回复请求体
 */
- (NSString *)makeRequestStrWithBody:(NSDictionary *)body interface:(NSString *)interfaceName {
    NSString *headStr = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><%@ xmlns=\"http://wwdog.org/\">";
    __block NSString *resUrl = [NSString stringWithFormat:headStr, interfaceName];
    
    [body enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        NSString *subStr = [NSString stringWithFormat:@"<%@>%@</%@>", key, obj, key];
        resUrl = [resUrl stringByAppendingString:subStr];
    }];
    
    resUrl = [resUrl stringByAppendingString:[NSString stringWithFormat:@"</%@></soap:Body></soap:Envelope>", interfaceName]];
    
    return resUrl;
}

//正则解析字符串  系统解析JSON

- (NSDictionary *)translateFromData:(NSData *)responseObject {
    NSString *resp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSRegularExpression *result = [[NSRegularExpression alloc] initWithPattern:@"(?<=return\\>).*(?=</return)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    __block NSDictionary *dict = [NSDictionary dictionary];
    NSArray *resultArr = [result matchesInString:resp options:0 range:NSMakeRange(0, resp.length)];
    [resultArr enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull checkingResult, NSUInteger idx, BOOL *_Nonnull stop) {
        
        dict = [NSJSONSerialization JSONObjectWithData:[[resp substringWithRange:checkingResult.range] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        
    }];
    return dict;
}


//远程控制
- (void)remoteControlWithCommand:(NSString *__nonnull)command deviceID:(NSString *__nonnull)deviceID
                      deviceType:(NSUInteger)type
                         success:(void (^ _Nullable)(id _Nullable data))success
                            fail:(void (^ _Nullable)(NSString *__nullable error))fail;
{
    RemoteObject *obj = [[RemoteObject alloc]initWithControlCommand:command type:type deviceID:deviceID];
    obj.requestBody = @{@"cmds": obj.commandCode};
    obj.interface = @"InsertTDevicetrol";
    obj.objIndex = 0;
    
    [self resultWithRemoteObj:obj fail:fail success:success];
    [self generalRemoteWithRemoteObj:obj];
}


- (void)lockControlWithPassword:(NSString *)password deviceID:(NSString *)deviceID endtime:(NSString *)endtime success:(void (^)(id _Nullable))success fail:(void (^)(NSString * _Nullable))fail
{
    RemoteObject *obj = [[RemoteObject alloc]initWithControlCommand:password type:24 deviceID:deviceID];
    obj.requestBody = @{@"cmd": @"24",@"cmdContent":password,@"time":endtime};
    obj.interface = @"InsertDevicetrol";
    obj.objIndex = 0;
    
    [self resultWithRemoteObj:obj fail:fail success:success];
    [self generalRemoteWithRemoteObj:obj];
}

/**
 通用Block
 
 @param obj <#obj description#>
 @param fail <#fail description#>
 @param success <#success description#>
 */
- (void)resultWithRemoteObj:(RemoteObject *)obj
                       fail:(void (^ _Nullable)(NSString * _Nullable))fail
                    success:(void (^ _Nullable)(id _Nullable))success {
    NSDictionary *errorDic = @{@"404":@"服务器或者本地网络故障",@"403":@"服务器返回错误",@"302":@"超时未返回数据",@"301":@"未配置对应的远程控制器/控制器没有心跳"};
    __weak NewRemote *weakself = self;
    self.partSuccess = ^(NSUInteger deviceIndex, NSString *feedbackCode) {
        if (success) {
            NSLog(@"远程控制器成功发送命令,请确认控制结果");
            success(@"远程控制器成功发送命令");
        }
    };
    self.partFail = ^(NSUInteger deviceIndex, NSString *failCode) {
        if ([failCode isEqualToString:@"404"]||[failCode isEqualToString:@"301"]) {
            obj.failTime = 3;
        }
        if (obj.failTime >=3) {
            if (fail) {
                if (errorDic[failCode]) {
                    NSLog(@"%@",errorDic[failCode]);
                    fail(errorDic[failCode]);
                }
                else{
                    fail(@"未知错误");
                }
            }
        }
        else
        {
            obj.failTime ++ ;
            [weakself generalRemoteWithRemoteObj:obj];
        }
    };
}



//通用发送

- (void)generalRemoteWithRemoteObj:(RemoteObject *)obj
{
    [self sendDataToServerWithInterface:obj.interface
                            requestBody:obj.requestBody
                                success:^(NSDictionary * _Nullable requestDic)
    {
        if ([obj.interface isEqualToString:@"InsertTDevicetrol"]) {
            [self interface_InsertTDevicetrol:requestDic remoteObject:obj];
        }
        else if ([obj.interface isEqualToString:@"InsertDevicetrol"]) {//两个不一样的
             [self interface_InsertDevicetrol:requestDic remoteObject:obj];
        }
        else if ([obj.interface isEqualToString:@"SelcetDeviceStatus"]) {
            [self interface_SelcetDeviceStatus:requestDic remoteObject:obj];
        }
    }
                                   fail:^(NSError * _Nullable error)
    {
        if (self.partFail) {//未连接网络
            self.partFail(obj.objIndex, @"404");
        }
    }];
}

//老版本远程控制的接口
- (void)interface_InsertTDevicetrol:(NSDictionary *)requestDic remoteObject:(RemoteObject *)obj
{
    if ([requestDic[@"Status"] isEqualToString:@"0"] && [requestDic[@"resultType"] isEqualToString:@"OK"]) {
        //开始刷新状态
        [self init_Interface_SelcetDeviceStatus:obj];
    }
    else
    {
        if (self.partFail) {//未到达服务器
            self.partFail(obj.objIndex, @"403");
        }
    }
}

//新版本远程控制的接口
- (void)interface_InsertDevicetrol:(NSDictionary *)requestDic remoteObject:(RemoteObject *)obj
{
    if ([requestDic[@"Status"] isEqualToString:@"0"] && [requestDic[@"resultType"] isEqualToString:@"OK"]) {
        //开始刷新状态
        [self init_Interface_SelcetDeviceStatus:obj];
    }
    else
    {
        if (self.partFail) {//未到达服务器
            self.partFail(obj.objIndex, @"403");
        }
    }
}



/**
 准备刷新接口

 @param obj <#obj description#>
 */
- (void)init_Interface_SelcetDeviceStatus:(RemoteObject *)obj
{
    obj.interface = @"SelcetDeviceStatus";
    obj.requestBody = @{@"deviceAddress": obj.deviceID};
    //设立时钟
    _thresholdValue = 0;
    _timeoutTimer  = [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self generalRemoteWithRemoteObj:obj];
    }];
    [_timeoutTimer fire];
}

- (void)interface_SelcetDeviceStatus:(NSDictionary *)requestDic remoteObject:(RemoteObject *)obj
{
    if ([requestDic[@"Status"] isEqualToString:@"02"]) {
        //成功
        [_timeoutTimer invalidate];
        if (self.partSuccess) {
            self.partSuccess(obj.objIndex, requestDic[@"resultType"]);
        }
        
    }else if ([requestDic[@"Status"] isEqualToString:@"00"]||[requestDic[@"Status"] isEqualToString:@"01"]) {
        _thresholdValue ++;
        if (_thresholdValue >5) {//大于两秒
            [_timeoutTimer invalidate];
            if (self.partFail) {
                self.partFail(obj.objIndex, @"302");//超时
            }
        }
        //继续等待回应
    }else if ([requestDic[@"Status"] isEqualToString:@"0-1"]) {
        [_timeoutTimer invalidate];
        if (self.partFail) {
            self.partFail(obj.objIndex, @"301");//状态:未配置对应的远程控制器/控制器没有心跳
        }
    }else
    {
        NSLog(@"%@",requestDic[@"Status"]);
        [_timeoutTimer invalidate];
        if (self.partFail) {
            self.partFail(obj.objIndex, requestDic[@"Status"]);//状态:未配置对应的远程控制器/控制器没有心跳
        }
    }
}



@end
