library helper_firebase;

import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:helper/helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFirebaseVersion {

  /// Instance of [HelperFirebaseVersion].
  static late HelperFirebaseVersion _instance;

  late final FirebaseRemoteConfig _remoteConfig;

  /// Minimum build required fetched from [_remoteConfig].
  late int _minBuildRequired;

  /// Boolean to know if the app is in maintenance.
  late bool _inMaintenance;

  /// Boolean to know if the app need to be updated.
  late bool _needUpdate;

  /// Key where [_needUpdate] is saved in SharedPreferences.
  final String _needUpdateKey = "needUpdateApp";

  /// Key where [_inMaintenance] is saved in SharedPreferences.
  final String _inMaintenanceKey = "inMaintenanceApp";

  /// Private constructor.
  HelperFirebaseVersion._(this._remoteConfig);

  /// Private constructor for test.
  HelperFirebaseVersion._createForTest();

  /// Function to initialize [_instance] with [remoteConfig].
  static void initialize(FirebaseRemoteConfig remoteConfig) {
    // Set the instance
    _instance = HelperFirebaseVersion._(remoteConfig);
  }

  /// Function to fetch from [_remoteConfig]
  /// if the app is in maintenance or if the app need to be updated.
  ///
  /// - minBuildKey is the key in the FirebaseRemoteConfig associated with the minimum build,
  /// [minBuildIosKey] for IOS, [minBuildAndroidKey] for Android.
  ///
  /// - inMaintenance is the key in the FirebaseRemoteConfig associated with the maintenance boolean,
  /// [inMaintenanceIosKey] for IOS, [inMaintenanceAndroidKey] for Android.
  Future<void> fetchConfig({
    RemoteConfigSettings? configSettings,
    String minBuildIosKey = "minBuildIos",
    String minBuildAndroidKey = "minBuildAndroid",
    String inMaintenanceIosKey = "inMaintenanceIos",
    String inMaintenanceAndroidKey = "inMaintenanceAndroid"
  }) async {
    // Fetch the SharedPreferences instance
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try{
      // Set config settings to the FirebaseRemoteConfig
      await _remoteConfig.setConfigSettings(
        configSettings ?? RemoteConfigSettings(fetchTimeout: const Duration(seconds: 5), minimumFetchInterval: const Duration(minutes: 5))
      );
      // Fetch all configurations
      await _remoteConfig.fetchAndActivate();
      // Fetch the minimum build required from FirebaseRemoteConfig
      _minBuildRequired = _remoteConfig.getInt(Platform.isIOS? minBuildIosKey : minBuildAndroidKey);
      // Check if the app need to be updated
      await checkIfNeedUpdate();
      // Fetch if the app is in maintenance
      _inMaintenance = _remoteConfig.getBool(Platform.isIOS? inMaintenanceIosKey : inMaintenanceAndroidKey);
      // Save inMaintenance boolean in SharedPreferences
      _saveMaintenance(preferences: preferences);
    }
    catch(e, stackTrace){
      // Print the error
      HelperTryCatch.printError(e, stackTrace);
      // Retrieve all booleans
      _needUpdate = preferences.getBool(_needUpdateKey) ?? false;
      _inMaintenance = preferences.getBool(_inMaintenanceKey) ?? false;
    }
  }


  /// Function to check if the app need to be updated.
  ///
  /// If the app need to be updated, it will set [_needUpdate] to true
  /// and save the boolean in SharedPreferences.
  Future<void> checkIfNeedUpdate({
    SharedPreferences? preferences
  }) async {
    // Fetch the instance of SharedPreferences
    preferences ??= await SharedPreferences.getInstance();
    // Fetch the package info
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // If the build number of the app is less than the minimum of build required
    if(int.parse(packageInfo.buildNumber) < _minBuildRequired) {
      // Set needUpdate boolean to true
      _needUpdate = true;
    }
    // If the build number of the app
    // is equal or superior than the minimum of build required
    else {
      // Set needUpdate boolean to false
      _needUpdate = false;
    }
    // Save the boolean in SharedPreferences
    await preferences.setBool(_needUpdateKey, _needUpdate);
  }


  /// Function to save the boolean [_inMaintenance] in SharedPreferences.
  Future<void> _saveMaintenance({
    required SharedPreferences? preferences
  }) async {
    // Fetch the instance of SharedPreferences
    preferences ??= await SharedPreferences.getInstance();
    // Save the boolean in SharedPreferences
    await preferences.setBool(_inMaintenanceKey, _inMaintenance);
  }

  bool get needUpdate => _needUpdate;

  bool get inMaintenance => _inMaintenance;

  static HelperFirebaseVersion get instance => _instance;

  /// Function to initialize [_instance] for testing.
  @visibleForTesting
  static void initializeForTest() {
    // Set the instance
    _instance = HelperFirebaseVersion._createForTest();
  }
}