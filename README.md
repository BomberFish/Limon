# Limón

Limón is the world's first Nintendo 3DS emulator for iPad and iPhone built on top of **[Citra](https://github.com/citra-emu/citra)** making use of the experimental Vulkan renderer by **[GPUcode](https://github.com/gpucode)** through **[MoltenVK](https://github.com/KhronosGroup/MoltenVK)**, written in Objective-C and Swift.

## About this fork
This fork adds support for JIT through TrollStore, based on work by [PojavLauncherTeam](https://github.com/PojavLauncherTeam/PojavLauncher_iOS/blob/main/Natives/main.m), [saagarjha](https://saagarjha.com/blog/2020/02/23/jailed-just-in-time-compilation-on-ios/), [utmapp](https://github.com/utmapp/UTM/blob/main/Services/UTMJailbreak.m), [RedNick16](https://github.com/Rednick16/TrollStoreJitEnabler), and [C22](https://github.com/c22dev/Lemon/tree/main/emuThreeDS/citra_wrapper/JIT).

## Why not just inject [TrollStoreJitEnabler](https://github.com/Rednick16/TrollStoreJitEnabler)?

I wanted a more integrated experience in general. I'll probably try that sometime while I wait for the original author to release build scripts for the dependencies.

## Building

I have no idea how to build this, since the original author of Limón has made the build dependencies private. See [this issue](https://github.com/emuPlace/Limon/issues/26) for more details.

## TODO:

- Test if this actually works
