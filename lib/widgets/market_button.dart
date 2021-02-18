import '../public.dart';

class MarketButton extends StatefulWidget {
  MarketButton({
    Key key,
    this.text,
    this.showIcon = true,
    this.onTap,
    this.state,
  }) : super(key: key);

  String text;
  bool showIcon;
  MButtonState state;
  @required
  void Function(MButtonState) onTap;

  @override
  _MarketButtonState createState() => _MarketButtonState();
}

class _MarketButtonState extends State<MarketButton> {
  MButtonState state;
  @override
  void initState() {
    state = widget.state;
    // TODO: implement initState
    super.initState();
  }

  void _buttonClick() {
    MButtonState currentState = state;
    if (currentState == MButtonState.ButtonState_Normal) {
      currentState = MButtonState.ButtonState_Top;
    } else if (currentState == MButtonState.ButtonState_Top) {
      currentState = MButtonState.ButtonState_Bottom;
    } else if (currentState == MButtonState.ButtonState_Bottom) {
      currentState = MButtonState.ButtonState_Top;
    }
    setState(() {
      state = currentState;
    });
    widget.onTap(currentState);
  }

  Widget _getTextWidget() {
    return Container(
      child: Text(
        widget.text,
        style: TextStyle(
          color: Color(0xff777777),
          fontSize: OffsetWidget.setSp(12),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _getIconTextWidget() {
    MButtonState currentState = widget.state;
    String imgName = Constant.ASSETS_IMG;
    if (currentState == MButtonState.ButtonState_Normal) {
      imgName += "icon/icon_sort_normal.png";
    } else if (currentState == MButtonState.ButtonState_Top) {
      imgName += "icon/icon_sort_up.png";
    } else if (currentState == MButtonState.ButtonState_Bottom) {
      imgName += "icon/icon_sort_down.png";
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _getTextWidget(),
        OffsetWidget.hGap(4),
        LoadAssetsImage(
          imgName,
          fit: BoxFit.contain,
          scale: 2,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => {
              _buttonClick(),
            },
        child:
            widget.showIcon == false ? _getTextWidget() : _getIconTextWidget());
  }
}
