import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // 현재 유저 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일 회원가입
  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 사용자 이름 업데이트
      await credential.user?.updateDisplayName(name);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        throw '이미 존재하는 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        throw '유효하지 않은 이메일입니다.';
      }
      throw e.message ?? '회원가입 중 오류가 발생했습니다.';
    }
  }

  // 이메일 로그인
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw '존재하지 않는 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        throw '잘못된 비밀번호입니다.';
      } else if (e.code == 'invalid-email') {
        throw '유효하지 않은 이메일입니다.';
      } else if (e.code == 'user-disabled') {
        throw '비활성화된 계정입니다.';
      }
      throw e.message ?? '로그인 중 오류가 발생했습니다.';
    }
  }

  // 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 기존 세션 클리어
      await _googleSignIn.signOut();
      
      // 동일한 GoogleSignIn 인스턴스 사용
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      // 인증 정보 얻기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Firebase 인증 정보 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google 로그인 오류: $e');
      throw '구글 로그인 중 오류가 발생했습니다.';
    }
  }

  // 현재 유저 가져오기
  User? getCurrentUser() => _auth.currentUser;

  // 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      throw '로그아웃에 실패했습니다.';
    }
  }
}