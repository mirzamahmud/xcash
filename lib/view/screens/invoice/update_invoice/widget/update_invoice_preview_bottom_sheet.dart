import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xcash_app/core/utils/dimensions.dart';
import 'package:xcash_app/core/utils/my_strings.dart';
import 'package:xcash_app/data/controller/invoice/update_invoice_controller.dart';
import 'package:xcash_app/view/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:xcash_app/view/components/buttons/rounded_button.dart';
import 'package:xcash_app/view/components/buttons/rounded_loading_button.dart';
import 'package:xcash_app/view/components/divider/custom_divider.dart';
import 'package:xcash_app/view/components/row_widget/bottom_sheet_row.dart';

class UpdateInvoicePreviewBottomSheet extends StatelessWidget {
  const UpdateInvoicePreviewBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateInvoiceController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHeaderRow(header: MyStrings.invoicePreview),
          const SizedBox(height: Dimensions.space15),
          BottomSheetRow(
            header: MyStrings.totalAmount,
            body: controller.totalInvoiceAmount,
          ),
          const SizedBox(height: Dimensions.space10),
          BottomSheetRow(
            header: MyStrings.totalCharge,
            body: controller.charge,
          ),
          const CustomDivider(space: 15),
          BottomSheetRow(
            header: MyStrings.willGet,
            body: controller.payableText,
          ),
          const SizedBox(height: Dimensions.space30),
          controller.submitLoading ? const RoundedLoadingBtn() : RoundedButton(
            text: MyStrings.confirm,
            press: (){
                controller.updateInvoice();
              }
          )
        ],
      ),
    );
  }
}
