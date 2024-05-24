import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/card_info.dart';
import '../services/card_info_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel loggedInUser = UserModel();
  CardInfoService cardInfoService = CardInfoService();
  List<CardInfo> cardInfoList = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchCardInfo();
  }

  void fetchUserData() {
    setState(() {
      loggedInUser = UserModel(
        firstName: 'John',
        secondName: 'Doe',
        email: 'john.doe@example.com',
      );
    });
  }

  void fetchCardInfo() async {
    List<CardInfo> cards = await cardInfoService.getAllCardInfo();
    setState(() {
      cardInfoList = cards;
    });
  }

  void showCardDialog({CardInfo? cardInfo}) {
    final cardNumberController = TextEditingController(text: cardInfo?.number ?? '');
    final cardTypeController = TextEditingController(text: cardInfo?.type ?? '');
    final expiryDateController = TextEditingController(text: cardInfo?.expiry ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cardInfo == null ? 'Add Card Info' : 'Edit Card Info'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(labelText: 'Card Number'),
              ),
              TextField(
                controller: cardTypeController,
                decoration: InputDecoration(labelText: 'Card Type'),
              ),
              TextField(
                controller: expiryDateController,
                decoration: InputDecoration(labelText: 'Expiry Date'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              CardInfo newCardInfo = CardInfo(
                number: cardNumberController.text,
                type: cardTypeController.text,
                expiry: expiryDateController.text,
              );

              if (cardInfo == null) {
                await cardInfoService.sendCardData(newCardInfo);
              } else {
                await cardInfoService.updateCardInfo(cardInfo.number, newCardInfo);
              }

              fetchCardInfo();
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteCardInfo(String number) async {
    await cardInfoService.deleteCardInfo(number);
    fetchCardInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello User!"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Welcome to credit card scanner",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "${loggedInUser.firstName} ${loggedInUser.secondName}",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${loggedInUser.email}",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                child: Text('Scan Your Card'),
              ),
              SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: cardInfoList.length,
                  itemBuilder: (context, index) {
                    final cardInfo = cardInfoList[index];
                    return ListTile(
                      title: Text(cardInfo.type),
                      subtitle: Text(cardInfo.number),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showCardDialog(cardInfo: cardInfo);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteCardInfo(cardInfo.number);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showCardDialog();
                },
                child: Text('Add New Card Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
