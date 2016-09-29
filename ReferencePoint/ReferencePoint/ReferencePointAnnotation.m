//
//  ReferencePointAnnotation.m
//  ReferencePoint
//
//  Created by Justin White on 29/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "ReferencePointAnnotation.h"

@interface ReferencePointAnnotation ()

@property (nonatomic, strong) FirebaseDataPin * pinReference;

@end

@implementation ReferencePointAnnotation

- (instancetype)initWithFirebasePinData: (FirebaseDataPin *) pin {
    
    self = [super init];
    
    if (self){
        self.pinReference = pin;
    }
    
    return self;
}

- (NSString *) getReferencedFirebaseId{
    return self.pinReference.firebaseId;
}

@end
