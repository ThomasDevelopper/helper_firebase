library helper_firebase;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:helper/helper.dart';

class HelperFirebaseAuth {

  /// Instance of [HelperFirebaseAuth].
  static late HelperFirebaseAuth _instance;

  final FirebaseAuth _firebaseAuth;
  String _weakPassword = "Password too weak";
  String _invalidEmail = "Please enter a valid email address";
  String _emailAlreadyUsed =  "Email already used";
  String _userNotFound = "User not found";
  String _userDisabled = "You have been banned from the app";
  String _wrongPassword = "Wrong password";
  String _tooManyRequest = "Too many requests are in progress, please try again later.";
  String _otherError = "An error has occurred (Code 1)";
  String _otherError2 = "An error has occurred (Code 2)";

  /// Private constructor to initialize [_firebaseAuth].
  HelperFirebaseAuth._(this._firebaseAuth);

  /// Function to initialize [_instance] with [firebaseAuth].
  static void initialize(FirebaseAuth firebaseAuth) {
    // Set the instance
    _instance = HelperFirebaseAuth._(firebaseAuth);
  }

  /// Function to initialize all errors message.
  void initializeErrors({
    String? weakPassword,
    String? invalidEmail,
    String? emailAlreadyUsed,
    String? userNotFound,
    String? userDisabled,
    String? wrongPassword,
    String? tooManyRequest,
    String? otherError,
    String? otherError2,
  }) {
    if(weakPassword!=null) _weakPassword = weakPassword;
    if(invalidEmail!=null) _invalidEmail = invalidEmail;
    if(emailAlreadyUsed!=null) _emailAlreadyUsed = emailAlreadyUsed;
    if(userNotFound!=null) _userNotFound = userNotFound;
    if(userDisabled!=null) _userDisabled = userDisabled;
    if(wrongPassword!=null) _wrongPassword = wrongPassword;
    if(tooManyRequest!=null) _tooManyRequest = tooManyRequest;
    if(otherError!=null) _otherError = otherError;
    if(otherError2!=null) _otherError2 = otherError2;
  }

  /// Function to execute [futureCredential].
  Future<UserCredential> _createFunction(Future<UserCredential> futureCredential) async {
    try{
      // Return the UserCredential
      return await futureCredential;
    }
    on FirebaseAuthException catch(e) {
      // For each code of the FirebaseAuthException
      switch(e.code) {
        case 'weak-password':
          throw _weakPassword;
        case 'invalid-email':
          throw _invalidEmail;
        case 'email-already-in-use':
          throw _emailAlreadyUsed;
        case 'user-not-found':
          throw _userNotFound;
        case 'user-disabled':
          throw _userDisabled;
        case 'wrong-password':
          throw _wrongPassword;
        case 'too-many-requests':
          throw _tooManyRequest;
        default:
          throw _otherError;
      }
    }
    catch(e, stackTrace) {
      // Print the error
      HelperTryCatch.printError(e, stackTrace);
      // Throw otherError2
      throw _otherError2;
    }
  }

  /// Function to re-authenticate the current user with the current user [password].
  Future<UserCredential> _reAuthenticateCurrentUser(String password) async {
    // Fetch the current user from firebase
    User currentUser = _firebaseAuth.currentUser!;
    // Try the re-authenticate the current user
    return await _createFunction(
      currentUser.reauthenticateWithCredential(EmailAuthProvider.credential(email: currentUser.email!, password: password))
    );
  }

  /// Register a user into Firebase with email and password.
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password
  }) {
    // Remove all unnecessary spaces from the email
    email = email.removeUnnecessarySpaces();
    // Fetch the future for register a user from FirebaseAuth
    Future<UserCredential> future = _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    // Return the future
    return future;
  }

  /// Log a user from Firebase with email and password.
  Future<UserCredential> logInWithEmailAndPassword({
    required String email,
    required String password
  }) {
    // Remove all unnecessary spaces from the email
    email = email.removeUnnecessarySpaces();
    // Fetch the future for register a user from Firebase
    Future<UserCredential> future = _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    // Return the function
    return _createFunction(future);
  }

  /// Function to update the email of the current user.
  ///
  /// - [password] is needed for re-authenticate the current user.
  /// - [newEmail] is the new email of the current user.
  Future<void> updateEmail({
    required String password,
    required String newEmail
  }) async {
    try{
      // Remove all unnecessary spaces from the email
      newEmail = newEmail.removeUnnecessarySpaces();
      // Try to re-authenticate the current user
      UserCredential currentUserReAuthenticate = await _reAuthenticateCurrentUser(password);
      // Update the email of the current user
      await currentUserReAuthenticate.user!.updateEmail(newEmail);
    }
    catch(e, stackTrace) {
      // Print the error
      HelperTryCatch.printError(e, stackTrace);
      // Re-throw the error
      rethrow;
    }
  }

  /// Function to update the password of the current user.
  ///
  /// - [oldPassword] is the old password of the current user
  /// is needed to re-authenticate the current user.
  ///
  /// - [newPassword] is the new password of the current user.
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword
  }) async {
    try{
      // Try to re-authenticate the current user
      UserCredential currentUserReAuthenticate = await _reAuthenticateCurrentUser(oldPassword);
      // Update the password of the current user
      await currentUserReAuthenticate.user!.updatePassword(newPassword);
    }
    catch(e, stackTrace) {
      // Print the error
      HelperTryCatch.printError(e, stackTrace);
      // Re-throw the error
      rethrow;
    }
  }

  static HelperFirebaseAuth get instance => _instance;
}