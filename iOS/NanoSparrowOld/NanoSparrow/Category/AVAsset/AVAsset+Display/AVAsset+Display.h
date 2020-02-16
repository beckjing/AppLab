//
//  AVAsset+Display.h
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (Display)

- (CGSize)displaySizeWithTransfrom:(CGAffineTransform)transform;
- (CGAffineTransform)displayPreferredTransform;

@end
