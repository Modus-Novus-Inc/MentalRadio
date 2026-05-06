import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Radio',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> podcasts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPodcasts();
  }

  Future<void> fetchPodcasts() async {
    try {
      final response = await http.get(Uri.parse('https://feeds.libsyn.com/261089/rss'));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        setState(() {
          podcasts = items.map((item) {
            return {
              'title': item.findElements('title').isNotEmpty 
                  ? item.findElements('title').first.text 
                  : 'No Title',
              'description': item.findElements('description').isNotEmpty 
                  ? item.findElements('description').first.text 
                  : 'No Description',
              'url': item.findElements('enclosure').isNotEmpty
                  ? item.findElements('enclosure').first.getAttribute('url') ?? ''
                  : '',
              'pubDate': item.findElements('pubDate').isNotEmpty 
                  ? item.findElements('pubDate').first.text 
                  : '',
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching podcasts: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPodcastsPage() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PodcastDetailPage(podcast: podcast),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.deepPurple.shade600,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Icon(
                          Icons.radio,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      podcast['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast['pubDate'].split(' ').take(4).join(' '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutUsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.deepPurple.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.radio,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'MENTAL RADIO',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"An Audio-Visual Acid Trip of Spiritual Crack"',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'What is Mental Radio?',
            'Mental Radio is an innovative audio theater experience that combines comedy, philosophy, and storytelling to create a unique form of entertainment. Created by Shadoe Stevens and his team of talented contributors, Mental Radio pushes the boundaries of traditional podcasting.',
          ),
          _buildSection(
            'Our Mission',
            'We believe in the power of "Subversive Optimism" - using humor, creativity, and positive thinking to challenge conventional wisdom and inspire personal growth. Mental Radio aims to uplift mankind through entertainment that both amuses and enlightens.',
          ),
          _buildSection(
            'The Experience',
            'Each episode of Mental Radio is crafted with 3D audio production, creating an immersive theater-of-the-mind experience. Our content ranges from surreal comedy sketches to philosophical discussions, all designed to engage your imagination and expand your consciousness.',
          ),
          _buildSection(
            'Join the Journey',
            'Mental Radio is more than just a podcast - it\'s a movement toward positive transformation through creative expression. Join us as we explore the limitless possibilities of human potential and the power of optimistic thinking.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorsPage() {
    final contributors = [
      {
        'name': 'Shadoe Stevens',
        'role': 'Radio Hall of Fame Inductee, Host of American Top 40',
        'image': 'https://images.bubbleup.com/width640/quality35/mentalradio/pages/meta/shadoe_1708620114.jpg',
        'shortDesc': 'In 2023, Shadoe Stevens was inducted into the Radio Hall of Fame.',
        'fullBio': 'In 2023, Shadoe Stevens was inducted into the Radio Hall of Fame.\n\nHe became one of the most recognized voices in the world as the host of the biggest radio show in history - American Top 40 - which grew to ONE BILLION LISTENERS a week in 110 countries.\n\nHIGHLIGHTS:\n• Won the Billboard Magazine Progressive Personality of the Year Award\n• Number One Rated personality - WRKO Boston - 33% Total Radio Audience\n• He created a number one, album-rock station on AM called "Rock with a Grin" at KRLA\n• Created Alternative Rock Programming launching "WORLD FAMOUS KROQ-FM" in Los Angeles\n• Created the first financially successful Album Rock format in America - KMET-FM\n• In Advertising, he is a CLEO Award Winner\n• Created, produced, and starred in the most successful regional advertising campaign in U.S. history: Fred Rated for Federated\n• Created, wrote, and produced the world\'s first Global Music Network: RhythmRadio\n• Created CaboWaboRadio for rock star Sammy Haggar\n• He Created, wrote, produced, and designed all artwork and marketing materials for MENTALRADIO\n• World\'s Youngest Disc Jockey at age 11 - Jamestown, North Dakota'
      },
      {
        'name': 'Chuck Cirino',
        'role': 'Emmy-nominated Entertainment Professional, Composer, Director',
        'image': 'https://images.bubbleup.com/width640/quality35/mentalradio/pages/meta/chuck_1597292835.jpg',
        'shortDesc': 'While the soundtrack to MentalRadio was created and produced by Shadoe Stevens, nearly all of the music was written and produced by Chuck Cirino.',
        'fullBio': 'Chuck Cirino is a Renaissance Man if ever there was one. In his early career he worked for Shadoe as the Director of the Federated Group\'s wildly successful "Fred Rated" campaign.\n\nChuck is an Emmy-nominated entertainment professional. He cut his teeth as an editor and post-production supervisor.\n\nChuck is best known for executive producing, hosting, and directing Weird TV, a nationally-syndicated television series featuring weird Americans, bizarre news, unbelievable events, and outlandish skits.\n\nKEY ACCOMPLISHMENTS:\n• Executive produced trilogy of children\'s feature films\n• Worked as director, editor and consultant for HBO\'s Runaway Box comedy web series\n• Directed episodes of Howie Mandel\'s The Amazing Live Sea-Monkeys for CBS\n• Directed music videos for Earth, Wind & Fire, Le Rue, and The Dickies\n• Director, cameraman, editor on over 1200 Federated Group TV spots\n• The first to introduce the Burning Man Festival to the rest of the world in 1994\n• Pretty much invented "reality TV" on his show Weird TV\n• Pioneering the "quick cut" style common in television shows and music videos'
      },
      {
        'name': 'Dave Nichols',
        'role': 'Writer, Editor, Producer (1,200+ TV commercials)',
        'image': 'https://images.bubbleup.com/width640/quality35/mentalradio/pages/meta/drake_1597292001.jpg',
        'shortDesc': 'Dave Nichols has been involved in all forms of media both in front and behind the camera since 1978.',
        'fullBio': 'Dave Nichols has been involved in all forms of media both in front and behind the camera since 1978. He and Shadoe Stevens have a long history of creating enlightening illusions.\n\nPROFESSIONAL ACHIEVEMENTS:\n• Written over 1,200 TV commercials while Head Writer at Shadoe Stevens Inc.\n• Co-wrote the television special Shadoevision for HBO\n• Head writer and producer of American Top 40 radio for ABC Watermark\n• Created early-learning software for Microsoft\n\nPUBLISHING CAREER:\n• Editor-in-chief of Easyriders and V-Twin motorcycle magazines for over 20 years\n• Oversaw 13 automotive and motorcycle magazine titles\n• On-camera host of V-Twin TV, a 26-episode television series on SPEED Channel\n• Best-selling author of multiple books including Top Chops and One Percenter series\n\nRECENT PROJECTS:\n• Wrote the screenplay "Apple Jack" for HBO producer Michael Hill\n• Wrote and directed the biker film "Rough Boys"\n• Currently producing the motorcycle-related TV series "Heart of Chrome"\n\nDave came to this planet in 1532, sent by the Optimystical High Counsel to monitor human development and nudge the population towards a more positive evolution.'
      },
      {
        'name': 'Sarge Pickman',
        'role': 'Comedian, Piano Savant, Motivational Speaker',
        'image': 'https://images.bubbleup.com/width640/quality35/mentalradio/pages/meta/sarge_1597292569.jpg',
        'shortDesc': 'Comedian Sarge is an entertainer who has performed worldwide to adoring audiences.',
        'fullBio': 'Comedian Sarge is an entertainer who has performed worldwide to adoring audiences. He is a self-taught piano savant, author and motivational speaker.\n\nPERSONAL JOURNEY:\nHe was born in Miami Beach, Florida during the Civil Rights Movement to a Jewish mother and black father, but given up for adoption soon after birth. He was raised in Great Neck, Long Island.\n\nMUSICAL TALENT:\nHis artistic talents surfaced on his 6th birthday after seeing "The Sound of Music" on Broadway. When they returned home, SARGE sat down at the family piano and began to play songs from the show entirely "by ear" without ever having touched a piano before.\n\nRECOVERY AND TRANSFORMATION:\nAfter struggling with addiction, on December 26, 1990, he had an epiphany that changed his life forever. He committed to sobriety cold turkey and has been clean and sober since then.\n\nPROFESSIONAL CAREER:\n• Worked extensively for ABC Wide World of Sports and CBS Sports\n• Nationally syndicated radio host for FOX Sports Radio\n• Opened for major artists: Natalie Cole, Aretha Franklin, Paul Anka, The Beach Boys\n• Performed at Radio City Music Hall and Major League Baseball\'s All-Star Game\n• Entertained troops in Iraq\n\nCURRENT WORK:\n• Highly sought after motivational speaker\n• Working in treatment centers bringing "Comedy Therapy" to people suffering from addiction\n• Released autobiography "Black Boychick" in 2017\n• Film "Sarge Behind Bars" placed second at the "REEL Recovery Film Festival"\n\nSarge sings in his own voice and in a dozen others including Harry Connick Jr., Sammy Davis Jr., Lionel Richie and Stevie Wonder. His impressions of Marv Albert, Mike Tyson, Kermit the Frog and Gilbert Gottfried leave audiences howling.'
      },
      {
        'name': 'Joshua Weinstein',
        'role': 'Writer, Editor, Consultant, Actor',
        'image': 'https://images.bubbleup.com/width640/quality35/mentalradio/pages/meta/joshua_weinstein_1597291771.jpg',
        'shortDesc': 'Joshua L. Weinstein is a writer, editor, consultant, and now – thanks to MentalRadio – an actor and Optimystical.',
        'fullBio': 'Joshua L. Weinstein is a writer, editor, consultant, and now – thanks to MentalRadio – an actor and Optimystical.\n\nHe became one of Shadoe Stevens\' coconspirators on MentalRadio in the early days of the pandemic. Before Shadoe finished explaining the concept, Joshua was in.\n\nJOURNALISM CAREER:\nJoshua began his career as a newspaper reporter with the St. Petersburg Times (now the Tampa Bay Times), Florida\'s largest-circulation daily. After a brief stop at a news-and-arts weekly in Miami, he moved to Maine, where he spent about 13 years writing for that state\'s largest-circulation newspaper.\n\nDIVERSE EXPERIENCE:\n• Written for Variety and other publications\n• Sold scripts\n• Edited books\n• Cofounded an online auction house\n• Written essays\n• Been a talking head on national television\n• Designed corporate media strategies\n• Officiated at a wedding\n\nHe lives in West Hollywood, enjoys coffee, and has a fear of sauces.'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'CONTRIBUTORS',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Meet the talented team behind Mental Radio',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...contributors.map((contributor) => _buildContributorCard(contributor, constraints)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContributorCard(Map<String, String> contributor, BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetailedContributorInfo(contributor),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: constraints.maxWidth > 600
              ? Row(
                  children: [
                    _buildContributorImage(contributor),
                    const SizedBox(width: 16),
                    _buildContributorInfo(contributor),
                    const SizedBox(width: 16),
                    _buildReadMoreButton(),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        _buildContributorImage(contributor),
                        const SizedBox(width: 16),
                        Expanded(child: _buildContributorInfo(contributor)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildReadMoreButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContributorImage(Map<String, String> contributor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: contributor['image'] != null && contributor['image']!.isNotEmpty
            ? Image.network(
                contributor['image']!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        contributor['name']!.split(' ').map((name) => name[0]).take(2).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  contributor['name']!.split(' ').map((name) => name[0]).take(2).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContributorInfo(Map<String, String> contributor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          contributor['name']!.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          contributor['role']!,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          contributor['shortDesc']!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[300],
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildReadMoreButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Read More',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
      ],
    );
  }

  void _showDetailedContributorInfo(Map<String, String> contributor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 600 : constraints.maxWidth,
                  maxHeight: constraints.maxHeight * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              contributor['name']!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile image
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: contributor['image'] != null && contributor['image']!.isNotEmpty
                                      ? Image.network(
                                          contributor['image']!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  contributor['name']!.split(' ').map((name) => name[0]).take(2).join(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Text(
                                            contributor['name']!.split(' ').map((name) => name[0]).take(2).join(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 40,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Role
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.deepPurple),
                                ),
                                child: Text(
                                  contributor['role']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Full bio
                            Text(
                              contributor['fullBio']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = _buildPodcastsPage();
        break;
      case 1:
        content = _buildAboutUsPage();
        break;
      case 2:
        content = _buildContributorsPage();
        break;
      default:
        content = _buildPodcastsPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mental Radio',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade700,
              ],
            ),
          ),
        ),
      ),
      body: content,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'Podcasts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Contributors',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Rest of the file with PodcastDetailPage and PodcastAudioPlayer classes...
class PodcastDetailPage extends StatelessWidget {
  final Map<String, dynamic> podcast;

  const PodcastDetailPage({Key? key, required this.podcast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Episode Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade700,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.deepPurple.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.radio,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    podcast['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published: ${podcast['pubDate']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (podcast['url'].isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PodcastAudioPlayer(url: podcast['url']),
              ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Episode Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Html(
                    data: podcast['description'],
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: Colors.grey[700],
                        lineHeight: LineHeight(1.5),
                        margin: Margins.zero,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PodcastAudioPlayer extends StatefulWidget {
  final String url;

  const PodcastAudioPlayer({Key? key, required this.url}) : super(key: key);

  @override
  _PodcastAudioPlayerState createState() => _PodcastAudioPlayerState();
}

class _PodcastAudioPlayerState extends State<PodcastAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
          isLoading = state == PlayerState.playing && position == Duration.zero;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Future<void> _playPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() {
        isLoading = true;
      });
      await _audioPlayer.play(UrlSource(widget.url));
    }
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      position = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade300,
                Colors.deepPurple.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _stop,
                    icon: const Icon(Icons.stop, color: Colors.white),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      onPressed: _playPause,
                      icon: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                      iconSize: 48,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () async {
                      final newPosition = position + const Duration(seconds: 30);
                      if (newPosition < duration) {
                        await _audioPlayer.seek(newPosition);
                      }
                    },
                    icon: const Icon(Icons.forward_30, color: Colors.white),
                    iconSize: 32,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Slider(
                    value: duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0,
                    onChanged: (value) async {
                      final newPosition = Duration(seconds: (value * duration.inSeconds).round());
                      await _audioPlayer.seek(newPosition);
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        formatTime(duration),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}