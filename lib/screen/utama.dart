import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsi/screen/tim.dart';
import 'dart:convert';

class Utama extends StatefulWidget {
  @override
  _utamaState createState() => _utamaState();
}

class _utamaState extends State<Utama> {
  List<dynamic> _leagues = [];

  Future<void> _fetchLeagues() async {
    try {
      final response = await http.get(Uri.parse('https://go-football-api-v44dfgjgyq-et.a.run.app/'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('League data fetched: $jsonData');
        setState(() {
          _leagues = jsonData['Data'] ?? [];
        });
      } else {
        print('Failed to load leagues: ${response.statusCode}');
        throw Exception('Failed to load leagues');
      }
    } catch (e) {
      print('Error fetching leagues: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLeagues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liga'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _leagues.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(32.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 32,
            mainAxisSpacing: 32,
          ),

          itemCount: _leagues.length,
          itemBuilder: (context, index) {
            final league = _leagues[index];
            final leagueName = league['leagueName'] ?? 'Unknown League';
            final country = league['country'] ?? 'Unknown Country';
            final logoUrl = league['logoLeagueUrl'] ?? '';

            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Tim(leagueId: league['idLeague']),
                    ),
                  );
                },
                child: GridTile(
                  child: logoUrl.isNotEmpty
                      ? Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error);
                    },
                  )
                      : Icon(Icons.sports_soccer),
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text(
                      leagueName,
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      country,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
