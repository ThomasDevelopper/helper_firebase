import 'package:flutter_test/flutter_test.dart';
import 'package:helper_firebase/src/helper_firebase_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Set Mock values
  SharedPreferences.setMockInitialValues({});
  PackageInfo.setMockInitialValues(appName: "", packageName: "", version: "", buildNumber: "5", buildSignature: "", installerStore: "");

  group("Test needUpdate boolean", () {
    late SharedPreferences preferences;

    setUp(() async {
      HelperFirebaseVersion.initializeForTest();
      preferences = await SharedPreferences.getInstance();
    });

    test("Test to verify if the boolean needUpdate is true", () async {
      // Set the minimum build required
      HelperFirebaseVersion.instance.minBuildRequired = 6;
      // Check the build version
      await HelperFirebaseVersion.instance.checkIfNeedUpdate(preferences: preferences);
      // Expect that needUpdate boolean is true
      expect(HelperFirebaseVersion.instance.needUpdate, true);
      // Expect that the needUpdate boolean in SharedPreferences is also true
      expect(preferences.getBool("needUpdateApp"), true);
    });

    test("Test to verify if the boolean needUpdate is false"
        "current build is equal to minimum build required", () async {
      // Set the minimum build required
      HelperFirebaseVersion.instance.minBuildRequired = 5;
      // Check the build version
      await HelperFirebaseVersion.instance.checkIfNeedUpdate(preferences: preferences);
      // Expect that needUpdate boolean is false
      expect(HelperFirebaseVersion.instance.needUpdate, false);
      // Expect that the needUpdate boolean in SharedPreferences is also false
      expect(preferences.getBool("needUpdateApp"), false);
    });

    test("Test to verify if the boolean needUpdate is false"
        "current build is less than minimum build required", () async {
      // Set the minimum build required
      HelperFirebaseVersion.instance.minBuildRequired = 4;
      // Check the build version
      await HelperFirebaseVersion.instance.checkIfNeedUpdate(preferences: preferences);
      // Expect that needUpdate boolean is false
      expect(HelperFirebaseVersion.instance.needUpdate, false);
      // Expect that the needUpdate boolean in SharedPreferences is also false
      expect(preferences.getBool("needUpdateApp"), false);
    });
  });
}