import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsi/screen/detail.dart';
import 'dart:convert';

class Tim extends StatefulWidget {
  final int leagueId;

  Tim({required this.leagueId});

  @override
  _timState createState() => _timState();
}

class _timState extends State<Tim> {
  List<dynamic> _teams = [];
  bool _isLoading = true;

  Future<void> _fetchTeams() async {
    try {
      final response = await http.get(Uri.parse('https://go-football-api-v44dfgjgyq-et.a.run.app/${widget.leagueId}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Team data fetched: $jsonData');
        setState(() {
          _teams = jsonData['Data'] ?? [];
          _isLoading = false;
        });
      } else {
        print('Failed to load teams: ${response.statusCode}');
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klub Bola'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Add padding here
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _teams.isEmpty
            ? Center(child: Text('No teams found'))
            : ListView.builder(
          itemCount: _teams.length,
          itemBuilder: (context, index) {
            final team = _teams[index];
            final teamName = team['NameClub'] ?? 'Unknown Team';
            final logoUrl = team['LogoClubUrl'] ?? '';
            final stadiumName = team['StadiumName'] ?? 'Unknown Stadium';

            return Card(
              child: ListTile(
                leading: logoUrl.isNotEmpty
                    ? Image.network(
                  logoUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                )
                    : Icon(Icons.sports),
                title: Text(teamName),
                subtitle: Text(
                  stadiumName,
                  style: TextStyle(fontSize: 12), // Small font size
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(teamId: team['IdClub']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

}
