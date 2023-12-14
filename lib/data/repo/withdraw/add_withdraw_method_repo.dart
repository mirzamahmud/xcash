import 'dart:convert';
import 'package:xcash_app/core/utils/method.dart';
import 'package:xcash_app/core/utils/url_container.dart';
import 'package:xcash_app/data/model/authorization/authorization_response_model.dart';
import 'package:xcash_app/data/model/global/response_model/response_model.dart';
import 'package:xcash_app/data/model/withdraw/add_withdraw_method_response_model.dart';
import 'package:xcash_app/data/repo/kyc/kyc_repo.dart';
import 'package:xcash_app/data/services/api_service.dart';
import 'package:http/http.dart' as http;

class AddWithdrawMethodRepo {

  ApiClient apiClient;

  AddWithdrawMethodRepo({required this.apiClient});

  Future<ResponseModel> getData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.addWithdrawMethodUrl}";

    ResponseModel responseModel = await apiClient.request(
        url, Method.getMethod, null, passHeader: true);

    return responseModel;
  }

  List<Map<String, String>>fieldList = [];
  List<ModelDynamicValue>filesList = [];

  Future<AuthorizationResponseModel> submitData(String name,String methodId,String currencyId,List<FormModel> list) async {

    apiClient.initToken();
    await modelToMap(list);
    String url = '${UrlContainer.baseUrl}${UrlContainer.addWithdrawMethodUrl}';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String>finalMap = {};

    for (var element in fieldList) {
      finalMap.addAll(element);
    }

    request.headers.addAll(<String, String>{'Authorization': 'Bearer ${apiClient.token}'});

    request.fields.addAll({
      'name':name,
      'method_id':methodId,
      'currency_id':currencyId
    });

    for (var file in filesList) {
      request.files.add(http.MultipartFile(
          file.key ?? '', file.value.readAsBytes().asStream(), file.value.lengthSync(), filename: file.value.path.split('/').last));
    }

    request.fields.addAll(finalMap);

    http.StreamedResponse response = await request.send();

    String jsonResponse = await response.stream.bytesToString();
    AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(jsonResponse));

    return model;
  }

  Future<dynamic> modelToMap(List<FormModel> list) async
  {
    for (var e in list) {
      if (e.type == 'checkbox') {
        if (e.cbSelected != null && e.cbSelected!.isNotEmpty) {
          for (int i = 0; i < e.cbSelected!.length; i++) {
            fieldList.add({'${e.label}[$i]': e.cbSelected![i]});
          }
        }
      }
      else if (e.type == 'file') {
        if (e.imageFile != null) {
          filesList.add(ModelDynamicValue(e.label, e.imageFile!));
        }
      }
      else {
        if (e.selectedValue != null && e.selectedValue
            .toString()
            .isNotEmpty) {
          fieldList.add({e.label ?? '': e.selectedValue});
        }
      }
    }
  }
}