import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untense/domain/repositories/tension_repository.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';
import 'package:untense/presentation/bloc/tension/tension_state.dart';

/// BLoC for managing tension entries
class TensionBloc extends Bloc<TensionEvent, TensionState> {
  final TensionRepository _tensionRepository;

  TensionBloc({required TensionRepository tensionRepository})
    : _tensionRepository = tensionRepository,
      super(const TensionInitial()) {
    on<LoadTodayEntries>(_onLoadTodayEntries);
    on<LoadEntriesForDate>(_onLoadEntriesForDate);
    on<AddTensionEntry>(_onAddEntry);
    on<UpdateTensionEntry>(_onUpdateEntry);
    on<DeleteTensionEntry>(_onDeleteEntry);
    on<ToggleChartVisibility>(_onToggleChart);
    on<DeleteAllEntries>(_onDeleteAllEntries);
    on<LoadDatesWithEntries>(_onLoadDatesWithEntries);
  }

  Future<void> _onLoadTodayEntries(
    LoadTodayEntries event,
    Emitter<TensionState> emit,
  ) async {
    emit(const TensionLoading());
    try {
      final today = DateTime.now();
      final entries = await _tensionRepository.getEntriesByDate(today);
      final dates = await _tensionRepository.getDatesWithEntries();
      emit(
        TensionLoaded(
          entries: entries,
          selectedDate: today,
          datesWithEntries: dates,
        ),
      );
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }

  Future<void> _onLoadEntriesForDate(
    LoadEntriesForDate event,
    Emitter<TensionState> emit,
  ) async {
    final currentState = state;
    final isChartVisible = currentState is TensionLoaded
        ? currentState.isChartVisible
        : true;

    emit(const TensionLoading());
    try {
      final entries = await _tensionRepository.getEntriesByDate(event.date);
      final dates = await _tensionRepository.getDatesWithEntries();
      emit(
        TensionLoaded(
          entries: entries,
          selectedDate: event.date,
          isChartVisible: isChartVisible,
          datesWithEntries: dates,
        ),
      );
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }

  Future<void> _onAddEntry(
    AddTensionEntry event,
    Emitter<TensionState> emit,
  ) async {
    try {
      await _tensionRepository.addEntry(event.entry);
      if (state is TensionLoaded) {
        final currentState = state as TensionLoaded;
        final entries = await _tensionRepository.getEntriesByDate(
          currentState.selectedDate,
        );
        final dates = await _tensionRepository.getDatesWithEntries();
        emit(
          currentState.copyWith(
            entries: entries,
            datesWithEntries: dates,
            revision: currentState.revision + 1,
          ),
        );
      } else {
        // BLoC wasn't loaded yet – bootstrap with today's data
        final today = DateTime.now();
        final entries = await _tensionRepository.getEntriesByDate(today);
        final dates = await _tensionRepository.getDatesWithEntries();
        emit(
          TensionLoaded(
            entries: entries,
            selectedDate: today,
            datesWithEntries: dates,
            revision: 1,
          ),
        );
      }
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }

  Future<void> _onUpdateEntry(
    UpdateTensionEntry event,
    Emitter<TensionState> emit,
  ) async {
    try {
      await _tensionRepository.updateEntry(event.entry);
      if (state is TensionLoaded) {
        final currentState = state as TensionLoaded;
        final entries = await _tensionRepository.getEntriesByDate(
          currentState.selectedDate,
        );
        emit(
          currentState.copyWith(
            entries: entries,
            revision: currentState.revision + 1,
          ),
        );
      } else {
        final today = DateTime.now();
        final entries = await _tensionRepository.getEntriesByDate(today);
        final dates = await _tensionRepository.getDatesWithEntries();
        emit(
          TensionLoaded(
            entries: entries,
            selectedDate: today,
            datesWithEntries: dates,
            revision: 1,
          ),
        );
      }
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }

  Future<void> _onDeleteEntry(
    DeleteTensionEntry event,
    Emitter<TensionState> emit,
  ) async {
    try {
      await _tensionRepository.deleteEntry(event.entryId);
      if (state is TensionLoaded) {
        final currentState = state as TensionLoaded;
        final entries = await _tensionRepository.getEntriesByDate(
          currentState.selectedDate,
        );
        final dates = await _tensionRepository.getDatesWithEntries();
        emit(
          currentState.copyWith(
            entries: entries,
            datesWithEntries: dates,
            revision: currentState.revision + 1,
          ),
        );
      }
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }

  Future<void> _onToggleChart(
    ToggleChartVisibility event,
    Emitter<TensionState> emit,
  ) async {
    if (state is TensionLoaded) {
      final currentState = state as TensionLoaded;
      emit(currentState.copyWith(isChartVisible: !currentState.isChartVisible));
    }
  }

  Future<void> _onDeleteAllEntries(
    DeleteAllEntries event,
    Emitter<TensionState> emit,
  ) async {
    try {
      await _tensionRepository.deleteAllEntries();
      if (state is TensionLoaded) {
        final currentState = state as TensionLoaded;
        emit(
          currentState.copyWith(
            entries: [],
            datesWithEntries: [],
            revision: currentState.revision + 1,
          ),
        );
      }
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }

  Future<void> _onLoadDatesWithEntries(
    LoadDatesWithEntries event,
    Emitter<TensionState> emit,
  ) async {
    try {
      final dates = await _tensionRepository.getDatesWithEntries();
      if (state is TensionLoaded) {
        final currentState = state as TensionLoaded;
        emit(currentState.copyWith(datesWithEntries: dates));
      }
    } catch (e) {
      emit(TensionError(e.toString()));
    }
  }
}
