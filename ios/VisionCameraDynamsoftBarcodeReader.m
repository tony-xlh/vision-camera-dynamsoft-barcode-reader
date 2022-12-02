//
//  VisionCameraDynamsoftBarcodeReader.m
//  VisionCameraDynamsoftBarcodeReader
//
//  Created by xulihang on 2022/12/2.
//  Copyright © 2022 Facebook. All rights reserved.
//


#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VisionCameraDynamsoftBarcodeReader, NSObject)

RCT_EXTERN_METHOD(initLicense:(NSString)license
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initRuntimeSettingsFromString:(NSString *)template
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(decodeBase64:(NSString *)base64
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
