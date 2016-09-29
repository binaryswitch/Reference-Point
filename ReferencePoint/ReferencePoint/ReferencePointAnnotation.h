//
//  ReferencePointAnnotation.h
//  ReferencePoint
//
//  Created by Justin White on 29/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FirebaseUserDataModelResponse.h"

@interface ReferencePointAnnotation : MKPointAnnotation

- (instancetype)initWithFirebasePinData: (FirebaseDataPin *) pin;
- (NSString *) getReferencedFirebaseId;

@end
