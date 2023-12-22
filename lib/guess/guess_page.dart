import 'package:flutter/material.dart';
// import 'package:flutter_first_station/storage/sp_storage.dart';
import 'guess_bar.dart';
import 'resultNotice.dart';
import 'dart:math';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key, required this.title});

  final String title;

  @override
  State<GuessPage> createState() => _GuessPageState();
}

// SingleTickerProviderStateMixin提供单个 Tickerer,若要在仅使用单个 AnimationController 的 State 中创建 AnimationController，请混合此类，然后传递给 vsync: this 动画控制器构造函数
// 为AutomaticKeepAlive的客户端提供便利方法的混合。与 State 子类一起使用,子类必须实现 wantKeepAlive，并且它们的构建方法必须调用 super.build
class _GuessPageState extends State<GuessPage> with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin{

  // AnimationController：Animation的一个子类，用来管理Animation
  late AnimationController controller;

  @override
  void initState() {
    // 当创建一个AnimationController时，需要传递一个vsync参数，存在vsync时会防止屏幕外动画消耗不必要的资源
    controller = AnimationController(
      // this指向的并不是State而是SingleTickerProviderStateMixin
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  int _value = 0;

  Random _random = Random();
  bool _guessing = false;
  bool? _isBig;

  @override
  void dispose() {
    _guessCtrl.dispose();
    super.dispose();
  }

  void _generateRandomValue() {
    setState(() {
      _guessing = true;
      _value = _random.nextInt(100);
    });
  }
  // TextEditingController 可编辑文本字段的控制器
  // 当用户使用关联的 TextEditingController 修改文本字段时，文本字段都会更新值
  TextEditingController _guessCtrl = TextEditingController();

  void _onCheck() {
    print('目标数值：$_value=====${_guessCtrl.text}');
    int ? guessValue = int.tryParse(_guessCtrl.text);
    // 开始或输入非整数，无视
    if(!_guessing || guessValue == null) return;
    controller.forward(from: 0);

    //  数字猜对了
    if(guessValue == _value) {
      setState(() {
        _isBig = null;
        _guessing = false;
      });
      return;
    }

    //  猜错了
    setState(() {
      _isBig = guessValue > _value;
    });
    _guessCtrl.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GuessAppBar(
        controller: _guessCtrl,
        onCheck: _onCheck,
      ),
      body:Stack(
        children: [
          if(_isBig!=null)
          Column(
            children: [
              // isBig! 是空安全的语法，如果一个可空对象 100% 确定非 null。可以通过 对象名! 表示 非空对象。 由于上面 if(_isBig) 才会走下方逻辑，所以使用处 100% 非空
              if(_isBig!)
              ResultNotice(color:Colors.redAccent,info:'大了',controller: controller),
              Spacer(),
              if(!_isBig!)
                ResultNotice(color:Colors.blueAccent,info:'小了',controller: controller),
            ],
          ),
          Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if(!_guessing)
                const Text('点击生成随机数'),
                Text(
                  _guessing ? '**' : '$_value',
                  style: const TextStyle(
                      fontSize: 68,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _guessing ? null : _generateRandomValue,
        backgroundColor: _guessing ? Colors.grey : Colors.blue,
        tooltip: 'Increment',
        child: const Icon(Icons.generating_tokens_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  // 当前实例是否应保持活动状态
  bool get wantKeepAlive => true;
}