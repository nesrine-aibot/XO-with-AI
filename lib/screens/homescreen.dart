import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> data = {};
  int boardSize = 3;
  String currentPlayer = 'X';
  bool gameover = false;
  String resultMessage = '';

  void init_game_data() {
    data = {};
    gameover = false;
    resultMessage = '';
    currentPlayer = 'X';
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        data[r.toString() + "x" + c.toString()] = '';
      }
    }
  }

  @override
  void initState() {
    init_game_data();
    super.initState();
  }

  List<List<String>> possible_wins = [
    ['0x0', '0x1', '0x2'],
    ['1x0', '1x1', '1x2'],
    ['2x0', '2x1', '2x2'],
    ['0x0', '1x0', '2x0'],
    ['0x1', '1x1', '2x1'],
    ['0x2', '1x2', '2x2'],
    ['0x0', '1x1', '2x2'],
    ['0x2', '1x1', '2x0'],
  ];

  bool isWin() {
    for (var line in possible_wins) {
      var result = '';
      for (var cell in line) {
        result = result + data[cell]!;
      }
      if (result == 'XXX' || result == 'OOO') {
        for (var cell in line) {
          data[cell] = "true"; // Mark winning cells
        }
        gameover = true;
        resultMessage = 'Player $currentPlayer wins!';
        return true;
      }
    }
    return false;
  }

  bool isFull() {
    return data.values.every((value) => value != '');
  }

  Future<void> computerTurn() async {
    
    if (gameover) return;

    try {
      
      print("trying ....");
      
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/move'),
        // Uri.parse('http://192.168.255.168:5000/move'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"board": data}),
      );
      print("trying ....");
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        String move = result['move'];
        print("trying ....");
        // Set the computer's move and check for win
        if (move != null) {
          setState(() {
            data[move] = 'O';
            gameover = isWin();
            if (gameover) {
              resultMessage = 'Player O wins!';
            } else if (isFull()) {
              gameover = true;
              resultMessage = 'It\'s a draw!';
            }
          });
        }
      } else {
        print("trying ....");
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to make the move: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Visibility(
              visible: gameover,
              child: Text(
                resultMessage.isNotEmpty ? resultMessage : 'It\'s a draw!',
                style: TextStyle(color: Colors.green, fontSize: 25),
              ),
            ),
            Visibility(
              visible: !gameover,
              child: Text(
                'Turn of Player $currentPlayer',
                style: TextStyle(color: Colors.black26, fontSize: 25),
              ),
            ),
            SizedBox(height: 30),
            for (int row = 0; row < boardSize; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int col = 0; col < boardSize; col++) getCell(row, col)
                ],
              ),
            SizedBox(height: 30),
            Visibility(
              visible: gameover,
              child: ElevatedButton(
                onPressed: () {
                  init_game_data();
                  setState(() {});
                },
                child: Text("Play Again"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCell(int row, int col) {
    var dataKey = row.toString() + "x" + col.toString();

    // Determine the color for the cell
    Color cellColor = Colors.redAccent;
    if (data[dataKey] == 'O') {
      cellColor = Colors.yellowAccent;
    }
    // Change color to green if the cell is part of the winning line
    if (data[dataKey] == "true") {
      cellColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        if (gameover) return;
        if (data[dataKey] == '') {
          data[dataKey] = 'X';
          gameover = isWin();

          if (!gameover) {
            gameover = isFull();
            if (gameover) {
              resultMessage = 'It\'s a draw!';
            } else {
              computerTurn(); 
            }
          }
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 3),
        ),
        width: 120,
        height: 120,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.8,
                child: (cellColor == Colors.green)
                    ? Container(
                        color: cellColor,
                      )
                    : Image.asset('assets/images/wood.png', fit: BoxFit.cover),
              ),
            ),
            Center(
              child: Text(
                data[dataKey] == "true" ? 'win' : '${data[dataKey]}',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: cellColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
