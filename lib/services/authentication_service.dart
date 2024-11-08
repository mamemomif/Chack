import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

    // Firebase 에러 메시지를 한글로 변환
  String _getKoreanErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return '인증 정보가 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'operation-not-allowed':
        return '해당 인증 방식이 비활성화되어 있습니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'too-many-requests':
        return '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'credential-already-in-use':
        return '이미 다른 계정에서 사용 중인 인증 정보입니다.';
      default:
        return '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  // 이메일 회원가입
  // 현재 유저 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일 회원가입
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. 계정 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. 사용자 이름 업데이트
      await credential.user?.updateDisplayName(name);
      
      // 3. 이메일 인증 메일 발송
      await credential.user?.sendEmailVerification();

      // 4. 로그아웃 (이메일 인증 전까지는 로그인 불가)
      await _auth.signOut();

    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}'); // 디버깅용
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Sign Up Error: $e'); // 디버깅용
      throw '회원가입 중 오류가 발생했습니다.';
    }
  }

  // 이메일 로그인
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 이메일 인증 여부 확인
      if (!credential.user!.emailVerified) {
        // 인증되지 않은 경우 로그아웃
        await _auth.signOut();
        throw '이메일 인증이 필요합니다. 메일함을 확인해주세요.';
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}'); // 디버깅용
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Sign In Error: $e'); // 디버깅용
      if (e is String) {
        throw e;
      }
      throw '로그인 중 오류가 발생했습니다.';
    }
  }

  // 인증 메일 재발송
  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      // 임시 로그인하여 현재 사용자 생성
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 인증 메일 발송
      await credential.user?.sendEmailVerification();
      
      // 다시 로그아웃
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print('Resend Verification Error: ${e.code}'); // 디버깅용
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Resend Verification Error: $e'); // 디버깅용
      throw '인증 메일 발송에 실패했습니다.';
    }
  }

  // 이메일 인증 상태 확인
  Future<bool> isEmailVerified(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final isVerified = credential.user?.emailVerified ?? false;
      
      // 인증되지 않은 경우 로그아웃
      if (!isVerified) {
        await _auth.signOut();
      }
      
      return isVerified;
    } catch (e) {
      print('Verification Check Error: $e'); // 디버깅용
      return false;
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
    } on FirebaseAuthException catch (e) {
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
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