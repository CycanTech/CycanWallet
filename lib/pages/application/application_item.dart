import 'package:flutter_coinid/widgets/custom_network_image.dart';

import '../../public.dart';

class ApplicationItem extends StatelessWidget {
  const ApplicationItem({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  Widget build(BuildContext context) {
    String url = params["url"];
    String name = params["name"];
    String desc = params["desc"];
    String owners = params["owners"];

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LoadNetworkImage(
            url,
            placeholder: "",
            fit: BoxFit.cover,
            scale: 1,
            width: OffsetWidget.setSc(62),
            height: OffsetWidget.setSc(62),
          ),
        ),
        OffsetWidget.hGap(9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Color(0xFF000000),
                fontWeight: FontWightHelper.semiBold,
                fontSize: OffsetWidget.setSp(15),
              ),
            ),
            Text(
              desc,
              style: TextStyle(
                color: Color(0xFFFFA703),
                fontWeight: FontWightHelper.regular,
                fontSize: OffsetWidget.setSp(12),
              ),
            ),
            Text(
              owners,
              style: TextStyle(
                color: Color(0xFFACBBCF),
                fontWeight: FontWightHelper.regular,
                fontSize: OffsetWidget.setSp(12),
              ),
            )
          ],
        ),
      ],
    );
  }
}
