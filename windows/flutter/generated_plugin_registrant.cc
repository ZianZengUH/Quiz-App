//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <ble_peripheral/ble_peripheral_plugin_c_api.h>
#include <file_selector_windows/file_selector_windows.h>
#include <network_info_plus_windows/network_info_plus_windows_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <quick_blue_windows/quick_blue_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BlePeripheralPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BlePeripheralPluginCApi"));
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  NetworkInfoPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NetworkInfoPlusWindowsPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  QuickBlueWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("QuickBlueWindowsPlugin"));
}
