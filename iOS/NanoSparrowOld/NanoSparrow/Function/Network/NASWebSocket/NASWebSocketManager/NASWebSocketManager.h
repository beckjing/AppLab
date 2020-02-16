//
//  NASWebSocketManager.h
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>
#import "NASWebSocketRequest.h"

@interface NASWebSocketManager : NSObject

- (instancetype)initWithRequest:(NASWebSocketRequest *)request
                       delegate:(id<SRWebSocketDelegate>)delegate;
- (void)connect;
- (void)close;
- (BOOL)sendData:(id)data;

@end
