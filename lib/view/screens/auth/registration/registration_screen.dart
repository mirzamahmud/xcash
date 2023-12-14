import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_images.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/core/utils/style.dart';
import 'package:xcash_app/data/controller/auth/auth/registration_controller.dart';
import 'package:xcash_app/data/repo/auth/general_setting_repo.dart';
import 'package:xcash_app/data/repo/auth/signup_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:xcash_app/view/components/app-bar/custom_appbar.dart';
import 'package:xcash_app/view/components/custom_loader/custom_loader.dart';
import 'package:xcash_app/view/components/custom_no_data_found_class.dart';
import 'package:xcash_app/view/components/will_pop_widget.dart';
import 'package:xcash_app/view/screens/auth/registration/widget/company_account_form.dart';
import 'package:xcash_app/view/screens/auth/registration/widget/personal_account_form.dart';
import 'package:xcash_app/view/screens/auth/registration/widget/select_account_type_widget.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(RegistrationRepo(apiClient: Get.find()));
    Get.put(RegistrationController(registrationRepo: Get.find(), generalSettingRepo: Get.find()));


    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RegistrationController>().initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) => WillPopWidget(
        nextRoute: RouteHelper.loginScreen,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: MyColor.getScreenBgColor(),
            appBar: const CustomAppBar(title: MyStrings.signUp,fromAuth: true),
            body: controller.noInternet ? NoDataOrInternetScreen(
              isNoInternet: true,
              onChanged: (value){
                controller.changeInternet(value);
              },
            ) : controller.isLoading ? const CustomLoader() : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.space30, horizontal: Dimensions.space15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*.02),
                  Center(child:Image.asset(MyImages.appLogo, height: 50, width: 225,color: MyColor.primaryColor,),),
                  SizedBox(height: MediaQuery.of(context).size.height*.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectAccountTypeWidget(
                          accountType: MyStrings.personalAccount,
                          imageSrc: MyImages.personalAcc,
                          isActive: controller.isActiveAccount,
                          press: (){
                            if(!controller.isActiveAccount){
                              controller.changeState(true);
                            }
                          },
                      ),
                      const SizedBox(width: Dimensions.space10),
                      SelectAccountTypeWidget(
                        accountType: MyStrings.companyAccount,
                        imageSrc: MyImages.companyAcc,
                        isActive: !controller.isActiveAccount,
                        press: (){
                          if(controller.isActiveAccount){
                            controller.changeState(false);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space25),
                  controller.isActiveAccount ? const PersonalAccountForm() : const CompanyAccountForm(),
                  const SizedBox(height: Dimensions.space30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(MyStrings.alreadyAccount.tr, style: regularLarge.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w500)),
                      const SizedBox(width: Dimensions.space5),
                      TextButton(
                        onPressed: (){
                          controller.clearAllData();
                          Get.offAndToNamed(RouteHelper.loginScreen);
                        },
                        child: Text(MyStrings.signIn.tr, style: regularLarge.copyWith(color: MyColor.getPrimaryColor())),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
