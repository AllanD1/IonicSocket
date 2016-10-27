		//
//  CountAdd.m
//  CountDemo
//
//  Created by System Administrator on 16/10/25.
//
//

#import "IonicSocket.h"
#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>

@implementation IonicSocket

- (void)SendInfo:(CDVInvokedUrlCommand *)command
{
    NSString *callBackId=command.callbackId;
    CDVPluginResult *result=nil;
    @try
    {
        NSString *host = [command.arguments objectAtIndex:0];
        NSString *port = [command.arguments objectAtIndex:1];
        NSString *message = [command.arguments objectAtIndex:2];
        
        NSArray *messages=[message componentsSeparatedByString:@";"];
        double nextTime=0;
        for (id info in messages)
        {
            if(![info isEqual:nil] && ![info isEqual:@""])
            {
                NSArray * infos=[info componentsSeparatedByString:@"@"];
                [NSThread sleepForTimeInterval:nextTime];
                [self Send:host :port :[infos objectAtIndex:0]];
                if([infos count]==2)
                {
                    nextTime = [[infos objectAtIndex:1] doubleValue];
                }
            }
        }
        result=[CDVPluginResult resultWithStatus:(CDVCommandStatus_OK)];
    }
    @catch (NSException *e)
    {
        result=[CDVPluginResult resultWithStatus:(CDVCommandStatus_ERROR) messageAsString:[e reason]];
    }
    @finally
    {
        [self.commandDelegate sendPluginResult:result callbackId:callBackId];
    }
}

-(void) Send:(NSString *)host: (NSString *) port :(NSString*) message{
    
    // 第一步：创建soket
    // TCP是基于数据流的，因此参数二使用SOCK_STREAM
    int error = -1;
    int clientSocketId = socket(AF_INET, SOCK_STREAM, 0);
    BOOL success = (clientSocketId != -1);
    struct sockaddr_in addr;
    
    // 第二步：绑定端口号
    if (success) {
        NSLog(@"client socket create success");
        // 初始化
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        
        // 指定协议簇为AF_INET，比如TCP/UDP等
        addr.sin_family = AF_INET;
        
        // 监听任何ip地址
        addr.sin_addr.s_addr = INADDR_ANY;
        error = bind(clientSocketId, (const struct sockaddr *)&addr, sizeof(addr));
        success = (error == 0);
    }
    if (success) {
        // p2p
        struct sockaddr_in peerAddr;
        memset(&peerAddr, 0, sizeof(peerAddr));
        peerAddr.sin_len = sizeof(peerAddr);
        peerAddr.sin_family = AF_INET;
        int intPort = [port intValue];
        peerAddr.sin_port = htons(intPort);
        
        // 指定服务端的ip地址，测试时，修改成对应自己服务器的ip
        peerAddr.sin_addr.s_addr = inet_addr([host UTF8String]);
        
        socklen_t addrLen;
        addrLen = sizeof(peerAddr);
        NSLog(@"will be connecting");
        
        // 第三步：连接服务器
        error = connect(clientSocketId, (struct sockaddr *)&peerAddr, addrLen);
        success = (error == 0);
        
        if (success) {
            // 第四步：获取套接字信息
            error = getsockname(clientSocketId, (struct sockaddr *)&addr, &addrLen);
            success = (error == 0);
            
            if (success) {
                NSLog(@"client connect success, local address:%s,port:%d",inet_ntoa(addr.sin_addr), ntohs(addr.sin_port));
                NSData * bytes=[self stringToByte:message];
                send(clientSocketId, [bytes bytes], [bytes length], 0);
                // 第六步：关闭套接字
                close(clientSocketId);
            }
        } else {
            NSLog(@"connect failed");
            
            // 第六步：关闭套接字
            close(clientSocketId);
        }
    }
}

-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
        int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
        return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
        int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
        int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
        return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

@end
