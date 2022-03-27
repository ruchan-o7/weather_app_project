import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../product/models/base_model.dart/base_model.dart';
import '../../product/network/weather_info_service.dart';

class PageManagerCubit extends Cubit<PageManagerState> {
  PageManagerCubit(this.baseModelList, this.service, this.cityInputCont)
      : super(PageManagerInitial()) {
    redirect();
  }
  List<BaseModel> baseModelList;
  TextEditingController cityInputCont;
  List<String> _searchedCities = [];

  IGetWeatherInfoService service;
  BaseModel? oldModel;
  BaseModel? newModel;
  void goToState(PageManagerState state) {
    emit(state);
  }

  void redirect() {
    if (baseModelList.isEmpty) {
      emit(EmptyListState());
    } else {
      emit(ShowCitiesState(list: baseModelList));
    }
  }

  Future<dynamic> getCityData(String city, BuildContext context) async {
    for (var i = 0; i < baseModelList.length; i++) {
      if (city == _searchedCities[i]) {
        return ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("City already added")));
      }
    }
    _searchedCities.add(city);
    emit(LoadingState());
    if (oldModel == null) {
      oldModel = await service.getAsBaseModel(city);
      if (oldModel != null) {
        baseModelList.insert(0, oldModel!);
        emit(ShowCitiesState(list: baseModelList));
      }
    } else {
      if (oldModel != newModel) {
        newModel = await service.getAsBaseModel(city);
        if (newModel != null) {
          baseModelList.insert(0, newModel!);

          emit(ShowCitiesState(list: baseModelList));
        } else {
          emit(ErrorState());
        }
      }
      return;
    }
  }
}

abstract class PageManagerState {}

class PageManagerInitial extends PageManagerState {}

class WriteCityState extends PageManagerState {}

class ShowCitiesState extends PageManagerState {
  List<BaseModel> list;
  ShowCitiesState({
    required this.list,
  });
}

class LoadingState extends PageManagerState {}

class ErrorState extends PageManagerState {}

class EmptyListState extends PageManagerState {}
