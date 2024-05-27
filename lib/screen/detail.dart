import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Detail extends StatefulWidget {
  final int teamId;

  Detail({required this.teamId});

  @override
  _detailState createState() => _detailState();
}

class _detailState extends State<Detail> {
  Map<String, dynamic>? _teamDetails;
  bool _isLoading = true;
  bool _isFavorite = false; // Track favorite status

  @override
  void initState() {
    super.initState();
    _fetchTeamDetails();
  }

  Future<void> _fetchTeamDetails() async {
    try {
      final response = await http.get(Uri.parse('https://go-football-api-v44dfgjgyq-et.a.run.app/1/${widget.teamId}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Team details fetched: $jsonData');
        setState(() {
          _teamDetails = jsonData['Data'];
          _isLoading = false;
        });
      } else {
        print('Failed to load team details: ${response.statusCode}');
        throw Exception('Failed to load team details');
      }
    } catch (e) {
      print('Error fetching team details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite; // Toggle favorite status
    });

    // Show snackbar based on favorite status
    final snackBar = SnackBar(
      content: _isFavorite
          ? Text('Berhasil ditambahkan', style: TextStyle(color: Colors.white))
          : Text('Berhasil menghapus', style: TextStyle(color: Colors.white)),
      backgroundColor: _isFavorite ? Colors.green : Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Klub'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _teamDetails == null
          ? Center(child: Text('No details found'))
          : SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: _teamDetails!['LogoClubUrl'] != null
                      ? Image.network(
                    _teamDetails!['LogoClubUrl'],
                    height: 250,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error);
                    },
                  )
                      : Icon(Icons.sports, size: 100),
                ),
                SizedBox(height: 20),
                Text(
                  _teamDetails!['NameClub'] ?? 'Unknown Team',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'HeadCoach',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_teamDetails!['HeadCoach'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  'Captain',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_teamDetails!['CaptainName'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  'Stadium',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_teamDetails!['StadiumName'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showClubLogo(_teamDetails!['LogoClubUrl']);
                  },
                  child: Text('Show Club Logo'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toggleFavorite();
        },
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border, // Change icon based on favorite status
          color: _isFavorite ? Colors.red : null, // Change color based on favorite status
        ),
      ),
    );
  }

  void _showClubLogo(String? logoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: logoUrl != null
              ? Image.network(
            logoUrl,
            errorBuilder: (context, error, stackTrace) {
              return Text('Failed to load logo');
            },
          )
              : Text('Logo not available'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
