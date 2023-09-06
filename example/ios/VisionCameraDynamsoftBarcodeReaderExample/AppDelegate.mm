#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <VisionCameraDynamsoftBarcodeReader-Bridging-Header.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"VisionCameraDynamsoftBarcodeReaderExample";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
  //[FrameProcessorPluginRegistry addFrameProcessorPlugin:@"decode"
  //                                        withInitializer:^FrameProcessorPlugin*(NSDictionary* options) {
  //    return [[VisionCameraDBRPlugin alloc] initWithOptions:options];
  //  }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
