import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hsound/services/firestore_service.dart';
import 'package:hsound/screens/profile/artist_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _selectedGenre = 'Todos';
  String _artistGenre = 'Todos';
  String _selectedInstrument = 'Todos';
  String _sortBy = 'title';
  String _searchTab = 'songs';
  bool _showArtistFilters = false;

  final List<String> _priceOptions = ['Todos', 'Gratis', 'Pago', 'Otro'];
  String _eventPriceFilter = 'Todos';

  final List<String> _instruments = [
    'Todos',
    'Guitarra acústica', 'Guitarra eléctrica', 'Bajo eléctrico', 'Bajo acústico',
    'Charango', 'Tiple', 'Violín', 'Viola', 'Violonchelo', 'Contrabajo',
    'Saxofón', 'Flauta traversa', 'Trompeta', 'Trombón', 'Armónica',
    'Acordeón', 'Quena', 'Zampoña',
    'Batería', 'Percusión latina', 'Marimba', 'Tambores', 'Djembé',
    'Cajón peruano', 'Pandereta',
    'Piano', 'Teclado', 'Sintetizador',
    'Voz tenor', 'Voz barítono', 'Voz bajo', 'Voz popular',
    'Toca discos (DJ)', 'Producción musical',
  ];
  
  final List<String> _genres = [
  'Todos',
  'Rock', 'Pop', 'Hip Hop/Rap', 'Trap', 'Electrónica', 'Reggaetón',
  'Salsa', 'Merengue', 'Vallenato', 'Bachata', 'Jazz', 'Blues',
  'Clásica', 'Reggae', 'Metal', 'Indie', 'Folk', 'R&B', 'Country',
  'Alternativo', 'Música Andina', 'Bambuco', 'Pasillo', 'Dancehall',
  'Sanjuanero', 'Carranga', 'Música Popular', 'Despecho', 'Bolero',
  'Cumbia', 'Champeta', 'Fusión Andina', 'Latin Trap', 'Otro',
];

  @override
  void initState() {
    super.initState();
    //_loadGenres();
  }

  //Future<void> _loadGenres() async {
    //final genres = await _firestoreService.getAvailableGenres();
    //setState(() {
      //_genres
        //..clear()
        //..add('Todos')
        //..addAll(genres);
   // });
 // }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedGenre = 'Todos';
      _artistGenre = 'Todos';
      _selectedInstrument = 'Todos';
      _eventPriceFilter = 'Todos';
    });
  }

  // 🎯 CORREGIDO: Navegación al perfil de artista
  void _navigateToArtistProfile(String artistId, String artistName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistProfileScreen(artistId: artistId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilters(),
            if (_searchTab == 'songs') _buildGenreFilter(),
            if (_searchTab == 'events') _buildEventPriceFilter(),
            if (_searchTab == 'artists' && _showArtistFilters) _buildArtistFilters(),
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _searchTab == 'songs' 
                    ? 'Buscar canciones...' 
                    : _searchTab == 'events'
                    ? 'Buscar eventos...'
                    : 'Buscar artistas...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4ADE80)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4ADE80)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF86EFAC)),
                ),
                filled: true,
                fillColor: const Color(0xFF2D2D2D),
              ),
              onChanged: (value) => _performSearch(),
              onSubmitted: (value) => _performSearch(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchTab = 'songs';
                      _clearSearch();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _searchTab == 'songs'
                          ? const Color(0xFF4ADE80) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          color: _searchTab == 'songs'
                              ? const Color(0xFF1E1E1E) 
                              : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Canciones',
                          style: TextStyle(
                            color: _searchTab == 'songs'
                                ? const Color(0xFF1E1E1E) 
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchTab = 'events';
                      _clearSearch();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _searchTab == 'events'
                          ? const Color(0xFF4ADE80) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          color: _searchTab == 'events'
                              ? const Color(0xFF1E1E1E) 
                              : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Eventos',
                          style: TextStyle(
                            color: _searchTab == 'events'
                                ? const Color(0xFF1E1E1E) 
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchTab = 'artists';
                      _clearSearch();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _searchTab == 'artists'
                          ? const Color(0xFF4ADE80) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: _searchTab == 'artists'
                              ? const Color(0xFF1E1E1E) 
                              : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Artistas',
                          style: TextStyle(
                            color: _searchTab == 'artists'
                                ? const Color(0xFF1E1E1E) 
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_searchTab == 'artists')
            IconButton(
              icon: Icon(
                _showArtistFilters ? Icons.filter_list_off : Icons.filter_list,
                color: const Color(0xFF4ADE80),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showArtistFilters = !_showArtistFilters;
                });
              },
              tooltip: 'Filtrar artistas',
            ),
           
           const Spacer(),
           
          if (_searchTab == 'songs') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4ADE80)),
              ),
              child: DropdownButton<String>(
                value: _sortBy,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 11),
                underline: const SizedBox(),
                icon: const Icon(Icons.swap_vert, color: Color(0xFF4ADE80), size: 16),
                items: const [
                  DropdownMenuItem(value: 'title', child: Text('Título', style: TextStyle(fontSize: 11))),
                  DropdownMenuItem(value: 'popularity', child: Text('Popular', style: TextStyle(fontSize: 11))),
                  DropdownMenuItem(value: 'date', child: Text('Reciente', style: TextStyle(fontSize: 11))),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventPriceFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Precio:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _priceOptions.length,
              itemBuilder: (context, index) {
                final option = _priceOptions[index];
                final isSelected = option == _eventPriceFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1E1E1E) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: const Color(0xFF2D2D2D),
                    selectedColor: const Color(0xFF4ADE80),
                    onSelected: (selected) {
                      setState(() {
                        _eventPriceFilter = option;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 NUEVO: Filtros horizontales de géneros
  Widget _buildGenreFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Géneros:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = genre == _selectedGenre;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      genre,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1E1E1E) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: const Color(0xFF2D2D2D),
                    selectedColor: const Color(0xFF4ADE80),
                    onSelected: (selected) {
                      setState(() {
                      _selectedGenre = genre;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Filtrar por género e instrumento',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  value: _artistGenre,
                  items: _genres,
                  label: 'Género',
                  onChanged: (value) {
                    setState(() {
                      _artistGenre = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedInstrument,
                  items: _instruments,
                  label: 'Instrumento',
                  onChanged: (value) {
                    setState(() {
                      _selectedInstrument = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4ADE80)),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4ADE80)),
        isExpanded: true,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResults() {
    if (_searchTab == 'songs') {
      if (_searchQuery.isEmpty && _selectedGenre == 'Todos') {
        return _buildBrowseAllSongs();
      }
      return _buildSongResults();
    } else if (_searchTab == 'events') {
      if (_searchQuery.isEmpty && _eventPriceFilter == 'Todos') {
        return _buildBrowseAllEvents();
      }
      return _buildEventsResults();
    } else {
      if (_searchQuery.isEmpty && _artistGenre == 'Todos' && _selectedInstrument == 'Todos') {
        return _buildBrowseAllArtists();
      }
      return _buildArtistResults();
    }
  }

  Widget _buildSongResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getApprovedSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }

        List<QueryDocumentSnapshot> songs = snapshot.data!.docs.toList();

        // Filtrar por texto de búsqueda (cliente-side)
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          songs = songs.where((song) {
            final data = song.data() as Map<String, dynamic>;
            final title = (data['title'] ?? '').toString().toLowerCase();
            final artist = (data['artistName'] ?? '').toString().toLowerCase();
            return title.contains(lowerQuery) || artist.contains(lowerQuery);
          }).toList();
        }

        // Filtrar por género (cliente-side)
        if (_selectedGenre != 'Todos') {
          songs = songs.where((song) {
            final data = song.data() as Map<String, dynamic>;
            return data['genre'] == _selectedGenre;
          }).toList();
        }

        if (songs.isEmpty) {
          String message;
          if (_searchQuery.isNotEmpty) {
            message = 'No se encontraron canciones para "$_searchQuery"';
          } else if (_selectedGenre != 'Todos') {
            message = 'No hay canciones de $_selectedGenre';
          } else {
            message = 'No se encontraron canciones';
          }
          return _buildNoResults(message: message);
        }

        // Ordenar cliente-side
        switch (_sortBy) {
          case 'popularity':
            songs.sort((a, b) {
              final aLikes = ((a.data() as Map<String, dynamic>)['likes'] ?? 0) as int;
              final bLikes = ((b.data() as Map<String, dynamic>)['likes'] ?? 0) as int;
              return bLikes.compareTo(aLikes);
            });
            break;
          case 'date':
            songs.sort((a, b) {
              final aTs = (a.data() as Map<String, dynamic>)['createdAt'];
              final bTs = (b.data() as Map<String, dynamic>)['createdAt'];
              final aDate = (aTs as Timestamp?)?.toDate() ?? DateTime(2000);
              final bDate = (bTs as Timestamp?)?.toDate() ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });
            break;
          case 'title':
          default:
            songs.sort((a, b) {
              final aTitle = ((a.data() as Map<String, dynamic>)['title'] ?? '').toString();
              final bTitle = ((b.data() as Map<String, dynamic>)['title'] ?? '').toString();
              return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
            });
            break;
        }

        // Limitar a 20 resultados
        if (songs.length > 20) {
          songs = songs.sublist(0, 20);
        }

        return _buildGroupedSongList(songs);
      },
    );
  }

  Widget _buildGroupedSongList(List<QueryDocumentSnapshot> songs) {
    // Agrupar canciones por género
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    for (final song in songs) {
      final data = song.data() as Map<String, dynamic>;
      final genre = data['genre'] ?? 'Otro';
      grouped.putIfAbsent(genre, () => []);
      grouped[genre]!.add(song);
    }

    final sortedGenres = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedGenres.length,
      itemBuilder: (context, index) {
        final genre = sortedGenres[index];
        final genreSongs = grouped[genre]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Canciones de $genre',
                style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...genreSongs.map((songDoc) {
              final songData = songDoc.data() as Map<String, dynamic>;
              return _buildSongItem(
                songId: songDoc.id,
                title: songData['title'] ?? 'Sin título',
                artist: songData['artistName'] ?? 'Artista desconocido',
                artistId: songData['artistId'] ?? '',
                genre: songData['genre'] ?? 'General',
                platform: songData['platform'] ?? 'youtube',
                likes: songData['likes'] ?? 0,
                songUrl: songData['url'] ?? '',
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildArtistResults() {
    final genreFilter = _artistGenre == 'Todos' ? null : _artistGenre;
    final instrumentFilter = _selectedInstrument == 'Todos' ? null : _selectedInstrument;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.searchArtists(
        query: _searchQuery,
        genre: genreFilter,
        instrument: instrumentFilter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
        }

        if (snapshot.hasError) {
          return _buildErrorState('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }

        return _buildGroupedArtistList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildBrowseAllSongs() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getApprovedSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }
        return _buildGroupedSongList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildBrowseAllArtists() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.searchArtists(query: ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }
        return _buildGroupedArtistList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildGroupedArtistList(List<QueryDocumentSnapshot> artists) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    for (final artist in artists) {
      final data = artist.data() as Map<String, dynamic>;
      final genre = data['musicalGenre'] ?? 'Otro';
      grouped.putIfAbsent(genre, () => []);
      grouped[genre]!.add(artist);
    }

    final sortedGenres = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedGenres.length,
      itemBuilder: (context, index) {
        final genre = sortedGenres[index];
        final genreArtists = grouped[genre]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFF4ADE80), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Artistas de $genre',
                    style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...genreArtists.map((artistDoc) {
              final artistData = artistDoc.data() as Map<String, dynamic>;
              return _buildArtistItem(
                artistId: artistDoc.id,
                name: artistData['name'] ?? 'Artista',
                bio: artistData['bio'],
                photoUrl: artistData['photoUrl'],
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSongItem({
    required String songId,
    required String title,
    required String artist,
    required String artistId,
    required String genre,
    required String platform,
    required int likes,
    required String songUrl,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _getPlatformIcon(platform),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$artist • $genre',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.grey, size: 16),
          const SizedBox(width: 4),
          Text(
            likes.toString(),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/song_player',
          arguments: {
            'url': songUrl,
            'title': title,
            'artist': artist,
            'platform': platform,
            'artistId': artistId,
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────
  Widget _buildEventsResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getApprovedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }

        List<QueryDocumentSnapshot> events = snapshot.data!.docs.toList();

        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          events = events.where((event) {
            final data = event.data() as Map<String, dynamic>;
            final title = (data['title'] ?? '').toString().toLowerCase();
            final artist = (data['artistName'] ?? '').toString().toLowerCase();
            final venue = (data['venue'] ?? '').toString().toLowerCase();
            return title.contains(lowerQuery) || artist.contains(lowerQuery) || venue.contains(lowerQuery);
          }).toList();
        }

        if (_eventPriceFilter != 'Todos') {
          events = events.where((event) {
            final data = event.data() as Map<String, dynamic>;
            final price = (data['price'] ?? '').toString();
            if (_eventPriceFilter == 'Gratis') return price == 'Gratis';
            if (_eventPriceFilter == 'Pago') return price.startsWith('\$');
            if (_eventPriceFilter == 'Otro') return price != 'Gratis' && !price.startsWith('\$');
            return true;
          }).toList();
        }

        if (events.isEmpty) {
          String message;
          if (_searchQuery.isNotEmpty) {
            message = 'No se encontraron eventos para "$_searchQuery"';
          } else if (_eventPriceFilter != 'Todos') {
            message = 'No hay eventos $_eventPriceFilter';
          } else {
            message = 'No se encontraron eventos';
          }
          return _buildNoResults(message: message);
        }

        events.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = (aData['eventDate'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final bDate = (bData['eventDate'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return aDate.compareTo(bDate);
        });

        return _buildEventsList(events);
      },
    );
  }

  Widget _buildBrowseAllEvents() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getApprovedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4ADE80)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }
        return _buildEventsList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildEventsList(List<QueryDocumentSnapshot> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final eventDoc = events[index];
        final data = eventDoc.data() as Map<String, dynamic>;
        final eventDate = (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        final isExpired = eventDate.isBefore(DateTime.now());
        final price = data['price'] ?? 'Gratis';
        String priceLabel;
        Color priceColor;
        if (price == 'Gratis') {
          priceLabel = 'Gratis';
          priceColor = const Color(0xFF4ADE80);
        } else if (price.toString().startsWith('\$')) {
          priceLabel = price;
          priceColor = Colors.amber;
        } else {
          priceLabel = price;
          priceColor = Colors.cyan;
        }

        return ListTile(
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpired ? Icons.event_busy : Icons.event_note,
              color: isExpired ? Colors.grey : const Color(0xFF4ADE80),
              size: 20,
            ),
          ),
          title: Text(
            data['title'] ?? 'Evento',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${data['artistName'] ?? '—'} • ${data['venue'] ?? '—'}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priceColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: priceColor.withOpacity(0.3)),
            ),
            child: Text(
              priceLabel,
              style: TextStyle(color: priceColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/event_detail',
              arguments: {'eventId': eventDoc.id},
            );
          },
        );
      },
    );
  }

  Widget _buildArtistItem({
    required String artistId,
    required String name,
    required String? bio,
    required String? photoUrl,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF4ADE80),
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null 
            ? const Icon(Icons.person, color: Color(0xFF1E1E1E))
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        bio ?? 'Artista de H Sound',
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () => _navigateToArtistProfile(artistId, name), // 🎯 AHORA SÍ FUNCIONA
    );
  }

  Widget _buildNoResults({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchTab == 'songs' ? Icons.music_off : _searchTab == 'events' ? Icons.event_busy : Icons.person_off,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? (_searchTab == 'songs'
                ? 'No se encontraron canciones'
                : _searchTab == 'events'
                ? 'No se encontraron eventos'
                : 'No se encontraron artistas'),
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos o filtros',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
              foregroundColor: const Color(0xFF1E1E1E),
            ),
            child: const Text('Limpiar búsqueda'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Error en la búsqueda',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _getPlatformIcon(String platform) {
    switch (platform) {
      case 'youtube':
        return Image.asset('assets/images/youtube.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.video_library, color: Colors.red, size: 16));
      case 'spotify':
        return Image.asset('assets/images/spotify.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 16));
      case 'soundcloud':
        return Image.asset('assets/images/soundcloud.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.cloud, color: Color(0xFFFF7700), size: 16));
      case 'youtube_music':
        return Image.asset('assets/images/youtube.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.library_music, color: Colors.red, size: 16));
      default:
        return const Icon(Icons.music_note, color: Color(0xFF4ADE80), size: 16);
    }
  }
}