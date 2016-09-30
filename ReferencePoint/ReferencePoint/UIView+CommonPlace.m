//
//  UIView+CommonPlace.m
//  ReferencePoint
//
//  Created by Justin White on 1/10/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "UIView+CommonPlace.h"

@implementation UIView (CommonPlace)

- (CGFloat)width {
    return self.bounds.size.width;
}

-(CGFloat)height {
    return self.bounds.size.height;
}

- (CGFloat)left{
    return self.frame.origin.x;
}

- (CGFloat)right{
    return self.frame.origin.x + self.width;
}

- (CGFloat)top{
    return self.frame.origin.y;
}

- (CGFloat)bottom{
    return self.frame.origin.y + self.height;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

-(instancetype)initInView: (UIView* _Nonnull)view{
    self = [super init];
    
    if (self){
        [view addSubview:self];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame inView: (UIView* _Nonnull)view{
    self = [self initWithFrame:frame];
    
    if (self){
        [view addSubview:self];
    }
    
    return self;
}

#pragma clang diagnostic pop

@end
