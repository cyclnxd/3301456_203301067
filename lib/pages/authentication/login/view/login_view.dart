import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/utils/utils.dart';

import '../../../../components/custom_text_field.dart';
import '../../../../constants/paddings.dart';
import '../../../../providers/firebase_provider.dart';
import '../../../../providers/is_loading_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../services/navigation/navigation_service.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  late final GlobalKey<FormState> _key;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _key = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Login",
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: ProjectPaddings.hLargePadding,
        child: Column(
          children: [
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 2,
              child: ref.watch(themeDataProvider)
                  ? SvgPicture.asset(
                      "ic_s_outlined_white.svg".svgPath(),
                      placeholderBuilder: (context) => Lottie.asset(
                        height: MediaQuery.of(context).size.height * 0.5,
                        "ic_indicator.json".lottiePath(),
                      ),
                    )
                  : SvgPicture.asset(
                      "ic_s_outlined_black.svg".svgPath(),
                      placeholderBuilder: (context) => Lottie.asset(
                        height: MediaQuery.of(context).size.height * 0.5,
                        "ic_indicator.json".lottiePath(),
                      ),
                    ),
            ),
            Expanded(
              flex: 4,
              child: Form(
                key: _key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomTextFormField(
                      controller: _emailController,
                      hintText: 'Email',
                      invalidText: 'Please enter an email',
                      obscureText: false,
                      inputType: TextInputType.emailAddress,
                    ),
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: 'Password',
                      invalidText: 'Please enter an password',
                      obscureText: true,
                      inputType: TextInputType.visiblePassword,
                    ),
                    loginSubmitButton(),
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 1,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                NavigationService.instance
                    .navigateToPageClear(path: "/register");
              },
              child: const Text(
                "Don't have an account?",
              ),
            ),
            TextButton(
              onPressed: () {
                _showMyDialog(context, ref);
              },
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton loginSubmitButton() {
    final _authState = ref.watch(authServicesProvider);
    return ElevatedButton(
      onPressed: ref.watch(isLoadingProvider)
          ? null
          : () async {
              if (_key.currentState!.validate()) {
                try {
                  ref.read(isLoadingProvider.notifier).changeIsLoading();
                  await _authState.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case "user-disabled":
                      showSnackBar(context, "User disabled");
                      break;
                    case "wrong-password":
                      showSnackBar(context, "Wrong password");
                      break;
                    default:
                      showSnackBar(context, "Email is wrong");
                      break;
                  }
                } finally {
                  ref.read(isLoadingProvider.notifier).changeIsLoading();
                }
              }
            },
      child: Center(
        child: ref.watch(isLoadingProvider)
            ? const SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(),
              )
            : const Text("Sign In"),
      ),
    );
  }
}

Future<void> _showMyDialog(context, ref) async {
  final _emailController = TextEditingController();
  final _key = GlobalKey<FormState>();
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reset Password'),
        content: SingleChildScrollView(
          child: Form(
            key: _key,
            child: ListBody(
              children: <Widget>[
                CustomTextFormField(
                  controller: _emailController,
                  invalidText: "Enter An Email",
                  hintText: "Email",
                  obscureText: false,
                  inputType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Apply'),
            onPressed: () async {
              try {
                if (_key.currentState!.validate()) {
                  await ref
                      .read(authServicesProvider)
                      .sendPasswordResetEmail(email: _emailController.text);
                  showSnackBar(context, "Email sent successfully");
                }
              } catch (e) {
                showSnackBar(context, "Email could not send");
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
