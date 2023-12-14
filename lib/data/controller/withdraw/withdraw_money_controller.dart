import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/my_color.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/data/model/global/response_model/response_model.dart';
import 'package:xcash_app/data/model/withdraw/submit_withdraw_money_response_model.dart';
import 'package:xcash_app/data/model/withdraw/withdraw_money_response_model.dart' as wm_model;
import 'package:xcash_app/data/repo/withdraw/withdraw_money_repo.dart';
import 'package:xcash_app/view/components/snack_bar/show_custom_snackbar.dart';

class WithdrawMoneyController extends GetxController{

  WithdrawMoneyRepo withdrawMoneyRepo;
  WithdrawMoneyController({required this.withdrawMoneyRepo});

  bool isLoading = true;
  wm_model.WithdrawMoneyResponseModel model = wm_model.WithdrawMoneyResponseModel();

  List<wm_model.Data> withdrawMoneyList = [];

  int page = 0;
  String? nextPageUrl;
  TextEditingController amountController = TextEditingController();

  String trx = "";

  wm_model.WithdrawMethod withdrawMethod = wm_model.WithdrawMethod();

  void initialData() async{
    page = 0;
    amountController.text = "";
    withdrawMoneyList.clear();
    isLoading = true;
    update();

    await loadData();
    isLoading = false;
    update();
  }

  Future<void> loadData() async{
    page = page + 1;

    if(page == 1){
      withdrawMoneyList.clear();
    }

    ResponseModel responseModel = await withdrawMoneyRepo.getData(page);
    if(responseModel.statusCode == 200){
      model = wm_model.WithdrawMoneyResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      nextPageUrl = model.data?.methods?.nextPageUrl;

      if(model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()){
        List<wm_model.Data>? tempWithdrawMoneyList = model.data?.methods?.data;
        if(tempWithdrawMoneyList != null && tempWithdrawMoneyList.isNotEmpty){
          withdrawMoneyList.addAll(tempWithdrawMoneyList);
        }
      }
      else{
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    }
    else{
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  bool hasNext(){
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null'? true : false;
  }

  bool submitLoading = false;
  Future<void> submitData({required String methodName, required String methodId, required String userMethodId}) async{

    String amount = amountController.text.toString();
    if(amount.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.enterAmountMsg]);
      return;
    }

    submitLoading = true;
    update();

    String withdrawMethodName = methodName;

    ResponseModel responseModel = await withdrawMoneyRepo.submitWithdrawMoney(
      methodId: methodId,
      userMethodId: userMethodId,
      amount: amount
    );

    if(responseModel.statusCode == 200){
      SubmitWithdrawMoneyResponseModel model = SubmitWithdrawMoneyResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if(model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()){
        trx = model.data?.trx ?? "";
        if(trx.isNotEmpty){
          Get.back();
          Get.toNamed(RouteHelper.withdrawPreviewScreen, arguments: [withdrawMethodName, trx, amountController.text]);
        } else{
          Get.back();
          Get.toNamed(RouteHelper.withdrawHistoryScreen);
        }
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

  dynamic getStatusOrColor(int index,{bool isStatus = true}){
    String status = withdrawMoneyList[index].status??'';

    if(isStatus){
      String text = status == "0" ? MyStrings.disabled
          : status == "1" ? MyStrings.enabled : "";
      return text;
    } else{
      Color color = status == "0" ? MyColor.colorOrange
          : status == "1" ? MyColor.colorGreen : MyColor.colorGreen;
      return color;
    }
  }
}