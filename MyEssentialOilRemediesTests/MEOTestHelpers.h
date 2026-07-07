//
//  MEOTestHelpers.h
//  My Essential Oil Remedies Tests
//
//  Shared helpers for the unit test suite.
//

#import <Foundation/Foundation.h>

#pragma mark Copy Factory Database to a Temporary Path
/*! @brief Copies the factory MEO.db that ships inside the host application bundle
    to a unique temporary path so each test works against a disposable database.
    @return The path of the temporary database copy, or nil if the copy failed.
 */
static inline NSString *MEOCopyFactoryDatabaseToTemp(void)
{
    NSString *source = [[NSBundle mainBundle] pathForResource:@"MEO" ofType:@"db"];
    if (source == nil) {
        return nil;
    }
    NSString *dest = [NSTemporaryDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"MEO-%@.db", [[NSUUID UUID] UUIDString]]];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:source toPath:dest error:&error]) {
        return nil;
    }
    return dest;
}
