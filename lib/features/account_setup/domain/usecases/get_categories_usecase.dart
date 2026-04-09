import '../entities/category_entity.dart';
import '../repository/account_setup_repository.dart';

class GetCategoriesUseCase {
  final AccountSetupRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<List<CategoryEntity>> call({
    int offset = 0,
    int limit = 20,
  }) {
    return _repository.getCategories(offset: offset, limit: limit);
  }
}
