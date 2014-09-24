//
//  NSData+MD5Digest.h
//  MD5SHA1Digest
//
//  Created by Tom Meinlschmidt on 28.2.2013.
//  Copyright (c) 2013 Tom Meinlschmidt. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSData (MD5Digest)

+(NSData *)MD5Digest:(NSData *)input;
-(NSData *)MD5Digest;

+(NSString *)MD5HexDigest:(NSData *)input;
-(NSString *)MD5HexDigest;

@end