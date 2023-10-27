//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <tflite_flutter_helper_plus/tflite_flutter_helper_plus_plugin_c_api.h>
#include <tflite_flutter_plus/tflite_flutter_plus_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  TfliteFlutterHelperPlusPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TfliteFlutterHelperPlusPluginCApi"));
  TfliteFlutterPlusPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TfliteFlutterPlusPluginCApi"));
}
