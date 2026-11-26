import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../../features/product/data/datasources/product_local_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/pos/presentation/bloc/cart_bloc.dart';
import '../../features/pos/data/repositories/order_repository.dart';

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
}