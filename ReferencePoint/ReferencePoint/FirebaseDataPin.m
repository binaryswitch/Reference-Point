//
//  FirebaseDataPin.m
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "FirebaseDataPin.h"

@implementation FirebaseDataPin


+(NSString *) randomKeyWithLength: (int) length {
    
    static const NSString * letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"description": @"desc", @"lat": @"latitude", @"lon": @"longitude"}];
}

@end
