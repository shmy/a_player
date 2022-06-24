#import "APlayerPlugin.h"
#if __has_include(<a_player/a_player-Swift.h>)
#import <a_player/a_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "a_player-Swift.h"
#endif

@implementation APlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAPlayerPlugin registerWithRegistrar:registrar];
}
@end
