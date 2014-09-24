//
//  NSData+SHA1Digest.h
//  MD5SHA1Digest
//

#import <Foundation/Foundation.h>

@interface NSData (SHA256Digest)

+(NSData *)SHA256Digest:(NSData *)input;
-(NSData *)SHA256Digest;

+(NSString *)SHA256HexDigest:(NSData *)input;
-(NSString *)SHA256HexDigest;

@end