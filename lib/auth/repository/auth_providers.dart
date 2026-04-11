import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prioro/auth/repository/auth_repository.dart';

final FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;

final GoogleSignIn googleSignInInstance = GoogleSignIn();

final AuthRepository authRepositoryInstance = AuthRepository(
  auth: firebaseAuthInstance,
  googleSignIn: googleSignInInstance,
);

Stream<User?> authStateChangesStream() =>
    firebaseAuthInstance.authStateChanges();

User? currentUser() => firebaseAuthInstance.currentUser;
