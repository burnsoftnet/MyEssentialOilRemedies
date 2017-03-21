//
//  NSObject+PTKConflictEntry.h
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 3/20/17.
//  Copyright © 2017 burnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTKMetadata;

@interface PTKConflictEntry : NSObject

@property (strong) NSFileVersion * version;
@property (strong) PTKMetadata * metadata;

- (id)initWithFileVersion:(NSFileVersion *)version metadata:(PTKMetadata *)metadata;

@end
