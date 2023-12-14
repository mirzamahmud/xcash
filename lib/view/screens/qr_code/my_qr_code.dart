import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_images.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/core/utils/style.dart';
import 'package:xcash_app/data/controller/qr_code/qr_code_controller.dart';
import 'package:xcash_app/data/repo/qr_code/qr_code_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:xcash_app/view/components/app-bar/action_button_icon_widget.dart';
import 'package:xcash_app/view/components/buttons/rounded_button.dart';
import 'package:xcash_app/view/components/custom_loader/custom_loader.dart';

class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({Key? key}) : super(key: key);

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {

  @override
  void initState() {

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(QrCodeRepo(apiClient: Get.find()));
    final controller = Get.put(QrCodeController(qrCodeRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QrCodeController>(
      builder: (controller) => SafeArea(
          child: Scaffold(
            backgroundColor: MyColor.primaryColor,
            appBar: AppBar(
              elevation: 0,
              titleSpacing: 0,
              backgroundColor: MyColor.appBarColor,
              title: Text(MyStrings.myQrCode.tr, style: regularDefault.copyWith(color: MyColor.appBarContentColor)),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: MyColor.appBarContentColor, size: 20),
              ),
              actions: [
                ActionButtonIconWidget(
                  pressed: (){
                    Get.toNamed(RouteHelper.qrCodeScanner);
                  },
                  icon: Icons.qr_code_outlined,
                  iconColor: MyColor.primaryColor,
                ),
                const SizedBox(width: 10)
              ],
            ),
            body: controller.isLoading ? const CustomLoader(loaderColor: MyColor.colorWhite) : SingleChildScrollView(
              padding: Dimensions.screenPaddingHV,
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MyColor.primaryColor,
                  borderRadius: BorderRadius.circular(Dimensions.defaultRadius)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: Dimensions.space20),
                    Container(
                      height: 60, width: 60,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: AssetImage(MyImages.profile), fit: BoxFit.fill)
                      ),
                    ),
                    const SizedBox(height: Dimensions.space15),
                    Text(
                      controller.username,
                      style: semiBoldExtraLarge.copyWith(color: MyColor.colorWhite),
                    ),
                    const SizedBox(height: Dimensions.space30),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColor.transparentColor,
                        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                      ),
                      child: Image.network(
                          controller.qrCode,
                          width: 220,
                          height: 220,
                          errorBuilder: (ctx,object,trx) {
                        return Image.asset(
                          MyImages.placeHolderImage,
                          fit: BoxFit.cover,
                          width: 220, height: 220,
                        );
                      }),
                    ),
                    const SizedBox(height: Dimensions.space30),
                   Row(
                     children: [
                       Expanded(child: RoundedButton(
                           color: MyColor.colorWhite,
                           text: MyStrings.download.tr,
                           textColor: MyColor.primaryColor,
                           press: ()async{
                             controller.downloadImage();
                           }
                       )),
                       const SizedBox(width: Dimensions.space12,),
                       Expanded(child: RoundedButton(
                           color: MyColor.colorBlack,
                           text: MyStrings.share.tr,
                           textColor: MyColor.colorWhite,
                           press: (){
                             controller.shareImage();
                           }
                       )),
                     ],
                   ),
                    const SizedBox(height: Dimensions.space15)
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}