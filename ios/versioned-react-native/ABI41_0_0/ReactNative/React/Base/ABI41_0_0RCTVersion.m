/**
 * @generated by scripts/bump-oss-version.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI41_0_0RCTVersion.h"

NSString* const ABI41_0_0RCTVersionMajor = @"major";
NSString* const ABI41_0_0RCTVersionMinor = @"minor";
NSString* const ABI41_0_0RCTVersionPatch = @"patch";
NSString* const ABI41_0_0RCTVersionPrerelease = @"prerelease";


NSDictionary* ABI41_0_0RCTGetreactNativeVersion(void)
{
  static NSDictionary* __rnVersion;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^(void){
    __rnVersion = @{
                  ABI41_0_0RCTVersionMajor: @(0),
                  ABI41_0_0RCTVersionMinor: @(63),
                  ABI41_0_0RCTVersionPatch: @(2),
                  ABI41_0_0RCTVersionPrerelease: [NSNull null],
                  };
  });
  return __rnVersion;
}
