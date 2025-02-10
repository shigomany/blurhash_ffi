#include "include/blurhash_ffi/blurhash_ffi_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "blurhash_ffi_plugin.h"

void BlurhashFfiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  blurhash_ffi::BlurhashFfiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
