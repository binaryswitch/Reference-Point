//
//  FirebaseUserDataModel.h
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "FirebaseDataPin.h"

@interface FirebaseUserDataModelResponse : JSONModel

@property (strong, nonatomic) NSDictionary * pins;
@property (strong, nonatomic) NSMutableArray<FirebaseDataPin *> <Ignore> * castedPins;

@end
