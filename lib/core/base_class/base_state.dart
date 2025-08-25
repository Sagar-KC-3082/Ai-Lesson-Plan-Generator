import 'failure_response.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/29/2023, Wednesday

abstract class BaseState {}

class InitialState extends BaseState {}

class LoadingState extends BaseState {}

class SuccessState<T> extends BaseState {
  final T data;

  SuccessState({required this.data});
}

class FailureState extends BaseState {
  final FailureResponse failureResponse;

  FailureState({required this.failureResponse});
}
