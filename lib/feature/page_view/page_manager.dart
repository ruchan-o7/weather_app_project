import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_with_chad_api/feature/current_city/current_city_view.dart';
import 'package:weather_with_chad_api/feature/current_city/current_city_view_model.dart';
import 'package:weather_with_chad_api/feature/page_view/page_manager_model.dart';
import 'package:weather_with_chad_api/feature/search_view/search_view.dart';
import 'package:weather_with_chad_api/product/models/base_model.dart/base_model.dart';
import 'package:weather_with_chad_api/product/models/forecast_model.dart';
import 'package:weather_with_chad_api/product/models/realtime_model.dart';
import 'package:weather_with_chad_api/product/network/network_manager.dart';
import 'package:weather_with_chad_api/product/network/weather_info_service.dart';

class PageManager extends StatelessWidget {
  PageManager({Key? key}) : super(key: key);
  ForeCastModel? foreCastModel;
  RealTimeModel? realTimeModel;
  int currentIndex = 0;
  List<BaseModel> list = [];
  var cityInputController = TextEditingController();
  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PageManagerCubit(list,
          GetWeatherInfoService(NetworkManager.instance), cityInputController),
      child: BlocConsumer<PageManagerCubit, PageManagerState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is WriteCityState) {
            return SearchView(
              controller: _controller,
              func: () {
                context.read<PageManagerCubit>().getData(_controller.text);
              },
            );
          } else if (state is ShowCitiesState) {
            return buildDataScaffold(state, context);
          } else if (state is LoadingState) {
            return centerCircular();
          } else {
            return centerCircular();
          }
        },
      ),
    );
  }

  Scaffold centerCircular() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildDataScaffold(ShowCitiesState state, BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromARGB(255, 211, 102, 0),
          Colors.yellow,
        ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                context.read<PageManagerCubit>().goToState(WriteCityState());
              },
              icon: Icon(Icons.menu_rounded)),
          title: Text("${DateFormat.yMMMMd("en-US").format(DateTime.now())}"),
        ),
        body: PageView.builder(
          itemBuilder: (context, index) {
            return CurrentCityView(
                currentIndex: currentIndex,
                model: state.list[index],
                index: index);
          },
          itemCount: state.list.length,
        ),

        // CurrentCityView(currentIndex: 0, index: 0, model: state.list.first),
      ),
    );
  }
}
