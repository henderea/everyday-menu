//
//  NSData+SHA256Digest.m
//  MD5SHA1Digest
//
//

#import "NSData+SHA256Digest.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SHA256)

+(NSData *)SHA256Digest:(NSData *)input {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(input.bytes, input.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

-(NSData *)SHA256Digest {
    return [NSData SHA256Digest:self];
}

+(NSString *)SHA256HexDigest:(NSData *)input {
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(input.bytes, input.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

-(NSString *)SHA256HexDigest {
    return [NSData SHA256HexDigest:self];
}

@end