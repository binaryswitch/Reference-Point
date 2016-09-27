//
//  FirebaseDataPin.h
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FirebaseDataPin : JSONModel

@property (nonatomic) NSString * firebaseId;
@property (nonatomic) NSNumber * latitude;
@property (nonatomic) NSNumber * longitude;

@end
