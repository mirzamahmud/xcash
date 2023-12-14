import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_images.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/core/utils/style.dart';
import 'package:xcash_app/data/controller/withdraw/withdraw_history_controller.dart';
import 'package:xcash_app/data/repo/withdraw/withdraw_history_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:xcash_app/view/components/app-bar/action_button_icon_widget.dart';
import 'package:xcash_app/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:xcash_app/view/components/custom_loader/custom_loader.dart';
import 'package:xcash_app/view/components/no_data.dart';
import 'package:xcash_app/view/screens/withdrawals/withdraw_history/widget/withdraw_details_bottom_sheet.dart';
import 'package:xcash_app/view/screens/withdrawals/withdraw_history/widget/withdraw_log_card.dart';
import 'package:xcash_app/view/screens/withdrawals/withdraw_history/widget/withdraw_log_top.dart';

class WithdrawHistoryScreen extends StatefulWidget {
  const WithdrawHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawHistoryScreen> createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (Get.find<WithdrawHistoryController>().hasNext()) {
        Get.find<WithdrawHistoryController>().loadData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WithdrawHistoryRepo(apiClient: Get.find()));
    final controller = Get.put(WithdrawHistoryController(withdrawHistoryRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawHistoryController>(
      builder: (controller) => SafeArea(
        child: Scaffold(
          backgroundColor: MyColor.screenBgColor,
          appBar: AppBar(
            title: Text(MyStrings.withdrawHistory.tr,
                style: regularDefault.copyWith(
                color: MyColor.getAppBarContentColor())),
            backgroundColor: MyColor.getAppBarColor(),
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back,
                  size: 20, color: MyColor.getAppBarContentColor()),
            ),
            actions: [
              ActionButtonIconWidget(
                  pressed: () => controller.changeSearchStatus(),
                  icon: controller.isSearch ? Icons.clear : Icons.search,
              ),
              ActionButtonIconWidget(
                isImage: true,
                pressed: () => Get.toNamed(RouteHelper.withdrawMoneyScreen),
                imageSrc: MyImages.withdrawMethod,
              ),
              const SizedBox(width: 10)
            ],
          ),
          body: controller.isLoading ? const CustomLoader() : Padding(
                  padding: const EdgeInsets.only(top: Dimensions.space20, left: Dimensions.space15, right: Dimensions.space15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: controller.isSearch,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            WithdrawLogTop(),
                            SizedBox(height: Dimensions.space15),
                          ],
                        ),
                      ),
                      Expanded(
                        child: controller.withdrawList.isEmpty && controller.filterLoading == false ? const Center(
                          child: NoDataWidget(),
                        ) : controller.filterLoading ? const CustomLoader() : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          controller: scrollController,
                          itemCount: controller.withdrawList.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                          itemBuilder: (context, index) {
                            if (controller.withdrawList.length == index) {
                              return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                            }

                            return WithdrawLogCard(
                              index: index,
                              press: (){
                                CustomBottomSheet(
                                  child: WithdrawDetailsBottomSheet(index: index)
                                ).customBottomSheet(context);
                              },
                            );
                        },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
