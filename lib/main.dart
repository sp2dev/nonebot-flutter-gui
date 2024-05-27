import 'dart:io';
import 'package:NonebotGUI/darts/global.dart';
import 'package:NonebotGUI/darts/utils.dart';
import 'dart:convert';
import 'package:NonebotGUI/ui/createbot.dart';
import 'package:NonebotGUI/ui/import_bot.dart';
import 'package:NonebotGUI/ui/settings/more_page.dart';
import 'package:NonebotGUI/ui/manage_bot.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() async{
  userDir = await createMainFolder();
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: _getTheme(userColorMode(userDir)),
    ),
  );
}
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

ThemeData _getTheme(mode) {
  switch (mode) {
    case 'light':
      return ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(238, 109, 109, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(238, 109, 109, 1),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Color.fromRGBO(238, 109, 109, 1);
            }
            return Colors.white;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(238, 109, 109, 1)
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))
        )
      );
    case 'dark':
      return ThemeData.dark().copyWith(
        primaryColor: const Color.fromRGBO(127, 86, 151, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(127, 86, 151, 1),
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: MaterialStatePropertyAll(Color.fromRGBO(127, 86, 151, 1),)
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(127, 86, 151, 1),
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(127, 86, 151, 1),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(127, 86, 151, 1)
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(127, 86, 151, 1))
        )
      );
    default:
      return ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(238, 109, 109, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(238, 109, 109, 1)
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(238, 109, 109, 1)
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))
        )
      );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String configFolder = '${createMainFolderBots(userDir)}';

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _readConfigFiles();
      setState(() {
      });
    });
  }

  List<String> configFileContentsName = [];
  List<String> configFileContentsPath = [];
  List<String> configFileContentsRun = [];
  List<String> configFileContentsTime = [];

  void _readConfigFiles() async {
    Directory directory = Directory(configFolder);
    List<FileSystemEntity> files = await directory.list().toList();

    configFileContentsName.clear();
    configFileContentsPath.clear();
    configFileContentsRun.clear();
    configFileContentsTime.clear();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonContent = json.decode(content);
        configFileContentsName.add(jsonContent['name']);
        configFileContentsPath.add(jsonContent['path']);
        configFileContentsRun.add(jsonContent['isrunning']);
        configFileContentsTime.add(jsonContent['time']);
      }
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NonebotGUI',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: '更多',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const More();
            }));
          },
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ImportBot();
              }));
            },
            tooltip: "从已有的Bot中导入",
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _readConfigFiles();
            },
            tooltip: "刷新列表",
            color: Colors.white,
          ),
        ],
      ),
      body: configFileContentsName.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('还没有Bot,点击右下角的“+”来创建'),
                  SizedBox(height: 3),
                  Text('如果你已经有了Bot,可以使用右上角的按钮导入'),
                  SizedBox(height: 3),
                  Text('如果创建后没有显示请点击右上角的按钮刷新列表'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: configFileContentsName.length,
              itemBuilder: (context, index) {
                String name = configFileContentsName[index];
                String status = configFileContentsRun[index];
                String time = configFileContentsTime[index];
                String path = configFileContentsPath[index];
                if (status == 'true') {
                  return SingleChildScrollView(
                      child: Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: const Text(
                        "运行中",
                        style: TextStyle(color: Colors.green),
                      ),
                      onTap: () {
                        manageBotOnOpenCfg(userDir, name, time);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          createLog(path);
                          return const ManageBot();
                        }));
                      },
                      trailing: const Icon(Icons.menu),
                    ),
                  ));
                } else {
                  return SingleChildScrollView(
                      child: Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: const Text(
                        "未运行",
                      ),
                      onTap: () {
                        manageBotOnOpenCfg(userDir, name, time);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          createLog(path);
                          return const ManageBot();
                        }));
                      },
                      trailing: const Icon(Icons.menu),
                    ),
                  ));
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const CreateBot();
          }));
        },
        tooltip: '添加一个bot',
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
