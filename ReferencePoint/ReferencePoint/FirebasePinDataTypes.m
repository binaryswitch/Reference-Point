//
//  FirebasePinDataTypes.m
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "FirebasePinDataTypes.h"

@implementation FirebasePinDataTypes

-(BOOL)validate:(NSError *__autoreleasing *)error{

    BOOL valid = [super validate:error];

    //fix bug with optional arrays of sub-models
    if (self.colour){
        
        double red = [[self.colour objectAtIndex:0] doubleValue];
        double green = [[self.colour objectAtIndex:1] doubleValue];
        double blue = [[self.colour objectAtIndex:2] doubleValue];
        
        self.castedColour =[UIColor colorWithRed:red green: green blue: blue alpha:1];
        
    }

    return valid;
}

@end
