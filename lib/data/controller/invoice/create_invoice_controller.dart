import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/helper/string_format_helper.dart';
import 'package:xcash_app/core/route/route.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/data/model/authorization/authorization_response_model.dart';
import 'package:xcash_app/data/model/global/response_model/response_model.dart';
import 'package:xcash_app/data/model/invoice/create_invoice_response_model.dart';
import 'package:xcash_app/data/model/invoice/invoice_items_model.dart';
import 'package:xcash_app/data/repo/invoice/create_invoice_repo.dart';
import 'package:xcash_app/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:xcash_app/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:xcash_app/view/screens/invoice/create_invoice/widget/create_invoice_bottom_sheet.dart';
import 'package:xcash_app/view/screens/invoice/create_invoice/widget/invoice_items.dart';

class CreateInvoiceController extends GetxController{

  CreateInvoiceRepo createInvoiceRepo;
  CreateInvoiceController({required this.createInvoiceRepo});

  final formKey = GlobalKey<FormState>();

  bool isLoading = true;

  CreateInvoiceResponseModel model = CreateInvoiceResponseModel();
  Currencies? selectedCurrency = Currencies();

  List<Currencies> currencyList = [];
  List<InvoiceItemsModel> invoiceItemList = [];

  TextEditingController invoiceToController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  TextEditingController itemController = TextEditingController();
  TextEditingController amountController = TextEditingController();


  void increaseNumberField(){
    invoiceItemList.add(InvoiceItemsModel(itemNameController: TextEditingController(), amountController: TextEditingController()));
    update();
  }

  void decreaseNumberField(int index){
    invoiceItemList.removeAt(index);
    calculateInvoiceAmount();
    update();
  }

  String  totalInvoiceAmount = '';
  String charge = '';
  String payableText = '';

  void calculateInvoiceAmount(){

    double totalAmount = 0;

    double firstInvoiceAmount = double.tryParse(amountController.text.toString())??0;
    totalAmount = totalAmount + firstInvoiceAmount ;

    for (var invoice in invoiceItemList) {
      double  invoiceAmount = double.tryParse(invoice.amountController.text)??0;
      totalAmount = totalAmount + invoiceAmount;
    }

    totalInvoiceAmount = '${Converter.formatNumber(totalAmount.toString(),precision:selectedCurrency?.currencyType == '2'? 8:2 )} ${selectedCurrency?.currencyCode??''}';


    //for preview bottom sheet
    double currencyRate = double.tryParse(selectedCurrency?.rate ?? "0") ?? 0;
    double percent = double.tryParse(model.data?.invoiceCharge?.percentCharge ?? "0") ?? 0;
    double percentCharge = totalAmount * percent / 100;
    double temCharge = double.tryParse(model.data?.invoiceCharge?.fixedCharge ?? "0") ?? 0;
    double fixedCharge = temCharge / currencyRate;

    double totalCharge = percentCharge + fixedCharge;
    double cap = double.tryParse(model.data?.invoiceCharge?.cap ?? "0") ?? 0;
    double mainCap = cap/currencyRate;

    if(cap != 1 && totalCharge > mainCap){
      totalCharge = mainCap;
    }

    charge = '${Converter.formatNumber('$totalCharge',precision: selectedCurrency?.currencyType == '2'? 8:2)} ${selectedCurrency?.currencyCode??''}';
    double payable = totalAmount - totalCharge;
    payableText = '${Converter.formatNumber( payable.toString(),precision: selectedCurrency?.currencyType == '2'? 8:2)} ${selectedCurrency?.currencyCode??''}';

    update();
  }



  setSelectedCurrency(Currencies? currencies){
    selectedCurrency = currencies;
    calculateInvoiceAmount();
    update();
  }

  Future<void> loadData() async{

    isLoading = true;
    update();

    currencyList.clear();

    invoiceToController.text = "";
    emailController.text = "";
    addressController.text = "";
    invoiceItemList.clear();

    itemController.text = '';
    amountController.text = '';


    selectedCurrency = Currencies(id: -1, currencyCode: MyStrings.selectOne);
    currencyList.insert(0, selectedCurrency!);
    setSelectedCurrency(selectedCurrency);

    ResponseModel responseModel = await createInvoiceRepo.getData();
    if(responseModel.statusCode == 200){
      model = CreateInvoiceResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if(model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()){
        List<Currencies>? tempCurrencyList = model.data?.currencies;
        if(tempCurrencyList != null && tempCurrencyList.isNotEmpty){
          currencyList.addAll(tempCurrencyList);
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

  Future <void> confirmInvoice() async{

    String invoiceTo = invoiceToController.text.toString();
    String email = emailController.text.toString();
    String address = addressController.text.toString();
    String curId = selectedCurrency?.id.toString()??'';

    if(invoiceTo.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceFieldErrorMsg]);
      return ;
    }

    if(email.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceEmailFieldErrorMsg]);
      return ;
    }

    if(address.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceAddressFieldErrorMsg]);
      return ;
    }

    if(curId == "0"){
      CustomSnackBar.error(errorList: [MyStrings.invoiceWalletErrorMsg]);
      return ;
    }


      CustomBottomSheet(child: const CreateInvoicePreviewBottomSheet()).customBottomSheet(Get.context!);

  }

  bool isSubmitLoading = false;
  Future <void> submitInvoice() async{


    String invoiceTo = invoiceToController.text.toString();
    String email = emailController.text.toString();
    String address = addressController.text.toString();
    String curId = selectedCurrency?.id.toString()??'';

    if(invoiceTo.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceFieldErrorMsg]);
      return ;
    }
    if(email.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceEmailFieldErrorMsg]);
      return ;
    }
    if(address.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceAddressFieldErrorMsg]);
      return ;
    }
    if(curId == "0"){
      CustomSnackBar.error(errorList: [MyStrings.invoiceWalletErrorMsg]);
      return ;
    }

    String firstInvoice = itemController.text.toString();
    String firstInvoiceAmount = amountController.text.toString();

    if(firstInvoice.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceItemNameErrorMsg]);
      return ;
    } if(firstInvoiceAmount.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.invoiceAmountErrorMsg]);
      return ;
    }

    isSubmitLoading = true;
    update();

    ResponseModel responseModel = await createInvoiceRepo.createInvoice(invoiceTo,email,address,curId,firstInvoice,firstInvoiceAmount,invoiceItemList);
    if(responseModel.statusCode == 200){
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if(model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()){
        Get.offAndToNamed(RouteHelper.invoiceScreen);
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      }
      else{
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    }
    else{
      CustomSnackBar.error(errorList: [responseModel.message]);
      return ;
    }

    isSubmitLoading = false;
    update();
  }

  void checkValidation(BuildContext context) {


    if(selectedCurrency?.id.toString() == "-1"){
      CustomSnackBar.error(errorList: [MyStrings.selectAWallet]);
    }
    else{
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => InvoiceItems(
                invoiceTo: invoiceToController.text,
                email: emailController.text,
                address: addressController.text,
                selectWallet: selectedCurrency?.currencyCode ?? "",
              )
          )
      );
    }
  }
}