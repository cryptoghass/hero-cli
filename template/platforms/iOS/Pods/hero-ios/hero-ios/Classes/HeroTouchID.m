//
//  BSD License
//  Copyright (c) Hero software.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name Facebook nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//  Created by 朱成尧 on 2/10/15.
//
//

#import "HeroTouchID.h"
#import <LocalAuthentication/LAContext.h>
@implementation HeroTouchID
{
    LAContext *_laContext;
    id _actionObject;
}
-(void)on:(NSDictionary *)json{
    [super on:json];
    if (json[@"action"]) {
        _actionObject = json[@"action"];
    }
    if (json[@"checkEnable"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:json[@"checkEnable"]];
        [dict setObject:[NSNumber numberWithBool:[self supportTouchID]] forKey:@"value"];
        [self.controller on:dict];
    }
    if (json[@"max"]) {
        _laContext.maxBiometryFailures = json[@"max"];
    }
    if (json[@"check"]) {
        [_laContext setLocalizedFallbackTitle:@""];
        return [_laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:json[@"check"][@"title"] reply:^(BOOL success, NSError * _Nullable error) {
            if (error || (!success)) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:json[@"check"][@"action"]];
                [dict setObject:@"fail" forKey:@"value"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controller on:dict];
                });
            }else{
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:json[@"check"][@"action"]];
                [dict setObject:@"success" forKey:@"value"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controller on:dict];
                });
            }
        }];

    }
}
- (BOOL)supportTouchID {
#ifdef __IPHONE_8_0
    _laContext = [[LAContext alloc] init];
    return [_laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL];
#else
    return NO;
#endif
}

@end