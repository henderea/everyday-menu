//
//  NSData+SHA1Digest.h
//  MD5SHA1Digest
//
//  Created by Tom Meinlschmidt on 28.2.2013.
//  Copyright (c) 2013 Tom Meinlschmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SHA1Digest)

+(NSData *)SHA1Digest:(NSData *)input;
-(NSData *)SHA1Digest;

+(NSString *)SHA1HexDigest:(NSData *)input;
-(NSString *)SHA1HexDigest;

@end