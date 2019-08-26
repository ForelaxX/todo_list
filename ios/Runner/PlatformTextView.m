//
//  PlatformTextView.m
//  Runner
//
//  Created by Forelax on 2019/8/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "PlatformTextView.h"

@interface PlatformTextView ()

@property (strong, nonatomic) UILabel *textView;
@property (assign, nonatomic) int64_t viewId;

@end

@implementation PlatformTextView

-(instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    if (self = [super init]) {
        _textView = [[UILabel alloc] initWithFrame:frame];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.text = args;
        _viewId = viewId;
    }
    return self;
}

- (nonnull UIView *)view {
    return self.textView;
}


@end
