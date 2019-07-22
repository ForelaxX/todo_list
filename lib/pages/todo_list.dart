import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/components/delete_todo_dialog.dart';
import 'package:todo_list/model/todo.dart';
import 'package:todo_list/model/todo_list.dart';
import 'package:todo_list/pages/route_url.dart';
import 'package:todo_list/utils/generate_todo.dart';

class TodoListPage extends StatefulWidget {

  final TodoList todoList;

  const TodoListPage({Key key, this.todoList}) : super(key: key);

  @override
  TodoListPageState createState() => TodoListPageState(todoList);
}

class TodoListPageState extends State<TodoListPage> {
  final TodoList _todoList;

  TodoListPageState(this._todoList);

  @override
  void initState() {
    super.initState();
  }


  void insertTodo(Todo todo) {
    setState(() {
      _todoList.add(todo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return TodoItem(
          todo: _todoList.list[index],
          key: Key(_todoList.list[index].id),
          onFinished: (Todo todo) {
            setState(() {
              _todoList.finshedAt(todo.id);
            });
          },
          onStar: (Todo todo) {
            setState(() {
              _todoList.starAt(todo.id);
            });
          },
          onTap: (Todo todo) async {
            Todo changedTodo = await Navigator.of(context).pushNamed(EDIT_TODO_PAGE_URL, arguments: EditTodoPageArgument(openType: OpenType.Preview, todo: todo));
            if (changedTodo == null) {
              return;
            }
            _todoList.updateTodo(todo.id, todo);
          },
          onLongPress: (Todo todo) async {
            bool result = await showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return DeleteTodoDialog(
                  todo: todo,
                );
              }
            );
            if (result) {
              setState(() {
                _todoList.remove(todo.id);
              });
            }
          },
        );
      },
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(Todo todo) onStar;
  final Function(Todo todo) onFinished;
  final Function(Todo todo) onTap;
  final Function(Todo todo) onLongPress;

  const TodoItem({Key key, this.todo, this.onStar, this.onFinished, this.onTap, this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle descTextStyle = TextStyle(
      color: Color.fromARGB(255, 74, 74, 74),
      fontSize: 15,
      fontFamily: 'Avenir',
      decoration: todo.isFinished ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor: Color.fromARGB(255, 74, 74, 74),
    );
    Widget infoRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () { onFinished(todo); },
              child: Image.asset(
                todo.isFinished ? 'assets/images/rect_selected.png' : 'assets/images/rect.png',
                width: 25,
                height: 25,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                todo.title,
                style: descTextStyle,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () { onStar(todo); },
          child: Container(
            child: Image.asset(todo.isStar ? 'assets/images/star.png' : 'assets/images/star_normal.png'),
            width: 25,
            height: 25,
          ),
        ),
      ],
    );
    Widget timeRow = Row(
      children: <Widget>[
        Image.asset(
          'assets/images/group.png',
          width: 25.0,
          height: 25.0,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Text(
            todo.timeString,
            style: descTextStyle,
          ),
        )
      ],
    );
    return GestureDetector(
      onTap: () { onTap(todo); },
      onLongPress: () => onLongPress(todo),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(
              width: 2,
              color: todo.priority.color,
            ),
          ),
        ),
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
        height: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            infoRow,
            timeRow,
          ],
        ),
      ),
    );
  }
}