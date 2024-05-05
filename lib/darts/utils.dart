import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:toml/toml.dart';




//存放一些小功能的地方
create_main_folder(){
  if (Platform.isWindows){
    Directory dir = Directory('${Platform.environment['USERPROFILE']!}/.nbgui');
    if (!dir.existsSync()){
      dir.createSync();
    }
    Directory.current = dir;
    File cfgfile = File('${dir.toString().replaceAll("Directory: ", '').replaceAll("'", '')}/user_config.json');
    if (!cfgfile.existsSync()){
      String cfg = '''
    {
      "python":"default",
      "nbcli":"default"
    }
    ''';
    cfgfile.writeAsStringSync(cfg);
    }
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  }

  else if (Platform.isLinux || Platform.isMacOS){
    Directory dir = Directory('${Platform.environment['HOME']!}/.nbgui');
    if (!dir.existsSync()){
      dir.createSync();
    }
    Directory.current = dir;
    File cfgfile = File('${dir.toString().replaceAll("Directory: ", '').replaceAll("'", '')}/user_config.json');
    if (!cfgfile.existsSync()){
      String cfg = '''
    {
      "python":"default",
      "nbcli":"default"
    }
    ''';
    cfgfile.writeAsStringSync(cfg);
    }
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  }
}

create_main_folder_bots(){
  if (Platform.isLinux){
    String dir = "${create_main_folder()}/bots/";
    return dir;
  }
  else if (Platform.isMacOS){
    String dir = "${create_main_folder()}/bots/";
    return dir;
  }
  else if (Platform.isWindows){
    String dir = "${create_main_folder()}\\bots\\";
    return dir;
  }
}

user_readconfig_python() {
  File file = File('${create_main_folder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  String PyPath = jsonMap['python'].toString();
  if (PyPath == 'default'){
    if (Platform.isLinux || Platform.isMacOS){
      return 'python3';
    }
    else if (Platform.isWindows){
      return 'python.exe';
    }
  }
  else{
    return PyPath.replaceAll('\\','\\\\');
  }
}

set_pypath(path) {
  File file = File('${create_main_folder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['python'] = path;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

user_readconfig_nbcli() {
  File file = File('${create_main_folder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  String NbcliPath = jsonMap['nbcli'].toString();
  if (NbcliPath == 'default'){
    return 'nb';
  }
  else{
    return NbcliPath.replaceAll('\\','\\\\');
  }
}

set_nbclipath(path) {
  File file = File('${create_main_folder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['nbcli'] = path;
  file.writeAsStringSync(jsonEncode(jsonMap));
}


//检查py
Future<String> getpyver() async {
  try {
    if (Platform.isLinux || Platform.isMacOS) {
      ProcessResult results = await Process.run('${user_readconfig_python()}', ['--version']);
      return results.stdout.trim();
    } else if (Platform.isWindows) {
      ProcessResult results = await Process.run('${user_readconfig_python()}', ['--version']);
      return results.stdout.trim();
    } else {
      return '不支持的平台...';
    }
  } catch (e) {
    return '你似乎还没有安装python？';
  }
}

//检查nbcli
Future<String> getnbcliver() async {
  try {
    final ProcessResult results = await Process.run('${user_readconfig_nbcli()}', ['-V']);
    return results.stdout;
  } catch (error) {
    return '你似乎还没有安装nb-cli？';
  }
}

//创建bot的配置文件
Future creatbot_writeconfig(name,path,venv,dep,drivers,adapters,template,plugindir) async{
  String name_ = name.toString();
  String path_ = path.toString();
  String venv_ = venv.toString();
  String dep_ = dep.toString();
  String drivers_ = drivers.toString();
  String adapters_ = adapters.toString();
  String template_ = template.toString();
  String plugindir_ = plugindir.toString();
  File file = File('${create_main_folder()}/cache_config.txt');
  File fileDrivers = File('${create_main_folder()}/cache_drivers.txt');
  File fileAdapters = File('${create_main_folder()}/cache_adapters.txt');
  file.writeAsStringSync('$name_,$path_,$venv_,$dep_,$template_,$plugindir_');
  fileDrivers.writeAsStringSync(drivers_);
  fileAdapters.writeAsStringSync(adapters_);
}


createbot_readconfig() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();
  return args; 
}

createbot_readconfig_name() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();  
  List args_ = args.split(',');
  return args_[0];
}


createbot_readconfig_path() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();  
  List args_ = args.split(',');
  return args_[1];
}

createbot_readconfig_venv() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();  
  List args_ = args.split(',');   
  return args_[2];
}

createbot_readconfig_dep() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();    
  List args_ = args.split(',');   
  return args_[3];
}

createbot_readconfig_template() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();    
  List args_ = args.split(',');   
  return args_[4];
}

createbot_readconfig_plugindir() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();    
  List args_ = args.split(',');   
  return args_[5];
}

//处理适配器和驱动器
Future<void> createbot_writeconfig_requirement(String drivers, String adapters) async {
  drivers = drivers.toLowerCase();
  String driverlist = drivers.split(',')
    .map((driver) => 'nonebot2[$driver]')
    .join(',');
  driverlist = driverlist.replaceAll(',', '\n');

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)}\n';
  }
  //处理OB V11与OB V12
  adapterlist = adapterlist.replaceAll('nonebot-adapter-onebot.v11','nonebot-adapter-onebot').replaceAll('nonebot-adapter-onebot.v12','nonebot-adapter-onebot');
  File file = File('${create_main_folder()}/requirements.txt');
  file.writeAsStringSync('$driverlist\n$adapterlist');
}

//判断平台并使用对应的venv指令
installbot(path,name,venv,dep){
  if (venv == 'true'){
    if (dep == 'true'){
      if (Platform.isLinux){
        String installbot = '$path/$name/.venv/bin/pip install -r requirements.txt';
        return installbot;
      } else if (Platform.isWindows){
        String installbot = '$path\\$name\\.venv\\Scripts\\pip.exe install -r requirements.txt';
        return installbot;
      } else if (Platform.isMacOS){
        String installbot = '$path/$name/.venv/bin/pip install -r requirements.txt';
        return installbot;
      }
    }
    else if (dep == 'false'){
      File requirements = File('${create_main_folder()}/requirements.txt');
      requirements.copy('${createbot_readconfig_path()}/${createbot_readconfig_name()}/requirements.txt');
      return 'echo 跳过依赖安装，将requirements.txt复制至${createbot_readconfig_path()}/${createbot_readconfig_name()}下';
    }
  }
  else if (venv == 'false'){
    if (dep == 'true'){
        String installbot = '${user_readconfig_python()} -m pip install -r requirements.txt';
        return installbot;
    }
    else if (dep == 'false'){
      File requirements = File('${create_main_folder()}/requirements.txt');
      requirements.copy('${createbot_readconfig_path()}/${createbot_readconfig_name()}/requirements.txt');
      return 'echo 跳过依赖安装，将requirements.txt复制至${createbot_readconfig_path()}/${createbot_readconfig_name()}下';
    }
  }
}

createvenv_echo(path,name){
if (Platform.isLinux){
  String echo = "echo 在$path/$name/.venv/中创建虚拟环境";
  return echo;
}
else if (Platform.isWindows){
  String echo = "echo 在$path\\$name\\.venv\\中创建虚拟环境";
  return echo;
}
else if (Platform.isMacOS){
  String echo = "echo 在$path/$name/.venv/中创建虚拟环境";
  return echo;
}
}


createvenv(path,name,venv){
  if(venv == 'true'){
    if (Platform.isLinux || Platform.isMacOS){
      String createvenv = '${user_readconfig_python()} -m venv $path/$name/.venv --prompt $name';
      return createvenv;
    } else if (Platform.isWindows){
      String createvenv = '${user_readconfig_python()} -m venv $path\\$name\\.venv --prompt $name';
      return createvenv;
    }
  }
  else if(venv == 'false'){
    return 'echo 虚拟环境已关闭，跳过...';
}
}



createfolder(path,name,plugindir){
  Directory dir = Directory('$path/$name');
  Directory dirBots = Directory('${create_main_folder()}/bots');
  if (!dir.existsSync()){
    dir.createSync();
  }
  if (!dirBots.existsSync()){
    dirBots.createSync();
  }
  if ( createbot_readconfig_template() == 'simple(插件开发者)' ){
    if ( plugindir == '在[bot名称]/[bot名称]下' ){
        Directory dirSrc = Directory('$path/$name/$name');
        Directory dirSrcPlugins = Directory('$path/$name/$name/plugins');
        if (!dirSrc.existsSync()){
          dirSrc.createSync();
      }
        if (!dirSrcPlugins.existsSync()){
          dirSrcPlugins.createSync();
      }
    }
    else if ( plugindir == '在src文件夹下' ){
        Directory dirSrc = Directory('$path/$name/src');
        Directory dirSrcPlugins = Directory('$path/$name/src/plugins');
        if (!dirSrc.existsSync()){
          dirSrc.createSync();
        }
        if (!dirSrcPlugins.existsSync()){
          dirSrcPlugins.createSync();
      }
    }
  }
}



writeenv(path,name){
  File file = File('${create_main_folder()}/cache_drivers.txt');
  String drivers = file.readAsStringSync();   
  drivers = drivers.toLowerCase();
  String driverlist = drivers.split(',')
    .map((driver) => '~$driver')
    .join('+');
  if (createbot_readconfig_template() == 'bootstrap(初学者或用户)'){
  String env = 'DRIVER=$driverlist';
  File fileEnv = File('$path/$name/.env.prod');
  fileEnv.writeAsStringSync(env);
  String echo = "echo 写入.env文件";
  return echo;
  }
  else if (createbot_readconfig_template() == 'simple(插件开发者)'){
  String env = 'ENVIRONMENT=dev\nDRIVER=$driverlist';
  File fileEnv = File('$path/$name/.env');
  fileEnv.writeAsStringSync(env);
  File fileEnvdev = File('$path/$name/.env.dev');
  fileEnvdev.writeAsStringSync('LOG_LEVEL=DEBUG');
  File fileEnvprod = File('$path/$name/.env.prod');
  fileEnvprod.createSync();
  String echo = "echo 写入.env文件";
  return echo;
  }
}

writepyproject(path,name){
  File file = File('${create_main_folder()}/cache_adapters.txt');
  String adapters = file.readAsStringSync();  

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)},';
  }
  String adapterlist_ = adapterlist.split(',')
    .map((adapter) => '{ name = "${adapter.replaceAll('nonebot-adapter-','').replaceAll('.', ' ')}", module_name = "${adapter.replaceAll('-', '.').replaceAll('adapter', 'adapters')}" }')
    .join(',');  

  if (createbot_readconfig_template() == 'bootstrap(初学者或用户)'){
  String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        $adapterlist_
    ]
    plugins = []
    plugin_dirs = []
    builtin_plugins = ["echo"]
  ''';
  File filePyproject = File('$path/$name/pyproject.toml');
  filePyproject.writeAsStringSync(pyproject.replaceAll(',{ name = "", module_name = "" }', ''.replaceAll('adapter', 'adapters')));
  String echo = "echo 写入pyproject.toml";
  return echo;
  }
else if (createbot_readconfig_template() == 'simple(插件开发者)'){
  if (createbot_readconfig_plugindir() == '在src文件夹下'){
  String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        $adapterlist_
    ]
    plugins = []
    plugin_dirs = ["src/plugins"]
    builtin_plugins = ["echo"]
  ''';
  File filePyproject = File('$path/$name/pyproject.toml');
  filePyproject.writeAsStringSync(pyproject.replaceAll(',{ name = "", module_name = "" }', ''.replaceAll('adapter', 'adapters')));
  String echo = "echo 写入pyproject.toml";
  return echo;
  }
  else if (createbot_readconfig_plugindir() == '在[bot名称]/[bot名称]下'){
  String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        $adapterlist_
    ]
    plugins = []
    plugin_dirs = ["$name/plugins"]
    builtin_plugins = ["echo"]
  ''';
  File filePyproject = File('$path/$name/pyproject.toml');
  filePyproject.writeAsStringSync(pyproject.replaceAll(',{ name = "", module_name = "" }', ''.replaceAll('adapter', 'adapters')));
  String echo = "echo 写入pyproject.toml";
  return echo;
  }
  }
}

writebot(name,path){
  DateTime now = DateTime.now();
  String time = "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
  File cfgfile = File('${create_main_folder()}/bots/$name.$time.json');
  
  if (Platform.isWindows){
  String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\','\\\\')}\\\\$name",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
}
''';
cfgfile.writeAsStringSync(botInfo);
String echo = "echo 写入json";
return echo;
  }

  if (Platform.isLinux){
  String botInfo = '''
{
  "name": "$name",
  "path": "$path/$name",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
}
''';
cfgfile.writeAsStringSync(botInfo);
String echo = "echo 写入json";
return echo;
  }

  if (Platform.isMacOS){
  String botInfo = '''
{
  "name": "$name",
  "path": "$path/$name",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
}
''';
cfgfile.writeAsStringSync(botInfo);
String echo = "echo 写入json";
return echo;
  }
}

//导入
importbot(name,path){
  DateTime now = DateTime.now();
  String time = "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
  File cfgfile = File('${create_main_folder()}/bots/$name.$time.json');

  if (Platform.isWindows){
  String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\','\\\\')}",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
}
''';
cfgfile.writeAsStringSync(botInfo);
String echo = "echo 写入json";
return echo;
  }

  if (Platform.isLinux || Platform.isMacOS){
  String botInfo = '''
{
  "name": "$name",
  "path": "$path",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
}
''';
cfgfile.writeAsStringSync(botInfo);
String echo = "echo 写入json";
return echo;
  }

}


//管理bot的函数
Future manage_bot_onopencfg(name,time) async{
  String onOpen = '$name.$time';
  File onOpenFile = File('${create_main_folder()}/on_open.txt');
  onOpenFile.writeAsStringSync(onOpen);
}

manage_bot_readcfg_name(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['name'].toString();
}

manage_bot_readcfg_path(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['path'].toString();
}

manage_bot_readcfg_time(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['time'].toString();
}

manage_bot_readcfg_status(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['isrunning'].toString();
}

manage_bot_readcfg_pid(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['pid'].toString();
}

manage_bot_view_stderr(){
  File stderrfile = File('${manage_bot_readcfg_path()}/nbgui_stderr.log');
  String stderr = stderrfile.readAsStringSync();
  return stderr;
}

delete_stderr(){
  File stderrfile = File('${manage_bot_readcfg_path()}/nbgui_stderr.log');
  String clear = "";
  stderrfile.writeAsString(clear);
}


Future openfolder(path) async{
  if(Platform.isWindows){
    await Process.run('explorer', [path]);
  }
  else if(Platform.isLinux){
    await Process.run('xdg-open', [path]);
  }
  else if(Platform.isMacOS){
    await Process.run('open', [path]);
  }
}


//唤起Bot进程
Future run_bot(path) async{
  String name = manage_bot_readcfg_name();
  String time = manage_bot_readcfg_time();
  Directory.current = Directory(path);
  File cfgfile = File('${create_main_folder()}/bots/$name.$time.json');
  final stdout = File('$path/nbgui_stdout.log');
  final stderr = File('$path/nbgui_stderr.log');
  Process process = await Process.start('${user_readconfig_nbcli()}', ['run'],workingDirectory: path);
  int pid = process.pid;
  //重写配置文件来更新状态
  Map<String, dynamic> jsonMap = jsonDecode(cfgfile.readAsStringSync());
  jsonMap['pid'] = pid;
  jsonMap['isrunning'] = 'true';
  cfgfile.writeAsStringSync(jsonEncode(jsonMap));

final outputSink = stdout.openWrite();
final errorSink = stderr.openWrite();


process.stdout.transform(systemEncoding.decoder).listen((data) {
    outputSink.write(data);
  });

process.stderr.transform(systemEncoding.decoder).listen((data) {
    errorSink.write(data);
  });
}



//结束bot进程
Future stop_bot() async{
  //读取配置文件
  String name = manage_bot_readcfg_name();
  String time = manage_bot_readcfg_time();
  File cfgfile = File('${create_main_folder()}/bots/$name.$time.json');
  Map botInfo = json.decode(cfgfile.readAsStringSync());
  String pidString = botInfo['pid'].toString();
  int pid = int.parse(pidString);
  Process.killPid(pid);
  //更新配置文件
  botInfo['isrunning'] = 'false';
  botInfo['pid'] = 'Null';
  cfgfile.writeAsStringSync(json.encode(botInfo));
}


//删除bot
Future delete_bot() async{
  String name = manage_bot_readcfg_name();
  String time = manage_bot_readcfg_time();
  File cfgfile = File('${create_main_folder()}/bots/$name.$time.json');
  cfgfile.delete();
}

Future delete_bot_all() async{
  String name = manage_bot_readcfg_name();
  String time = manage_bot_readcfg_time();
  File cfgfile = File('${create_main_folder()}/bots/$name.$time.json');
  String path = manage_bot_readcfg_path();
  Directory(path).delete(recursive: true);
  cfgfile.delete();
}

clear_log() async{
  String path = manage_bot_readcfg_path();
  File stdout = File('$path/nbgui_stdout.log');
  stdout.delete();
  String info = "[I]Welcome to Nonebot GUI!\n";
  stdout.writeAsString(info);
}


manage_cli_plugin(manage,pluginName) {
  if(manage == 'install'){
    String cmd = '${user_readconfig_nbcli()} plugin install $pluginName';
    return cmd;
  }
  if(manage == 'uninstall'){
    String cmd = '${user_readconfig_nbcli()} plugin uninstall $pluginName -y';
    return cmd;
  }
}


manage_cli_adapter(manage,adapterName) {
  if(manage == 'install'){
    String cmd = '${user_readconfig_nbcli()} adapter install $adapterName';
    return cmd;
  }
  if(manage == 'uninstall'){
    String cmd = '${user_readconfig_nbcli()} adapter uninstall $adapterName -y';
    return cmd;
  }
}

manage_cli_driver(manage,driverName){
  if(manage == 'install'){
    String cmd = '${user_readconfig_nbcli()} driver install $driverName';
    return cmd;
}
  if(manage == 'uninstall'){
    String cmd = '${user_readconfig_nbcli()} driver uninstall $driverName -y';
    return cmd;
}
}

manage_cli_self(manage,packageName){
  if(manage == 'install'){
    String cmd = '${user_readconfig_nbcli()} self install $packageName';
    return cmd;
}
  if(manage == 'uninstall'){
    String cmd = '${user_readconfig_nbcli()} self uninstall $packageName -y';
    return cmd;
}
  if(manage == 'update'){
    String cmd = '${user_readconfig_nbcli()} self update';
    return cmd;
}
}

//补救用，发现进managebot时如果找不到stderr就会炸（）
createlog(path){
  File stdout = File('$path/nbgui_stdout.log');
  File stderr = File('$path/nbgui_stderr.log');
  if ( !stdout.existsSync()){
    stdout.createSync();
  }
  if ( !stderr.existsSync()){
    stderr.createSync();
  }
}

//从pyproject.toml中读取插件列表
get_pluginlist() {
  File pyprojectFile = File('${manage_bot_readcfg_path()}/pyproject.toml');
  String pyproject = pyprojectFile.readAsStringSync();
  var toml = TomlDocument.parse(pyproject).toMap();
  var nonebot = toml['tool']['nonebot'];
  List pluginsList = nonebot['plugins'];
  return pluginsList;
}