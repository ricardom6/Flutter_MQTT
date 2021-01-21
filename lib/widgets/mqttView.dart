import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_app/mqtt/state/MQTTAppState.dart';
import 'package:flutter_mqtt_app/mqtt/MQTTManager.dart';


class MQTTView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  MQTTAppState currentAppState;
  MQTTManager manager;
  var identificaCircuito = ['Garagem','Escritorio','Banheiro Escritorio'];
  var enderecoCircuito = ['00','01','02'];
  String hostname = 'm6auto.ddns.net';
  @override

  void initState() {
    super.initState();

    /*
    _hostTextController.addListener(_printLatestValue);
    _messageTextController.addListener(_printLatestValue);
    _topicTextController.addListener(_printLatestValue);

     */
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  /*
  _printLatestValue() {
    print("Second text field: ${_hostTextController.text}");
    print("Second text field: ${_messageTextController.text}");
    print("Second text field: ${_topicTextController.text}");
  }

   */

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold =
        Scaffold(appBar: _buildAppBar(context), body: _buildSingleChildScrollView());
    return scaffold;
    _configureAndConnect;
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('MQTT M6 Auto'),
      //backgroundColor: Colors.greenAccent,
    );
  }
  Widget _buildSingleChildScrollView() {
    return SingleChildScrollView(
        child: _buildColumn(),
    );
  }
  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)
        ),
        _buildEditableColumn(),
        _buildScrollableTextWith(currentAppState.getHistoryText)
      ],
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          //_buildTextFieldWith(_hostTextController, 'Insira endereco do broker',currentAppState.getAppConnectionState),
          //const SizedBox(height: 10),
          //_buildTextFieldWith(
          //    _topicTextController, 'Enter a topic to subscribe or listen', currentAppState.getAppConnectionState),
          //const SizedBox(height: 10),
          //_buildPublishMessageRow(),
          //const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
        //_buildAllButton(),
        _buildLinhaDeComando('Garagem','00'),
          _buildLinhaDeComando('Escritorio','01'),
          _buildLinhaDeComando('Banheiro Esc','02'),
             // *Buzzer
          _buildLinhaDeComando('Lavabo','04'),
          _buildLinhaDeComando('Lamp1 sala','05'),
          _buildLinhaDeComando('Lamp2 sala','06'),
          _buildLinhaDeComando('luz bh suite','07'),
          _buildLinhaDeComando('Quarto 2','08'),
            // *Ar Escritorio
          _buildLinhaDeComando('Suite','10'),
          _buildLinhaDeComando('home office','11'),
          _buildLinhaDeComando('Cascata','12'),
          _buildLinhaDeComando('Area de serviço','13'),
          _buildLinhaDeComando('Bh Social','14'),
          _buildLinhaDeComando('Cozinha','15'),
          _buildLinhaDeComando('L1Varanda','16'),
          _buildLinhaDeComando('L2Varanda','17'),
          _buildLinhaDeComando('L3Jardim','18'),
          _buildLinhaDeComando('L4Pool','19'),
          _buildLinhaDeComando('Bomba Hidro','20'),
          //21
          //22
          _buildLinhaDeComando('Ar Condicionado','23'),
          _buildLinhaDeComando('Jardim Frontal','24'),
        ],
      ),
    );
  }
  Widget _buildLinhaDeComando(String buttonName,String text) {

    final String idTopicoA = 'A' + text;
    final String idTopicoB = 'B' + text;
    final String topicoSub = 'Y' + text;
    final String nome = buttonName;
    return Column(
      children: <Widget>[
        Text(nome),
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: Colors.redAccent,
                //color: Colors.redAccent,
                child: Text(nome + ' OFF'),
                onPressed: () {
                  _publishMessage(idTopicoB);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RaisedButton(
                color: Colors.greenAccent,
                child: Text(nome + ' ON'),
                onPressed: () {
                  _publishMessage(idTopicoA);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message', currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              //color: Colors.deepOrangeAccent,
              child: Text(status +': ' + hostname, textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController &&
        state == MQTTAppConnectionState.disconnected) || (controller == _topicTextController &&
        state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[

        Expanded(
          child: RaisedButton(
            color: Colors.lightBlueAccent,
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null, //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RaisedButton(
            color: Colors.redAccent,
            child: const Text('Disconnect'),
            onPressed: state == MQTTAppConnectionState.connected
                ? _disconnect
                : null, //
          ),
        ),
      ],
    );
  }
  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    return RaisedButton(
      color: Colors.green,
      child: const Text('Send'),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);

            }
          : null, //
    );
  }
  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if(Platform.isAndroid){
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTManager(
        host: hostname,//_hostTextController.text,
        topic: 'COMANDOS',//_topicTextController.text,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect(){
    manager.disconnect();
  }
  void _publishMessage(String text) {
    String osPrefix = 'Flutter_iOS';
    if(Platform.isAndroid){
      osPrefix = 'Flutter_Android';
    }
    //final String message = osPrefix + ' says: ' + text;
    final String message = text;
    manager.publish(message);
    _messageTextController.clear();
  }
}
