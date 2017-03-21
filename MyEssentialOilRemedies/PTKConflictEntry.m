//
//  NSObject+PTKConflictEntry.m
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 3/20/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import "PTKConflictEntry.h"

@implementation PTKConflictEntry
@synthesize version = _version;
@synthesize metadata = _metadata;

- (id)initWithFileVersion:(NSFileVersion *)version metadata:(PTKMetadata *)metadata {
    if ((self = [super init])) {
        self.version = version;
        self.metadata = metadata;
    }
    return self;
}

@end
