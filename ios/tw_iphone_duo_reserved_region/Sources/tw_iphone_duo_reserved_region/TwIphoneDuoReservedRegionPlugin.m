#import "./include/tw_iphone_duo_reserved_region/TwIphoneDuoReservedRegionPlugin.h"

/// MethodChannel used exclusively for iPhone Duo Reserved Region queries.
static NSString *const TWIphoneDuoReservedRegionChannelName =
    @"tw591/iphone_duo_reserved_regions";

/// Method that returns active occlusion-region rectangles.
static NSString *const TWIphoneDuoReservedRegionMethodName =
    @"getActiveOcclusionRegions";

@interface TwIphoneDuoReservedRegionPlugin ()

/// Registrar used to resolve the Flutter view without owning its lifecycle.
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;

/// Channel retained for the lifetime of the registered plugin.
@property(nonatomic, strong) FlutterMethodChannel *channel;

/// Creates the plugin around the registrar-owned Flutter engine.
- (instancetype)initWithRegistrar:
    (NSObject<FlutterPluginRegistrar> *)registrar;

/// Serializes currently active occlusion regions in Flutter view coordinates.
- (id)activeOcclusionRegionPayload;

@end

@implementation TwIphoneDuoReservedRegionPlugin

/// Registers the MethodChannel and delegates its calls to this plugin.
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  TwIphoneDuoReservedRegionPlugin *plugin =
      [[TwIphoneDuoReservedRegionPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:plugin channel:plugin.channel];
}

/// Creates the plugin around the registrar-owned Flutter engine.
- (instancetype)initWithRegistrar:
    (NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
    _channel = [FlutterMethodChannel
        methodChannelWithName:TWIphoneDuoReservedRegionChannelName
              binaryMessenger:registrar.messenger];
  }
  return self;
}

/// Handles supported queries and rejects unknown MethodChannel methods.
- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if (![call.method isEqualToString:TWIphoneDuoReservedRegionMethodName]) {
    result(FlutterMethodNotImplemented);
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    result([self activeOcclusionRegionPayload]);
  });
}

/// Serializes currently active occlusion regions in Flutter view coordinates.
- (id)activeOcclusionRegionPayload {
  if (@available(iOS 27.1, *)) {
    UIView *flutterView = self.registrar.viewController.view;
    if (flutterView == nil) {
      return [FlutterError errorWithCode:@"flutter_view_unavailable"
                                 message:@"Flutter view is unavailable."
                                 details:nil];
    }

    NSArray<UIViewReservedRegion *> *regions =
        [flutterView reservedRegionsOfKind:
                         [UIViewReservedRegionKind occlusionRegionKind]];
    NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *payload =
        [NSMutableArray array];
    for (UIViewReservedRegion *region in regions) {
      if (!region.isActive) continue;
      CGRect frame = region.frame;
      [payload addObject:@{
        @"left" : @(CGRectGetMinX(frame)),
        @"top" : @(CGRectGetMinY(frame)),
        @"width" : @(CGRectGetWidth(frame)),
        @"height" : @(CGRectGetHeight(frame)),
      }];
    }
    return payload;
  }
  return nil;
}

@end
