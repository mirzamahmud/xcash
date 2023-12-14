import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/helper/string_format_helper.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/core/utils/style.dart';
import 'package:xcash_app/data/controller/wallet/wallet_controller.dart';
import 'package:xcash_app/data/repo/wallet/wallet_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:xcash_app/view/components/app-bar/custom_appbar.dart';
import 'package:xcash_app/view/components/custom_loader/custom_loader.dart';
import 'package:xcash_app/view/components/divider/custom_divider.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WalletRepo(apiClient: Get.find()));
    final controller = Get.put(WalletController(walletRepo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadWalletData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<WalletController>(
      builder: (controller) => SafeArea(
        child: Scaffold(
          backgroundColor: MyColor.screenBgColor,
          appBar: CustomAppBar(
            title: MyStrings.myWallet.tr,
            isShowBackBtn: true,
            bgColor: MyColor.getAppBarColor(),
          ),
          body: controller.isLoading ? const CustomLoader() : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
            physics: const ClampingScrollPhysics(),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: controller.walletList.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width > 400 ? 2 : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) => Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.space12, horizontal: Dimensions.space15),
                decoration: BoxDecoration(color: MyColor.getCardBgColor(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius),/*boxShadow: MyUtils.getCardShadow()*/),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 30, width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: MyColor.getSymbolColor(index), shape: BoxShape.circle),
                      child: Text(
                        controller.walletList[index].currency?.currencySymbol ?? "",
                        style: regularLarge.copyWith(color: MyColor.colorWhite),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space10),
                    Expanded(
                      child: Row(
                          children: [
                            Expanded(child: Text(
                               '${ Converter.formatNumber(controller.walletList[index].balance ?? "",precision: controller.walletList[index].currency?.currencyType=='2'?8:2)} ${controller.walletList[index].currency?.currencyCode ?? ""}',
                                style: regularLarge.copyWith(fontWeight: FontWeight.w600)
                            )),
                            const SizedBox(width: Dimensions.space5),
                          ]
                      ),
                    ),

                    controller.walletRepo.apiClient.getModuleStatus('transfer_money')?const CustomDivider(space: Dimensions.space15):const SizedBox(),
                    controller.walletRepo.apiClient.getModuleStatus('transfer_money')?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          MyStrings.transferMoney.tr,
                          style: regularSmall.copyWith(color: MyColor.contentTextColor),
                        ),
                        GestureDetector(
                          onTap: (){
                            Get.toNamed(RouteHelper.transferMoneyScreen, arguments: controller.walletList[index].id.toString());
                          },
                          child: Container(
                            height: 30, width: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward, color: MyColor.primaryColor, size: 15),
                          ),
                        )
                      ],
                    ):const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
