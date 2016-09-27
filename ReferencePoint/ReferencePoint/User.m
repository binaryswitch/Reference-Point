//
//  User.m
//  ReferencePoint
//
//  Created by Justin White on 25/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "User.h"

@implementation User

// Specify default values for properties

+ (NSString *)primaryKey {
    return @"email";
}

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
