import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/helper/string_format_helper.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/data/model/authorization/authorization_response_model.dart';
import 'package:xcash_app/data/model/global/response_model/response_model.dart';
import 'package:xcash_app/data/model/request_money/request_money/request_money_response_model.dart';
import 'package:xcash_app/data/model/transfer/check_user_response_model.dart';
import 'package:xcash_app/data/repo/request_money/request_money_repo.dart';
import 'package:xcash_app/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:xcash_app/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:xcash_app/view/screens/request-money/request_money/widget/request_money_bottom_sheet.dart';

class RequestMoneyController extends GetxController{

  RequestMoneyRepo requestMoneyRepo;
  RequestMoneyController({required this.requestMoneyRepo});

  bool isLoading = true;
  String currency = "";

  RequestMoneyResponseModel model = RequestMoneyResponseModel();

  Wallets? selectedWallet = Wallets();
  String totalCharge = "";
  String limit = "";

  TextEditingController amountController = TextEditingController();
  TextEditingController requestToController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  final FocusNode amountFocusNode = FocusNode();

  List<Wallets> walletList = [];

  setWalletMethod(Wallets? wallets){
    selectedWallet = wallets;
    currency = selectedWallet?.id == -1 ? "" : selectedWallet?.currencyCode ?? "";
    limit = selectedWallet?.id.toString() == "-1" ? "0" : selectedWallet?.currency?.moneyRequestLimit ?? "";
    String amt = amountController.text.toString();
    mainAmount = amt.isEmpty ? 0 : double.tryParse(amt) ?? 0;
    changeInfoWidget(mainAmount);
    update();
  }


  Future<void> loadData() async{
    isLoading = true;
    update();

    ResponseModel responseModel = await requestMoneyRepo.getWalletData();
    walletList.clear();

    hasAgent                 = false;
    validUser                = "";
    invalidUser              = "";
    isAgentFound             = false;
    amountController.text    = "";
    requestToController.text = "";
    noteController.text      = "";
    charge                   = '';
    mainAmount               = 0;
    payableText              = '';

    selectedWallet = Wallets(id: -1, currencyCode: MyStrings.selectWallet);
    walletList.insert(0, selectedWallet!);
    setWalletMethod(selectedWallet);

    if(responseModel.statusCode == 200){
      model = RequestMoneyResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if(model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()){
        List<Wallets>? tempWalletList = model.data?.wallets;
        if(tempWalletList != null && tempWalletList.isNotEmpty){
          walletList.addAll(tempWalletList);
        }
      } else{
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    }
    else{
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  bool submitLoading = false;
  Future<void> submitRequest() async{

    submitLoading = true;
    update();

    String amount   = amountController.text;
    String walletId = selectedWallet?.id.toString() ?? "";
    String username = requestToController.text;
    String note     = noteController.text;

    ResponseModel responseModel = await requestMoneyRepo.submitRequestMoney(walletId: walletId, amount: amount, username: username,note:note);
    if(responseModel.statusCode == 200){
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if(model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()){
        Get.back();
        loadData();
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      }
      else{
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    }
    else{
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    submitLoading = false;
    update();
  }

  double mainAmount = 0;
  String charge = "";
  String payableText = '';
  void changeInfoWidget(double amount){
    if(selectedWallet?.id.toString() == "-1"){
      return ;
    }

    mainAmount = amount;

    double rate           = double.tryParse(selectedWallet?.currency?.rate ?? "0") ?? 0;
    double percent        = double.tryParse(model.data?.transferCharge?.percentCharge ?? "0") ?? 0;
    double percentCharge  = amount * percent / 100;
    double temCharge      = double.tryParse(model.data?.transferCharge?.fixedCharge ?? "0") ?? 0;
    double fixedCharge    = temCharge / rate;
    double totalCharge    = percentCharge + fixedCharge;
    double cap            = double.tryParse(model.data?.transferCharge?.cap ?? "0") ?? 0;
    double mainCap        = cap/rate;

    if(cap != 1 && totalCharge > mainCap){
      totalCharge = mainCap;
    }

    charge                = '${Converter.formatNumber('$totalCharge',precision: selectedWallet?.currency?.currencyType == '2'? 8:2)} $currency';
    double payable        = amount - totalCharge;
    payableText           = '${Converter.formatNumber( payable.toString(),precision: selectedWallet?.currency?.currencyType == '2'? 8:2)} $currency';
    update();
  }

  bool hasAgent       = false;
  String validUser    = "";
  String invalidUser  = "";
  bool? isAgentFound;

  Future<void> checkUserFocus(bool hasFocus) async{
    hasAgent = hasFocus;
    update();

    String user                 = requestToController.text;
    ResponseModel responseModel = await requestMoneyRepo.checkUser(user: user);

    if(responseModel.statusCode == 200){
      CheckUserResponseModel model = CheckUserResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if(model.status.toString().toLowerCase() == "success"){
        isAgentFound = true;
        validUser    = MyStrings.validUserMsg.tr;
        update();
      }
      else{
        isAgentFound = false;
        invalidUser  = Converter.removeQuotationAndSpecialCharacterFromString(model.message?.error.toString().tr ?? MyStrings.invalidUserMsg.tr);
        update();
      }
    }
    else{
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  void checkValidation(BuildContext context) {
    if(selectedWallet?.id.toString() == "-1"){
      CustomSnackBar.error(errorList: [MyStrings.selectAWallet]);
      return ;
    }
    else if(amountController.text.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.enterAmountMsg]);
      return ;
    }
    else if(requestToController.text.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.enterEmailOrUserName]);
      return ;
    }
    else{
      CustomBottomSheet(child: const RequestMoneyBottomSheet()).customBottomSheet(context);
    }
  }
}