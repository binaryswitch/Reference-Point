//
//  FirebaseDataPin.h
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface FirebaseDataPin : JSONModel

@property (nonatomic) NSString <Ignore>*  firebaseId;
@property (nonatomic) NSNumber <Optional>* latitude;
@property (nonatomic) NSNumber <Optional>* longitude;
@property (nonatomic) NSString * desc;

+(NSString *) randomKeyWithLength: (int) length;

@end
