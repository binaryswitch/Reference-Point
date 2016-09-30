//
//  UIView+CommonPlace.h
//  ReferencePoint
//
//  Created by Justin White on 1/10/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CommonPlace)

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

@property (nonatomic, readonly) CGFloat left;
@property (nonatomic, readonly) CGFloat right;
@property (nonatomic, readonly) CGFloat top;
@property (nonatomic, readonly) CGFloat bottom;

-(instancetype)initInView: (UIView* _Nonnull)view;
-(instancetype)initWithFrame: (CGRect)frame inView: (UIView* _Nonnull)view;

NS_ASSUME_NONNULL_END

@end
