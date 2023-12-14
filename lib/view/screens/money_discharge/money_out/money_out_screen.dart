import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/data/controller/money_discharge/money_out/money_out_controller.dart';
import 'package:xcash_app/data/repo/money_discharge/money_out/money_out_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:xcash_app/view/components/app-bar/custom_appbar.dart';
import 'package:xcash_app/view/components/custom_loader/custom_loader.dart';
import 'package:xcash_app/view/screens/money_discharge/money_out/widget/money_out_form.dart';

class MoneyOutScreen extends StatefulWidget {
  const MoneyOutScreen({Key? key}) : super(key: key);

  @override
  State<MoneyOutScreen> createState() => _MoneyOutScreenState();
}

class _MoneyOutScreenState extends State<MoneyOutScreen> {

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(MoneyOutRepo(apiClient: Get.find()));
    final controller = Get.put(MoneyOutController(moneyOutRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      String userType = Get.arguments ?? "";
      controller.loadData(userType);
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MoneyOutController>(
      builder: (controller) => SafeArea(
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(
            isShowBackBtn: true,
            title: MyStrings.moneyOut.tr,
            bgColor: MyColor.getAppBarColor(),
          ),
          body: controller.isLoading ? const CustomLoader() : const SingleChildScrollView(
            padding: Dimensions.screenPaddingHV,
            child: MoneyOutForm(),
          ),
        ),
      )
    );
  }
}

