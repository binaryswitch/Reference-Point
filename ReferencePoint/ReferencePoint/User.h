//
//  User.h
//  ReferencePoint
//
//  Created by Justin White on 25/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <Realm/Realm.h>

@interface User : RLMObject

@property (nonatomic) NSString * email;

@end

RLM_ARRAY_TYPE(User)
