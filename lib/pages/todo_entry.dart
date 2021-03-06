import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/colors.dart';
import 'package:todo_list/model/network_client.dart';
import 'package:todo_list/model/todo.dart';
import 'package:todo_list/model/todo_list.dart';
import 'package:todo_list/pages/calendart.dart';
import 'package:todo_list/pages/reporter.dart';
import 'package:todo_list/pages/route_url.dart';
import 'package:todo_list/pages/about.dart';
import 'package:todo_list/pages/todo_list.dart';

class TodoEntryPage extends StatefulWidget {
  final TodoEntryPageArgument argument;

  TodoEntryPage({Key key, this.argument}) : super(key: key);

  _TodoEntryState createState() => _TodoEntryState();
}

class _TodoEntryState extends State<TodoEntryPage> with WidgetsBindingObserver {

  int currentIndex;
  List<TabConfig> _tabConfigs;
  TodoList _todoList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentIndex = 0;
    _todoList = TodoList(widget.argument.email);
    _tabConfigs = [
      TabConfig(title: '你的清单', page: TodoListPage(), imagePath: 'assets/images/lists.png'),
      TabConfig(title: '日历', page: CalendarPage(todoList: _todoList), imagePath: 'assets/images/calendar.png'),
      TabConfig(title: '', page: Container(), imagePath: 'assets/images/add.png', size: 50, singleImage: true),
      TabConfig(title: '任务回顾', page: ReporterPage(todoList: _todoList), imagePath: 'assets/images/report.png'),
      TabConfig(title: '关于', page: AboutPage(todoList: _todoList, email: widget.argument.email), imagePath: 'assets/images/settings.png'),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      NetworkClient.instance().uploadList(_todoList.list, widget.argument.email);
    }
    if (state == AppLifecycleState.resumed) {
      _todoList.syncWithNetwork();
    }
    super.didChangeAppLifecycleState(state);
  }

  void onTabChange(int index) async {
    if (mounted) {
      if (index == 2) {
        Todo todo = await Navigator.of(context).pushNamed(EDIT_TODO_PAGE_URL, arguments: EditTodoPageArgument(openType: OpenType.Add));
        if (todo != null) {
          _todoList.add(todo);
          index = 0;
        } else {
          index = currentIndex;
        }
      }
      if (currentIndex != index) {
        setState(() {
          currentIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: ChangeNotifierProvider<TodoList>.value(
         value: _todoList,
          child: IndexedStack(
          index: currentIndex,
          children: _tabConfigs.map((config) => config.page).toList()
        ),
       ),
      //  body: childPages[currentIndex],
       appBar: AppBar(
         title: Text(_tabConfigs[currentIndex].title),
         automaticallyImplyLeading: false,
         backgroundColor: BACKGROUND_COLOR,
         centerTitle: true,
       ),
       bottomNavigationBar: BottomNavigationBar(
         onTap: onTabChange,
         currentIndex: currentIndex,
         type: BottomNavigationBarType.fixed,
         items: _tabConfigs.map((config) => config.navigationBarItem).toList(),
       ),
    );
  }
}

class TabConfig {
  /// Tab 名字
  final String title;
  /// Tab 上显示的图片
  final String imagePath;
  /// 如果想设置自定义的 Widget，可以使用这个选项
  final BottomNavigationBarItem navigationBarItem;
  /// tab 对应的页面
  final Widget page;

  TabConfig({
    this.title,
    this.imagePath,
    this.page,
    double size = 24,
    bool singleImage = false,
  }) : this.navigationBarItem = buildBottomNavigationBarItem(imagePath, size: size, singleImage: singleImage);


  static Color activeTabColor = Color(0xff50D2C2);
  static Color inactiveTabColor = Colors.black;
  static BottomNavigationBarItem buildBottomNavigationBarItem(String imagePath, {double size, bool singleImage}) {
    if (singleImage) {
      return BottomNavigationBarItem(
        icon: Image(
          width: size,
          height: size,
          image: AssetImage(imagePath),
        ),
        title: Text(''),
      );
    }
    ImageIcon activeIcon = ImageIcon(
      AssetImage(imagePath),
      size: size,
      color: activeTabColor,
    );
    ImageIcon inactiveImageIcon = ImageIcon(
      AssetImage(imagePath),
      size: size,
      color: singleImage ? Colors.transparent : inactiveTabColor,
    );
    return BottomNavigationBarItem(
      activeIcon: activeIcon,
      icon: inactiveImageIcon,
      title: Text(''),
    );
  }
}