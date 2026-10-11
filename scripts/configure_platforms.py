#!/usr/bin/env python3
"""
Run this AFTER `flutter create .` has generated the android/ and ios/
folders. It adds the permission strings and the landmarkapp:// deep-link
registration that `flutter create` doesn't know to add on its own:

  iOS (ios/Runner/Info.plist):
    - NSFaceIDUsageDescription
    - NSCameraUsageDescription
    - NSPhotoLibraryUsageDescription
    - CFBundleURLTypes entry for the "landmarkapp" scheme

  Android (android/app/src/main/AndroidManifest.xml):
    - <uses-permission> for CAMERA and USE_BIOMETRIC
    - <intent-filter> on the main activity for "landmarkapp://verify"

  Android (MainActivity.kt or .java):
    - Switches the base class from FlutterActivity to FlutterFragmentActivity.
      The local_auth plugin (Face ID / biometric login) requires this —
      without it, biometric login fails at runtime with:
      "PlatformException(no_fragment_activity, local_auth plugin requires
      activity to be a FragmentActivity...)". `flutter create` always
      generates plain FlutterActivity, so this always needs patching.

Usage:
    cd landmark-flutter   # repo root, after `flutter create .`
    python3 scripts/configure_platforms.py

Safe to re-run: it checks for existing entries before adding anything.
"""
import plistlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def configure_ios() -> None:
    plist_path = ROOT / "ios" / "Runner" / "Info.plist"
    if not plist_path.exists():
        print(f"[iOS] Skipped — {plist_path} not found yet. "
              f"Run `flutter create .` first.")
        return

    with open(plist_path, "rb") as f:
        data = plistlib.load(f)

    changed = False

    usage_strings = {
        "NSFaceIDUsageDescription": "Log in to Landmark with Face ID",
        "NSCameraUsageDescription": "Landmark needs camera access to photograph listings",
        "NSPhotoLibraryUsageDescription": "Landmark needs photo library access to add listing photos",
    }
    for key, value in usage_strings.items():
        if key not in data:
            data[key] = value
            changed = True
            print(f"[iOS] Added {key}")
        else:
            print(f"[iOS] {key} already present, left as-is")

    url_types = data.get("CFBundleURLTypes", [])
    has_scheme = any(
        "landmarkapp" in t.get("CFBundleURLSchemes", []) for t in url_types
    )
    if not has_scheme:
        url_types.append({
            "CFBundleURLName": "com.landmark.verify",
            "CFBundleURLSchemes": ["landmarkapp"],
        })
        data["CFBundleURLTypes"] = url_types
        changed = True
        print("[iOS] Added landmarkapp:// URL scheme")
    else:
        print("[iOS] landmarkapp:// URL scheme already present, left as-is")

    if changed:
        with open(plist_path, "wb") as f:
            plistlib.dump(data, f)
        print(f"[iOS] Wrote {plist_path}")
    else:
        print("[iOS] Nothing to change")


def configure_android() -> None:
    manifest_path = ROOT / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
    if not manifest_path.exists():
        print(f"[Android] Skipped — {manifest_path} not found yet. "
              f"Run `flutter create .` first.")
        return

    xml = manifest_path.read_text()
    original = xml

    permissions = [
        '<uses-permission android:name="android.permission.CAMERA"/>',
        '<uses-permission android:name="android.permission.USE_BIOMETRIC"/>',
    ]
    for perm in permissions:
        name = re.search(r'android:name="([^"]+)"', perm).group(1)
        if f'android:name="{name}"' in xml:
            print(f"[Android] {name} already present, left as-is")
            continue
        xml = xml.replace("<manifest", f"<!--PERM_PLACEHOLDER-->\n<manifest", 1) \
            if "<!--PERM_PLACEHOLDER-->" not in xml else xml
        # Insert right after the opening <manifest ...> tag's closing '>'
        match = re.search(r"<manifest[^>]*>", xml)
        if match:
            insert_at = match.end()
            xml = xml[:insert_at] + f"\n    {perm}" + xml[insert_at:]
            print(f"[Android] Added permission {name}")

    xml = xml.replace("<!--PERM_PLACEHOLDER-->\n", "")

    # Add the landmarkapp://verify deep link intent-filter to the main activity,
    # right before that <activity>'s closing tag.
    if 'android:scheme="landmarkapp"' in xml:
        print("[Android] landmarkapp:// intent-filter already present, left as-is")
    else:
        deep_link_filter = (
            "\n            <intent-filter>\n"
            '                <action android:name="android.intent.action.VIEW"/>\n'
            '                <category android:name="android.intent.category.DEFAULT"/>\n'
            '                <category android:name="android.intent.category.BROWSABLE"/>\n'
            '                <data android:scheme="landmarkapp" android:host="verify"/>\n'
            "            </intent-filter>\n"
        )
        # Find the first <activity ...> block that is the launcher activity
        # (flutter's template names it MainActivity) and insert before </activity>.
        activity_match = re.search(r"(<activity[^>]*android:name=\"\.MainActivity\"[^>]*>.*?)(</activity>)",
                                    xml, re.DOTALL)
        if activity_match:
            xml = xml[:activity_match.end(1)] + deep_link_filter + xml[activity_match.end(1):]
            print("[Android] Added landmarkapp:// intent-filter to MainActivity")
        else:
            print("[Android] Could not find MainActivity block automatically — "
                  "add the intent-filter manually (see README).")

    if xml != original:
        manifest_path.write_text(xml)
        print(f"[Android] Wrote {manifest_path}")
    else:
        print("[Android] Nothing to change")


def configure_android_main_activity() -> None:
    android_app_main = ROOT / "android" / "app" / "src" / "main"
    candidates = list(android_app_main.glob("kotlin/**/MainActivity.kt")) + \
        list(android_app_main.glob("java/**/MainActivity.java"))

    if not candidates:
        print(f"[Android] Skipped MainActivity patch — none found under {android_app_main}. "
              f"Run `flutter create .` first.")
        return

    for path in candidates:
        text = path.read_text()
        original = text

        if path.suffix == ".kt":
            if "FlutterFragmentActivity" in text:
                print(f"[Android] {path.name} already uses FlutterFragmentActivity, left as-is")
                continue
            text = text.replace(
                "import io.flutter.embedding.android.FlutterActivity",
                "import io.flutter.embedding.android.FlutterFragmentActivity",
            )
            text = re.sub(
                r"class\s+MainActivity\s*:\s*FlutterActivity\s*\(\s*\)",
                "class MainActivity: FlutterFragmentActivity()",
                text,
            )
        else:  # .java
            if "FlutterFragmentActivity" in text:
                print(f"[Android] {path.name} already uses FlutterFragmentActivity, left as-is")
                continue
            text = text.replace(
                "import io.flutter.embedding.android.FlutterActivity;",
                "import io.flutter.embedding.android.FlutterFragmentActivity;",
            )
            text = re.sub(
                r"class\s+MainActivity\s+extends\s+FlutterActivity",
                "class MainActivity extends FlutterFragmentActivity",
                text,
            )

        if text != original:
            path.write_text(text)
            print(f"[Android] Switched {path.relative_to(ROOT)} to FlutterFragmentActivity "
                  f"(required by local_auth for biometric login)")
        else:
            print(f"[Android] Could not find the expected FlutterActivity pattern in {path.name} — "
                  f"check it manually (see README).")


if __name__ == "__main__":
    configure_ios()
    print()
    configure_android()
    print()
    configure_android_main_activity()
    print("\nDone. Review the diffs (`git diff ios/ android/`) before committing.")
