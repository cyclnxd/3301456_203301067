import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:subsocial/extensions/image_path.dart';

import '../../../../components/custom_text_field.dart';
import '../../../../constants/paddings.dart';
import '../../../../providers/firebase_provider.dart';
import '../../../../providers/is_loading_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../services/navigation/navigation_service.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Register",
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
                      placeholderBuilder: (context) =>
                          const CircularProgressIndicator(),
                    )
                  : SvgPicture.asset(
                      "ic_s_outlined_black.svg".svgPath(),
                      placeholderBuilder: (context) =>
                          const CircularProgressIndicator(),
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
                    registerSubmitButton(),
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          onPressed: () {
            NavigationService.instance.navigateToPageClear(path: "/login");
          },
          child: const Text("I have an account"),
        ),
      ),
    );
  }

  ElevatedButton registerSubmitButton() {
    final _authState = ref.watch(authServicesProvider);
    return ElevatedButton(
      onPressed: ref.watch(isLoadingProvider)
          ? null
          : () async {
              if (_key.currentState!.validate()) {
                try {
                  ref.read(isLoadingProvider.notifier).changeIsLoading();
                  await _authState.signUpWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  NavigationService.instance.navigateToPageClear(
                    path: '/account-info',
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "${_emailController.text} address cannot be used"),
                    ),
                  );
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
            : const Text("Sign Up"),
      ),
    );
  }
}
