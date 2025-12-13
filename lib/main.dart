import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  
  // Auth datasources
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient.client);
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  
  // Auth repository
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  
  // Auth use cases
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  
  runApp(
    MyApp(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      ),
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashPage(),
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.home: (context) => const HomePage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Service Marketplace App')),
    );
  }
}


