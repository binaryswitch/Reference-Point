//
//  FirebasePinDataTypes.h
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <UIKit/UIKit.h>

@interface FirebasePinDataTypes : JSONModel

@property (nonatomic) NSArray * colour;
@property (nonatomic) UIColor <Ignore> *castedColour;

@property (nonatomic) NSString * title;

@end
