import 'package:flutter/material.dart';
import 'package:todo_list/components/image_hero.dart';
import 'package:todo_list/model/login_status.dart';
import 'package:todo_list/model/network_client.dart';
import 'package:todo_list/model/todo_list.dart';
import 'package:todo_list/pages/route_url.dart';

class AboutPage extends StatelessWidget {

  const AboutPage({Key key, this.todoList, this.email}) : super(key: key);

  final TodoList todoList;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                child: FractionallySizedBox(
                  child: ImageHero(imageKey: 'assets/images/mark.png'),
                  widthFactor: 0.3,
                  heightFactor: 0.3,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Todo App',
                            style: TextStyle(fontSize: 25, fontFamily: 'VT323'),
                          ),
                        ),
                        Center(
                          child: Text(
                            '版本 1.0.0',
                            style: TextStyle(fontFamily: 'VT323'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 24, right: 24, top: 12, bottom: 12),
                    child: FlatButton(
                      onPressed: () async {
                        await LoginStatus.instance().clearStatus();
                        await NetworkClient.instance().uploadList(todoList.list, email);
                        Navigator.of(context)
                            .pushReplacementNamed(LOGIN_PAGE_URL);
                      },
                      color: Colors.red,
                      disabledColor: Colors.red,
                      child: Text(
                        '退出登录',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
