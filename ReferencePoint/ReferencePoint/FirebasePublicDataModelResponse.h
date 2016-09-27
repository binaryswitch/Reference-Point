//
//  FirebasePublicDataModelResponse.h
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "FirebasePinDataTypes.h"
#import "FirebaseAppVersion.h"

@protocol FirebasePinDataTypes
@end

@interface FirebasePublicDataModelResponse : JSONModel

@property (nonatomic) NSDictionary * version;

@property (strong, nonatomic) NSArray<FirebasePinDataTypes> * datatypes;
@property (strong, nonatomic) NSMutableArray<FirebaseAppVersion *> <Ignore> * castedVersion;

@end
