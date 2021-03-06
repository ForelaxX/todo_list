import 'package:flutter/material.dart';
import 'package:todo_list/components/date_filed_wrapper.dart';
import 'package:todo_list/components/labeld_field.dart';
import 'package:todo_list/components/location_filed_wrapper.dart';
import 'package:todo_list/components/time_filed_wrapper.dart';
import 'package:todo_list/config/colors.dart';
import 'package:todo_list/model/todo.dart';
import 'package:todo_list/pages/route_url.dart';
import 'package:todo_list/utils/date_time.dart';

class EditTodoPage extends StatefulWidget {
  final EditTodoPageArgument argument;

  const EditTodoPage({Key key, @required this.argument})
      : assert(argument != null),
        super(key: key);

  @override
  _EditTodoPageState createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final TextEditingController _todoNameController = TextEditingController();
  final TextEditingController _todoDescController = TextEditingController();
  final DateFieldController _dateController = DateFieldController();
  final TimeFieldController _startTimeController = TimeFieldController();
  final TimeFieldController _endTimeController = TimeFieldController();
  final TextEditingController _startTimeTextController =
      TextEditingController();
  final TextEditingController _locationTextController = TextEditingController();
  final LocationFieldController _locationController = LocationFieldController();
  final TextEditingController _dateTextController = TextEditingController();
  final TextEditingController _endTimeTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final EdgeInsetsGeometry _labeledFieldPadding =
      const EdgeInsets.fromLTRB(20, 10, 20, 20);
  final TextStyle _titleStyle =
      TextStyle(color: Color(0xFF1D1D26), fontFamily: 'Avenir', fontSize: 14.0);
  final InputBorder _border = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 0.5));

  OpenType _openType;
  Todo _todo;

  Map<OpenType, OpenTypeConfig> _openTypeConfigMap;

  void _edit() {
    setState(() {
      _openType = OpenType.Edit;
    });
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Navigator.of(context).pop(_todo);
    }
  }

  @override
  void initState() {
    super.initState();
    _openType = widget.argument.openType;
    _todo = widget.argument.todo ?? Todo();
    _openTypeConfigMap = {
      OpenType.Preview: OpenTypeConfig('查看 TODO', Icons.edit, _edit),
      OpenType.Edit: OpenTypeConfig('编辑 TODO', Icons.check, _submit),
      OpenType.Add: OpenTypeConfig('添加 TODO', Icons.check, _submit),
    };
    _locationController.addListener(() {
      _locationTextController.text = _locationController.location.description;
    });
    _dateController.addListener(() {
      _dateTextController.text = formatAsChineseDate(_dateController.date);
    });
    _startTimeController.addListener(() {
      _startTimeTextController.text =
          formatTimeOfDay(_startTimeController.time);
    });
    _endTimeController.addListener(() {
      _endTimeTextController.text = formatTimeOfDay(_endTimeController.time);
    });
    if (_openType == OpenType.Preview) {
      _todoNameController.text = _todo.title;
      _todoDescController.text = _todo.description;
      _locationController.location = _todo.location;
      _dateController.date = _todo.date;

      _startTimeController.time = _todo.startTime;
      _endTimeController.time = _todo.endTime;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _todoNameController.dispose();
    _todoDescController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startTimeTextController.dispose();
    _dateTextController.dispose();
    _endTimeTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_openTypeConfigMap[_openType].title),
        backgroundColor: BACKGROUND_COLOR,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _openTypeConfigMap[_openType].icon,
              color: Color(0xffbbbbbe),
            ),
            onPressed: _openTypeConfigMap[_openType].onPressed,
          ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    bool canEdit = _openType != OpenType.Preview;
    return SingleChildScrollView(
      child: IgnorePointer(
        ignoring: !canEdit,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildInputTextLine(
                  '名称',
                  '任务名称',
                  maxLines: 1,
                  controller: _todoNameController,
                  onSaved: (value) => _todo.title = value,
                ),
                _buildInputTextLine(
                  '描述',
                  '任务描述',
                  controller: _todoDescController,
                  onSaved: (value) => _todo.description = value,
                ),
                GestureDetector(
                  child: _buildLocationPicker(
                    '地点',
                    '任务地点',
                    locationController: _locationController,
                    onSaved: (value) => _todo.location = value,
                  ),
                  onLongPress: () => Navigator.of(context).pushNamed(
                    LOCATION_DETAIL_PAGE_URL,
                    arguments: LocationDetailArgument('location'),
                  ),
                ),
                _buildDatePicker(
                  '日期',
                  '请选择日期',
                  dateController: _dateController,
                  textController: _dateTextController,
                  onSaved: (value) => _todo.date = value.nowDay,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: _buildTimePicker(
                        '开始时间',
                        '请选择开始时间',
                        timeController: _startTimeController,
                        textController: _startTimeTextController,
                        onSaved: (value) => _todo.startTime = value,
                      ),
                    ),
                    Expanded(
                      child: _buildTimePicker(
                        '终止时间',
                        '请选择终止时间',
                        timeController: _endTimeController,
                        textController: _endTimeTextController,
                        onSaved: (value) => _todo.endTime = value,
                      ),
                    ),
                  ],
                ),
                _buildPriorityWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputTextLine(
    String title,
    String hintText, {
    int maxLines,
    TextEditingController controller,
    FormFieldSetter<String> onSaved,
  }) {
    TextInputType inputType =
        maxLines == null ? TextInputType.multiline : TextInputType.text;
    return LabeledField(
      labelText: title,
      labelStyle: _titleStyle,
      padding: _labeledFieldPadding,
      child: TextFormField(
        keyboardType: inputType,
        validator: (String value) {
          return value.length > 0 ? null : '$title 不能为空';
        },
        onSaved: onSaved,
        textInputAction: TextInputAction.done,
        maxLines: maxLines,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: _border,
        ),
      ),
    );
  }

  Widget _buildLocationPicker(
    String title,
    String hintText, {
    LocationFieldController locationController,
    TextEditingController textController,
    Function(Location) onSaved,
  }) {
    return LabeledField(
      labelText: title,
      labelStyle: _titleStyle,
      padding: _labeledFieldPadding,
      child: LocationFieldWrapper(
        child: TextFormField(
          controller: _locationTextController,
          decoration: InputDecoration(
            hintText: hintText,
            disabledBorder: _border,
            suffixIcon: Icon(Icons.location_on),
          ),
          onSaved: (_) => onSaved(locationController.location),
        ),
        controller: locationController,
      ),
    );
  }

  Widget _buildDatePicker(
    String title,
    String hintText, {
    DateFieldController dateController,
    TextEditingController textController,
    Function(DateTime) onSaved,
  }) {
    DateTime now = DateTime.now();
    return LabeledField(
      labelText: title,
      labelStyle: _titleStyle,
      padding: _labeledFieldPadding,
      child: DateFieldWrapper(
        child: TextFormField(
          controller: textController,
          decoration: InputDecoration(
            hintText: hintText,
            disabledBorder: _border,
          ),
          validator: (String value) {
            return dateController.date == null ? '$title 不能为空' : null;
          },
          onSaved: (_) => onSaved(dateController.date),
        ),
        controller: dateController,
        initialDate: now,
        firstDate:
            dateController.date ?? DateTime(now.year, now.month, now.day - 1),
        lastDate: DateTime(2025),
      ),
    );
  }

  Widget _buildTimePicker(
    String title,
    String hintText, {
    TimeFieldController timeController,
    TextEditingController textController,
    Function(TimeOfDay) onSaved,
  }) {
    return LabeledField(
      labelText: title,
      labelStyle: _titleStyle,
      padding: _labeledFieldPadding,
      child: TimeFieldWrapper(
        child: TextFormField(
          controller: textController,
          decoration: InputDecoration(
            hintText: hintText,
            disabledBorder: _border,
          ),
          validator: (String value) {
            return timeController.time == null ? '$title 不能为空' : null;
          },
          onSaved: (_) => onSaved(timeController.time),
        ),
        controller: timeController,
        initialTime: TimeOfDay.now(),
      ),
    );
  }

  Widget _buildPriorityWidget() {
    return LabeledField(
      labelText: '优先级',
      labelStyle: _titleStyle,
      padding: _labeledFieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(_todo.priority.description),
                ),
                PopupMenuButton<Priority>(
                  itemBuilder: (BuildContext context) => Priority.values
                      .map((e) => _buildPriorityPopupMenuItem(e))
                      .toList(),
                  onSelected: (Priority priority) {
                    this.setState(() {
                      _todo.priority = priority;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    child: Container(
                      width: 100,
                      height: 5,
                      color: _todo.priority.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<Priority> _buildPriorityPopupMenuItem(Priority priority) {
    return PopupMenuItem<Priority>(
      value: priority,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(priority.description),
          Container(
            width: 100,
            height: 5,
            color: priority.color,
          )
        ],
      ),
    );
  }
}

class OpenTypeConfig {
  final String title;
  final IconData icon;
  final Function onPressed;

  const OpenTypeConfig(this.title, this.icon, this.onPressed);
}
