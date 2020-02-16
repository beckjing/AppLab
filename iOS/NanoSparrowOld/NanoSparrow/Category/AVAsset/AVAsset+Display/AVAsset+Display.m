//
//  AVAsset+Display.m
//  NanoSparrow
//
//  Created by yuecheng on 12/18/17.
//  Copyright © 2017 nanosparrow.com. All rights reserved.
//

#import "AVAsset+Display.h"
#import "NSArray+Safe.h"

@implementation AVAsset (Display)

- (CGSize)displaySizeWithTransfrom:(CGAffineTransform)transform {
    AVAssetTrack *assetTrack = [[self tracksWithMediaType:AVMediaTypeVideo] safe_objectAtIndex:0];
    if (assetTrack) {
        CGAffineTransform finalTransform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
        CGFloat width = fabs(finalTransform.a) * assetTrack.naturalSize.width + fabs(finalTransform.c) * assetTrack.naturalSize.height;
        CGFloat height = fabs(finalTransform.b) * assetTrack.naturalSize.width + fabs(finalTransform.d) * assetTrack.naturalSize.height;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (CGAffineTransform)displayPreferredTransform {
    AVAssetTrack *assetTrack = [[self tracksWithMediaType:AVMediaTypeVideo] safe_objectAtIndex:0];
    if (assetTrack) {
        return assetTrack.preferredTransform;
    }
    return CGAffineTransformIdentity;
}

@end
