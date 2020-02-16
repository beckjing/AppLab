//
//  NASWebSocketManager.m
//  NanoSparrow
//
//  Created by yuecheng on 12/7/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "NASWebSocketManager.h"

@interface NASWebSocketManager()

@property (nonatomic, strong) NASWebSocketRequest *request;
@property (nonatomic,   weak) id<SRWebSocketDelegate> delegate;
@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation NASWebSocketManager

- (instancetype)initWithRequest:(NASWebSocketRequest *)request
                       delegate:(id<SRWebSocketDelegate>)delegate {
    self = [super init];
    if (self) {
        _request = request;
        _delegate = delegate;
    }
    return self;
}

- (void)connect {
    
}

- (void)close {
    self.webSocket.delegate = nil;
    [self.webSocket close];
}

- (BOOL)sendData:(id)data {
    return NO;
}


@end
