import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../../features/product/data/datasources/product_local_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/pos/presentation/bloc/cart_bloc.dart';
import '../../features/pos/data/repositories/order_repository.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/inventory/data/datasources/inventory_local_data_source.dart';

final sl = GetIt.instance; // sl singkatan dari Service Locator

void setupLocator() {
  // 1. Database (Singleton: Hanya ada 1 instance sepanjang aplikasi nyala)
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // 2. Data Source
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSource(sl<AppDatabase>()),
  );

  // 3. Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductLocalDataSource>()),
  );

  // 4. BLoC (Factory: BLoC biasanya dibuat baru setiap kali halaman dibuka)
  sl.registerFactory<ProductBloc>(
    () => ProductBloc(sl<ProductRepository>()),
  );

  sl.registerFactory<CartBloc>(() => CartBloc());

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepository(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthLocalDataSource>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

   sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSource(sl<AppDatabase>()),
  );
}