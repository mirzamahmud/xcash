import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_images.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/core/utils/style.dart';
import 'package:xcash_app/data/controller/add_money/add_money_method_controller.dart';
import 'package:xcash_app/data/model/add_money/add_money_method_response_model.dart';
import 'package:xcash_app/data/repo/add_money/add_money_method_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:xcash_app/view/components/app-bar/custom_appbar.dart';
import 'package:xcash_app/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:xcash_app/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:xcash_app/view/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:xcash_app/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:xcash_app/view/components/buttons/rounded_button.dart';
import 'package:xcash_app/view/components/buttons/rounded_loading_button.dart';
import 'package:xcash_app/view/components/card/bottom_sheet_card.dart';
import 'package:xcash_app/view/components/custom_loader/custom_loader.dart';
import 'package:xcash_app/view/components/text-form-field/custom_amount_text_field.dart';
import 'package:xcash_app/view/components/text/label_text.dart';
import 'package:xcash_app/view/screens/add-money/add_money/widget/add_money_info_widget.dart';
import 'package:xcash_app/view/screens/transaction/widget/filter_row_widget.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({Key? key}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {

  @override
  void initState() {

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(AddMoneyMethodRepo(apiClient: Get.find()));
    final controller = Get.put(AddMoneyMethodController(addMoneyMethodRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return GetBuilder<AddMoneyMethodController>(
      builder: (controller) => SafeArea(
          child: Scaffold(
            backgroundColor: MyColor.getScreenBgColor(),
            appBar: CustomAppBar(title:MyStrings.addMoney,isShowActionBtn: true,actionIcon: MyImages.moneyHistory,actionPress: (){
              Get.toNamed(RouteHelper.addMoneyHistoryScreen);
            }, ),
            body: controller.isLoading ? const CustomLoader() : SingleChildScrollView(
              padding: Dimensions.screenPaddingHV,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LabelText(text: MyStrings.selectWallet),
                  const SizedBox(height: Dimensions.textToTextSpace),
                  FilterRowWidget(
                      borderColor: controller.selectedWallet?.id.toString() == "-1" ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor,
                      text: "${controller.selectedWallet?.id.toString() == "-1" ? MyStrings.selectWallet : controller.selectedWallet?.currencyCode}",
                      press: () {
                        FocusScope.of(context).unfocus();
                        CustomBottomSheet(
                            child: Column(
                              children: [
                                const BottomSheetHeaderRow(header: ''),
                                const SizedBox(height: Dimensions.space15),
                                ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.walletList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          final controller = Get.find<AddMoneyMethodController>();
                                          AddMoneyWallets selectedValue = controller.walletList[index];
                                          controller.setWallet(selectedValue);
                                          Navigator.pop(context);

                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                        },
                                        child: BottomSheetCard(
                                          child: Text(
                                            controller.walletList[index].currencyCode.toString().tr,
                                            style: regularDefault,
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            )
                        ).customBottomSheet(context);
                      }
                  ),
                  const SizedBox(height: Dimensions.space20),
                  const LabelText(text: MyStrings.selectGateway),
                  const SizedBox(height: Dimensions.textToTextSpace),
                  FilterRowWidget(
                      borderColor: controller.selectedGateway?.id.toString() == "-1" ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor,
                      text: "${controller.selectedGateway?.id.toString() == "-1" ? MyStrings.selectGateway : controller.selectedGateway?.name}",
                      press: () {
                        FocusScope.of(context).unfocus();
                        CustomBottomSheet(
                            child: Column(
                              children: [
                                const BottomSheetBar(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    BottomSheetCloseButton()
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space15),
                                ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.gatewayList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          final controller= Get.find<AddMoneyMethodController>();
                                          Gateways selectedValue = controller.gatewayList[index];
                                          controller.setGatewayMethod(selectedValue);
                                          Navigator.pop(context);

                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                        },
                                        child:BottomSheetCard(
                                          child:Text(
                                            controller.gatewayList[index].name?.tr.toString() ?? "",
                                            style: regularDefault,
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            )
                        ).customBottomSheet(context);
                      }
                  ),
                  const SizedBox(height: Dimensions.space20),

                  CustomAmountTextField(
                    labelText: MyStrings.amount.tr,
                    hintText: MyStrings.amountHint.tr,
                    currency: controller.currency,
                    controller: controller.amountController,
                    onChanged: (value){
                      if(value.toString().isEmpty){
                        controller.changeInfoWidgetValue(0);
                      }else{
                        double amount = double.tryParse(value.toString())??0;
                        controller.changeInfoWidgetValue(amount);
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.space5),
                  Text(
                    "${MyStrings.depositLimit.tr}: ${controller.depositMinLimit} - ${controller.depositMaxLimit} ${controller.currency}",
                    style: regularExtraSmall.copyWith(color: MyColor.getPrimaryColor(), fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: Dimensions.space20),
                  controller.mainAmount > 0 ? const AddMoneyInfoWidget() : const SizedBox(),
                  const SizedBox(height: Dimensions.space30),
                  controller.submitLoading ? const RoundedLoadingBtn() : RoundedButton(
                    press: (){
                      controller.submitData();
                    },
                    text: MyStrings.proceed,
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}

