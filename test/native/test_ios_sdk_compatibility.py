"""Compile the real plugin while forbidding APIs absent from older iOS SDKs.

Run on macOS after `flutter precache --ios`:
    python3 -m unittest discover -s test/native -v

The SDK overlay changes the maximum SDK version after importing Flutter/UIKit,
then poisons the new API names. This also catches references hidden behind a
runtime-only @available check. It does not replace a build with an older Xcode.
"""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SOURCE = (
    ROOT
    / "ios/tw_iphone_duo_reserved_region/Sources"
    / "tw_iphone_duo_reserved_region/TwIphoneDuoReservedRegionPlugin.m"
)


@unittest.skipUnless(shutil.which("xcrun"), "Requires Xcode on macOS")
class IosSdkCompatibilityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sdk = subprocess.check_output(
            ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], text=True
        ).strip()
        flutter_root = os.environ.get("FLUTTER_ROOT")
        if flutter_root:
            flutter_root = Path(flutter_root)
        else:
            flutter = shutil.which("flutter")
            if flutter is None:
                raise RuntimeError("Install Flutter or set FLUTTER_ROOT")
            flutter_root = Path(flutter).resolve().parents[1]
        cls.frameworks = (
            flutter_root
            / "bin/cache/artifacts/engine/ios/Flutter.xcframework"
            / "ios-arm64_x86_64-simulator"
        )
        if not (cls.frameworks / "Flutter.framework/Headers/Flutter.h").is_file():
            raise RuntimeError("Missing Flutter iOS framework; run flutter precache --ios")

    def compile_plugin(self, *extra_flags):
        result = subprocess.run(
            [
                "xcrun", "--sdk", "iphonesimulator", "clang",
                "-fsyntax-only", "-fobjc-arc", "-fblocks", "-Werror",
                "-Wunguarded-availability",
                "-target", "arm64-apple-ios15.5-simulator",
                "-isysroot", self.sdk,
                "-F", str(self.frameworks),
                *extra_flags,
                str(SOURCE),
            ],
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_compiles_with_installed_sdk_and_ios_15_5_deployment_target(self):
        self.compile_plugin()

    def test_older_sdks_compile_without_reserved_region_apis(self):
        for sdk_version in (150500, 260200, 270000):
            with self.subTest(sdk_version=sdk_version), tempfile.TemporaryDirectory() as tmp:
                overlay = Path(tmp) / "old_sdk.h"
                overlay.write_text(
                    "#import <Flutter/Flutter.h>\n"
                    "#undef __IPHONE_OS_VERSION_MAX_ALLOWED\n"
                    f"#define __IPHONE_OS_VERSION_MAX_ALLOWED {sdk_version}\n"
                    "#pragma GCC poison UIViewReservedRegion UIViewReservedRegionKind "
                    "reservedRegionsOfKind occlusionRegionKind\n"
                )
                self.compile_plugin("-include", str(overlay))


if __name__ == "__main__":
    unittest.main()
