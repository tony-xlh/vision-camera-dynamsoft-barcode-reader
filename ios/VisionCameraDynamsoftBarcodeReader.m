#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>



@interface RCT_EXTERN_MODULE(VisionCameraDynamsoftBarcodeReader, NSObject)

RCT_EXTERN_METHOD(initLicense:(NSString)license
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initRuntimeSettingsFromString:(NSString *)template
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(decodeBase64:(NSString *)base64
                 templateName:(NSString *)templateName
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
