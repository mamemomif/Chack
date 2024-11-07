import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../constants/text_styles.dart';
import '../constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다!')),
      );
      
      Navigator.pop(context); // 회원가입 성공 후 로그인 화면으로 돌아가기
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '똑똑한 독서 습관,\n',
                          style: AppTextStyles.titleStyle,
                        ),
                        TextSpan(
                          text: '채크',
                          style: AppTextStyles.titleStyle.copyWith(
                            color: AppColors.pointColor,
                          ),
                        ),
                        TextSpan(
                          text: '에 오신 것을 환영해요 :)',
                          style: AppTextStyles.titleStyle,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  CustomTextField(
                    hintText: '이름',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: '이메일 주소',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return '유효한 이메일 주소를 입력하세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: '비밀번호',
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: '비밀번호 확인',
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 45),

                  CustomButton(
                    text: _isLoading ? '로딩 중...' : '시작하기',
                    onPressed: _isLoading ? null : _register,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
