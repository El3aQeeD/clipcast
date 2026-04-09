import '../entities/speaker_entity.dart';
import '../repository/account_setup_repository.dart';

class GetSpeakersUseCase {
  final AccountSetupRepository _repository;

  const GetSpeakersUseCase(this._repository);

  Future<List<SpeakerEntity>> call({
    int offset = 0,
    int limit = 20,
  }) {
    return _repository.getSpeakers(offset: offset, limit: limit);
  }
}
