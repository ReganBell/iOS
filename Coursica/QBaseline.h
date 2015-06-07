//
//  QBaseline.h
//  Coursica
//
//  Created by Regan Bell on 6/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "Mantle.h"

@interface QBaseline : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber * department;
@property (strong, nonatomic) NSNumber * division;
@property (strong, nonatomic) NSNumber * group;
@property (strong, nonatomic) NSNumber * size;

@end
