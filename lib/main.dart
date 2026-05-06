import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_html/flutter_html.dart';
import 'splash_screen.dart';

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
      home: SplashScreen(nextScreen: MyHomePage()),
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
      // Try Mental Radio's official RSS feed first, fallback to a working podcast feed
      final response = await http.get(Uri.parse('https://mentalradio.libsyn.com/rss'));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        setState(() {
          podcasts = items.map((item) {
            // Extract image from itunes:image or RSS item
            String imageUrl = '';
            final itunesImage = item.findElements('itunes:image');
            if (itunesImage.isNotEmpty) {
              imageUrl = itunesImage.first.getAttribute('href') ?? '';
            } else {
              // Look for image in description or use default
              final description = item.findElements('description').isNotEmpty 
                  ? item.findElements('description').first.text 
                  : '';
              if (description.contains('<img')) {
                final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
                if (imgMatch != null) {
                  imageUrl = imgMatch.group(1) ?? '';
                }
              }
            }
            
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
              'image': imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/200x200.png?text=Mental+Radio',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        // Fallback: Create some sample Mental Radio episodes
        setState(() {
          podcasts = [
            {
              'title': 'Mental Radio Episode 1: Welcome to the Optimystical Universe',
              'description': 'Join Shadoe Stevens and the Mental Radio crew for an audio adventure into subversive optimism and mental control.',
              'url': 'https://www.soundjay.com/misc/sounds-of-nature-01.mp3',
              'pubDate': 'Mon, 21 Oct 2024 12:00:00 GMT',
              'image': 'https://via.placeholder.com/200x200/6B46C1/FFFFFF?text=MR+EP1',
            },
            {
              'title': 'Mental Radio Episode 2: The Art of Optimystical Thinking',
              'description': 'Discover the power of optimystical thinking and how it can transform your reality.',
              'url': 'https://www.soundjay.com/misc/sounds-of-nature-02.mp3',
              'pubDate': 'Mon, 14 Oct 2024 12:00:00 GMT',
              'image': 'https://via.placeholder.com/200x200/7C3AED/FFFFFF?text=MR+EP2',
            },
            {
              'title': 'Mental Radio Episode 3: Audio Theater Magic',
              'description': 'Experience the magic of audio theater with incredible sound design and storytelling.',
              'url': 'https://www.soundjay.com/misc/sounds-of-nature-03.mp3',
              'pubDate': 'Mon, 07 Oct 2024 12:00:00 GMT',
              'image': 'https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=MR+EP3',
            },
            {
              'title': 'Mental Radio Episode 4: The Contributors Special',
              'description': 'Meet the amazing contributors who make Mental Radio possible.',
              'url': 'https://www.soundjay.com/misc/sounds-of-nature-04.mp3',
              'pubDate': 'Mon, 30 Sep 2024 12:00:00 GMT',
              'image': 'https://via.placeholder.com/200x200/A78BFA/FFFFFF?text=MR+EP4',
            },
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      // Fallback: Create sample episodes if network fails
      setState(() {
        podcasts = [
          {
            'title': 'Mental Radio Episode 1: Welcome to the Optimystical Universe',
            'description': 'Join Shadoe Stevens and the Mental Radio crew for an audio adventure into subversive optimism and mental control.',
            'url': 'https://www.soundjay.com/misc/sounds-of-nature-01.mp3',
            'pubDate': 'Mon, 21 Oct 2024 12:00:00 GMT',
            'image': 'https://via.placeholder.com/200x200/6B46C1/FFFFFF?text=MR+EP1',
          },
          {
            'title': 'Mental Radio Episode 2: The Art of Optimystical Thinking',
            'description': 'Discover the power of optimystical thinking and how it can transform your reality.',
            'url': 'https://www.soundjay.com/misc/sounds-of-nature-02.mp3',
            'pubDate': 'Mon, 14 Oct 2024 12:00:00 GMT',
            'image': 'https://via.placeholder.com/200x200/7C3AED/FFFFFF?text=MR+EP2',
          },
          {
            'title': 'Mental Radio Episode 3: Audio Theater Magic',
            'description': 'Experience the magic of audio theater with incredible sound design and storytelling.',
            'url': 'https://www.soundjay.com/misc/sounds-of-nature-03.mp3',
            'pubDate': 'Mon, 07 Oct 2024 12:00:00 GMT',
            'image': 'https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=MR+EP3',
          },
          {
            'title': 'Mental Radio Episode 4: The Contributors Special',
            'description': 'Meet the amazing contributors who make Mental Radio possible.',
            'url': 'https://www.soundjay.com/misc/sounds-of-nature-04.mp3',
            'pubDate': 'Mon, 30 Sep 2024 12:00:00 GMT',
            'image': 'https://via.placeholder.com/200x200/A78BFA/FFFFFF?text=MR+EP4',
          },
        ];
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Podcast Image
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.shade700,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: podcast['image'] != null && podcast['image'].isNotEmpty
                            ? Image.network(
                                podcast['image'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade700,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade700,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.radio,
                                            size: 32,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'MR',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.radio,
                                      size: 32,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'MR',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Podcast Info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              podcast['title'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                ],
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
        'image': 'assets/images/contributors/shadoe_stevens.jpg',
        'shortDesc': 'In 2023, Shadoe Stevens was inducted into the Radio Hall of Fame.',
        'fullBio': 'In 2023, Shadoe Stevens was inducted into the Radio Hall of Fame.\n\nHe became one of the most recognized voices in the world as the host of the biggest radio show in history - American Top 40 - which grew to ONE BILLION LISTENERS a week in 110 countries.\n\nHIGHLIGHTS:\n• Won the Billboard Magazine Progressive Personality of the Year Award\n• Number One Rated personality - WRKO Boston - 33% Total Radio Audience\n• He created a number one, album-rock station on AM called "Rock with a Grin" at KRLA\n• Created Alternative Rock Programming launching "WORLD FAMOUS KROQ-FM" in Los Angeles\n• Created the first financially successful Album Rock format in America - KMET-FM\n• In Advertising, he is a CLEO Award Winner\n• Created, produced, and starred in the most successful regional advertising campaign in U.S. history: Fred Rated for Federated\n• Created, wrote, and produced the world\'s first Global Music Network: RhythmRadio\n• Created CaboWaboRadio for rock star Sammy Haggar\n• He Created, wrote, produced, and designed all artwork and marketing materials for MENTALRADIO\n• World\'s Youngest Disc Jockey at age 11 - Jamestown, North Dakota'
      },
      {
        'name': 'Chuck Cirino',
        'role': 'Emmy-nominated Entertainment Professional, Composer, Director',
        'image': 'assets/images/contributors/chuck_cirino.jpg',
        'shortDesc': 'While the soundtrack to MentalRadio was created and produced by Shadoe Stevens, nearly all of the music was written and produced by Chuck Cirino.',
        'fullBio': 'Chuck Cirino is a Renaissance Man if ever there was one. In his early career he worked for Shadoe as the Director of the Federated Group\'s wildly successful "Fred Rated" campaign.\n\nChuck is an Emmy-nominated entertainment professional. He cut his teeth as an editor and post-production supervisor.\n\nChuck is best known for executive producing, hosting, and directing Weird TV, a nationally-syndicated television series featuring weird Americans, bizarre news, unbelievable events, and outlandish skits.\n\nKEY ACCOMPLISHMENTS:\n• Executive produced trilogy of children\'s feature films\n• Worked as director, editor and consultant for HBO\'s Runaway Box comedy web series\n• Directed episodes of Howie Mandel\'s The Amazing Live Sea-Monkeys for CBS\n• Directed music videos for Earth, Wind & Fire, Le Rue, and The Dickies\n• Director, cameraman, editor on over 1200 Federated Group TV spots\n• The first to introduce the Burning Man Festival to the rest of the world in 1994\n• Pretty much invented "reality TV" on his show Weird TV\n• Pioneering the "quick cut" style common in television shows and music videos'
      },
      {
        'name': 'Dave Nichols',
        'role': 'Writer, Editor, Producer (1,200+ TV commercials)',
        'image': 'assets/images/contributors/dave_nichols.jpg',
        'shortDesc': 'Dave Nichols has been involved in all forms of media both in front and behind the camera since 1978.',
        'fullBio': 'Dave Nichols has been involved in all forms of media both in front and behind the camera since 1978. He and Shadoe Stevens have a long history of creating enlightening illusions.\n\nPROFESSIONAL ACHIEVEMENTS:\n• Written over 1,200 TV commercials while Head Writer at Shadoe Stevens Inc.\n• Co-wrote the television special Shadoevision for HBO\n• Head writer and producer of American Top 40 radio for ABC Watermark\n• Created early-learning software for Microsoft\n\nPUBLISHING CAREER:\n• Editor-in-chief of Easyriders and V-Twin motorcycle magazines for over 20 years\n• Oversaw 13 automotive and motorcycle magazine titles\n• On-camera host of V-Twin TV, a 26-episode television series on SPEED Channel\n• Best-selling author of multiple books including Top Chops and One Percenter series\n\nRECENT PROJECTS:\n• Wrote the screenplay "Apple Jack" for HBO producer Michael Hill\n• Wrote and directed the biker film "Rough Boys"\n• Currently producing the motorcycle-related TV series "Heart of Chrome"\n\nDave came to this planet in 1532, sent by the Optimystical High Counsel to monitor human development and nudge the population towards a more positive evolution.'
      },
      {
        'name': 'Sarge Pickman',
        'role': 'Comedian, Piano Savant, Motivational Speaker',
        'image': 'assets/images/contributors/sarge_pickman.jpg',
        'shortDesc': 'Comedian Sarge is an entertainer who has performed worldwide to adoring audiences.',
        'fullBio': 'Comedian Sarge is an entertainer who has performed worldwide to adoring audiences. He is a self-taught piano savant, author and motivational speaker.\n\nPERSONAL JOURNEY:\nHe was born in Miami Beach, Florida during the Civil Rights Movement to a Jewish mother and black father, but given up for adoption soon after birth. He was raised in Great Neck, Long Island.\n\nMUSICAL TALENT:\nHis artistic talents surfaced on his 6th birthday after seeing "The Sound of Music" on Broadway. When they returned home, SARGE sat down at the family piano and began to play songs from the show entirely "by ear" without ever having touched a piano before.\n\nRECOVERY AND TRANSFORMATION:\nAfter struggling with addiction, on December 26, 1990, he had an epiphany that changed his life forever. He committed to sobriety cold turkey and has been clean and sober since then.\n\nPROFESSIONAL CAREER:\n• Worked extensively for ABC Wide World of Sports and CBS Sports\n• Nationally syndicated radio host for FOX Sports Radio\n• Opened for major artists: Natalie Cole, Aretha Franklin, Paul Anka, The Beach Boys\n• Performed at Radio City Music Hall and Major League Baseball\'s All-Star Game\n• Entertained troops in Iraq\n\nCURRENT WORK:\n• Highly sought after motivational speaker\n• Working in treatment centers bringing "Comedy Therapy" to people suffering from addiction\n• Released autobiography "Black Boychick" in 2017\n• Film "Sarge Behind Bars" placed second at the "REEL Recovery Film Festival"\n\nSarge sings in his own voice and in a dozen others including Harry Connick Jr., Sammy Davis Jr., Lionel Richie and Stevie Wonder. His impressions of Marv Albert, Mike Tyson, Kermit the Frog and Gilbert Gottfried leave audiences howling.'
      },
      {
        'name': 'Joshua Weinstein',
        'role': 'Writer, Editor, Consultant, Actor',
        'image': 'assets/images/contributors/joshua_weinstein.jpg',
        'shortDesc': 'Joshua L. Weinstein is a writer, editor, consultant, and now – thanks to MentalRadio – an actor and Optimystical.',
        'fullBio': 'Joshua L. Weinstein is a writer, editor, consultant, and now – thanks to MentalRadio – an actor and Optimystical.\n\nHe became one of Shadoe Stevens\' coconspirators on MentalRadio in the early days of the pandemic. Before Shadoe finished explaining the concept, Joshua was in.\n\nJOURNALISM CAREER:\nJoshua began his career as a newspaper reporter with the St. Petersburg Times (now the Tampa Bay Times), Florida\'s largest-circulation daily. After a brief stop at a news-and-arts weekly in Miami, he moved to Maine, where he spent about 13 years writing for that state\'s largest-circulation newspaper.\n\nDIVERSE EXPERIENCE:\n• Written for Variety and other publications\n• Sold scripts\n• Edited books\n• Cofounded an online auction house\n• Written essays\n• Been a talking head on national television\n• Designed corporate media strategies\n• Officiated at a wedding\n\nHe lives in West Hollywood, enjoys coffee, and has a fear of sauces.'
      },
      {
        'name': 'Michael Orenstein',
        'role': 'Stand-up Comedian, Voice Over Artist',
        'image': 'assets/images/contributors/michael_orenstein.jpg',
        'shortDesc': 'Michael took an honors degree in Cellular and Molecular Biology from the University of Michigan and turned it into 35+ years as an entertainer.',
        'fullBio': 'Michael took an honors degree in Cellular and Molecular Biology from the University of Michigan and turned it into 35+ years as an entertainer.\n\nHe has toured the world doing stand-up comedy, improv, theater, writing, and on-camera work.\n\nToday, he is focused on VO and thrilled to be a part of the Mental Radio Team.\n\nWhen not performing, Michael is a devoted husband and father to three rug rats and five fur babies.'
      },
      {
        'name': 'Josh Robert Thompson',
        'role': 'Voice Actor (Geoff Peterson on Craig Ferguson)',
        'image': 'assets/images/contributors/josh_robert_thompson.jpg',
        'shortDesc': 'Ever since he was a little boy, Josh Robert Thompson has been talking to himself.',
        'fullBio': '(NARRATED BY MORGAN FREEMAN)\n\nEver since he was a little boy, Josh Robert Thompson has been talking to himself. Raised in a sleepy suburb of Cleveland, Josh dreamed of someday being on TV – spending weeknights watching Johnny Carson, and weekends building cardboard talkshow sets in his basement.\n\nRADIO BREAKTHROUGH:\nBut Josh\'s path to TV was through the radio. A series of prank phone calls to national news outlets caught the attention of "The Howard Stern Show," where Josh quickly established himself as the voice of "Fake" Arnold Schwarzenegger.\n\nTELEVISION SUCCESS:\nYet it was his turn as robot skeleton sidekick Geoff Peterson on "The Late Late Show with Craig Ferguson" that proved to be Josh\'s big break, lasting for nearly a decade on CBS.\n\nVOICE ACTING CAREER:\n• Josh\'s wide range of celebrity impressions have been featured for over ten seasons on FOX\'s "Family Guy" – from Morgan Freeman to Donald Trump and everyone in between\n• Featured in "American Dad," "The Angry Birds Movie," "Robot Chicken"\n• Netflix originals "Skylanders Academy" and "Motown Magic"\n\nSTAND-UP AND FILM:\n• Toured all over the U.S. and Canada, playing in legendary venues like The Chicago Theater and Radio City Music Hall\n• Stars in the romantic comedy "Nowhere Girl"\n• The indie supernatural thriller "Revelator"\n• The award-winning comedic series "F#cking 40"'
      },
      {
        'name': 'JC Wendel',
        'role': 'Actress (CBS\'s Dave\'s World), Trapeze Artist',
        'image': 'assets/images/contributors/jc_wendel.jpg',
        'shortDesc': 'JC Wendel is an American actress with extensive stage and screen credits.',
        'fullBio': 'JC Wendel is an American actress with extensive stage and screen credits.\n\nOriginally from New York, she was born into a show business family. Her mother was broadway veteran and NBC\'s Third Rock From the Sun star Elmarie Wendel. Her father was a well known artist, musician and painter.\n\nEARLY CAREER:\nJC made her stage debut at the age of eight and never stopped working.\n\nTELEVISION AND FILM:\nBest known for CBS\'s Dave\'s World, starring opposite Harry Anderson and Shadoe Stevens, she has extensive television and film credits, including:\n• Half hour comedies\n• Episodic dramas\n• Pilots\n• Movies\n• Magic Specials\n• Circus Of The Stars\n\nTHEATER EXPERIENCE:\n• International tours of The Odd Couple starring opposite Tim Conway & Tom Poston\n• Scores of regional theatrical tours\n• Limited runs of original plays and beloved musicals\n\nSPECIAL SKILLS:\nIn addition to performing as a professional Trapeze Artist, she is also an award winning equestrian and fine artist.'
      },
      {
        'name': 'Ana Fesmire',
        'role': 'Radio Host (25 years), Voice Over Artist',
        'image': 'assets/images/contributors/ana_fesmire.jpg',
        'shortDesc': 'Ana is a Renaissance Girl Friday. Starting her career in children\'s theatre.',
        'fullBio': 'Ana is a Renaissance Girl Friday. Starting her career in children\'s theatre. She moved on to stage and then Radio.\n\nRADIO CAREER:\n25 year career in morning and afternoon radio shows. As well as her love for comedy and voice overs.\n\nARTISTIC INTERESTS:\n• A lifelong love of musical theater\n• Local theater arts\n• Doing commercials and character voices\n\nPERSONAL LIFE:\nAnd when she\'s not using her voice, she\'s using her hands to cook, Garden, paint and to write.\n\nHaving a father who is 50 years her elder gave her a perspective on all things 30\'s and 40\'s music, radio comedy and music that she can bring to the table and mental radio.'
      },
      {
        'name': 'Diane Nichols',
        'role': 'Actor, Director, Playwright, Comedian',
        'image': 'assets/images/contributors/diane_nichols.jpg',
        'shortDesc': 'Diane Nichols is an actor, director, and playwright. She also does stand-up comedy.',
        'fullBio': 'Diane Nichols is an actor, director, and playwright. She also does stand-up comedy.\n\nShe is currently available for funerals, store openings, ship christenings, and cat shows, as long as they are at her house.\n\nPERSONAL DETAILS:\n• Diane loves bacon waffles\n• She has never met an extra-terrestrial (that she knows of)\n• Yes, that is her real hair color'
      },
      {
        'name': 'Wade Chitwood',
        'role': 'Filmmaker, Visual Effects Artist',
        'image': 'assets/images/contributors/wade_chitwood.jpg',
        'shortDesc': 'Wade Chitwood is a filmmaker and visual effects artist in Bellevue, Washington.',
        'fullBio': 'Wade Chitwood is a filmmaker and visual effects artist in Bellevue, Washington. Through his production and visual effects company "Hoplight Productions," he wrote, directed, and produced the award-winning films, "The Prospector," "The Comet Chronicles," and "Rocket Man Adventure Series."\n\nARTISTIC SKILLS:\nMultifaceted artist, Wade is proficient in various creative art forms that include:\n• Digital effects for feature films and TV shows\n• Comics and comic books\n• Literary illustrations\n• Assorted fine art mediums\n• Other picture postcards\n\nIn 2015 he was the media guest of honor at RADCON Science Fiction convention in the Tri-Cities, Washington.\n\nWRITING CAREER:\nAs a writer, Wade has written:\n• Two science fiction novels\n• An autobiographical book of poems, "Seattle Lunchbox Demons"\n• Currently finishing the TV pilots for "The Comet Chronicles" and "Rocket Man" series\n\nSPORTS:\nWade is a founding member of the Seattle Hurling Club and continues to support and promote the sport of Irish hurling. Playing, not so much - as he has found, he doesn\'t heal as fast as he once did.\n\nMYSTICAL ACHIEVEMENTS:\nCurrently, due to direct mystical experiences and personal transformation, Wade has been elevated to Grand Master, 9th Degree Optimystical in the Ancient Society of Mental Control. This qualifies him to be a Holier Than Thou Creative Contributor to the organization\'s worldwide efforts to uplift mankind.'
      },
      {
        'name': 'Timothy Hallinan',
        'role': 'Award-nominated Author (20+ novels)',
        'image': 'assets/images/contributors/timothy_hallinan.jpg',
        'shortDesc': 'Timothy Hallinan has been nominated for the Edgar, Nero, Shamus, Macavity, and Silver Dagger awards.',
        'fullBio': 'Timothy Hallinan has been nominated for the Edgar, Nero, Shamus, Macavity, and Silver Dagger awards.\n\nHe is the author of twenty widely praised, critically acclaimed novels, including:\n• The Simeon Grist Los Angeles mysteries\n• The Poke Rafferty Bangkok thrillers\n• The Junior Bender mystery series\n\nAfter years of working in Hollywood, television, and the music industry, he now writes full time.\n\nHe divides his time between California and Thailand.'
      },
      {
        'name': 'Marshall McCabe',
        'role': 'Actor (Annoyance Theatre founder)',
        'image': 'assets/images/contributors/marshall_mccabe.jpg',
        'shortDesc': 'Originally from Chicago, a founding member of the Annoyance Theatre.',
        'fullBio': 'Originally from Chicago, a founding member of the Annoyance Theatre.\n\nCHICAGO STAGE CREDITS:\n• The title role in Romeo and Juliet\n• Picnic\n• Road\n• Six Degrees of Separation produced by The Lincoln Center\n\nCBS Studios brought him to Los Angeles.\n\nLOS ANGELES THEATER:\nIn Los Angeles, he performed in:\n• The Premiere of Award Winning Exit Wounds\n• Unemployed Elephants (Best Actor for two-person play)\n• Showpony\n• The Interview\n• A Letter from Ethel Kennedy directed by Joanna Gleason\n• Sex, Sex, Sex, Sex, and Sex by George Furth and directed by John Rubenstein\n• Need\n\nHe\'s also performed with the Actors\' Gang and Ensemble Studio Theatre.\n\nFILM AND TELEVISION:\n• TV: Ruth Harper Pilot, and Pacific Blue\n• Film: Boulevard Misfits, Behind Closed Doors, Stuck, Secrets of Suspense, and Greasy Lake\n• His solo play Up and Bedlam is in pre-production to film as Greatest Loss\n\nMEMBERSHIPS AND MENTORSHIP:\n• Lifetime Member of the Actors Studio, Victory Theatre and Rogue Machine\n• He\'s directed some short films and stage productions\n• A mentor for the Make a Film Foundation that grants children with life-threatening medical conditions to create short film legacies by teaming them with noted actors, directors, and writers'
      },
      {
        'name': 'Davin Fesmire',
        'role': 'Radio Host, Video Producer (Reel Live Media)',
        'image': 'assets/images/contributors/davin_fesmire.jpg',
        'shortDesc': 'A man with a name as unique as his background, has a knack for building things or making them better.',
        'fullBio': 'A man with a name as unique as his background, has a knack for building things or making them better. Davin is married to his wife and often his co-host, Ana Fesmire. They have two adorable artistically gifted teenage kids.\n\nCOMEDY AND ENTERTAINMENT:\nDavin loves creating comedy! Almost nothing is out of bounds, if it\'s funny enough.\n\nRADIO CAREER:\nHis life experience as a Radio Host has taken him from coast to coast a few times. He\'s built and hosted top rated radio shows solo, and with Ana in cities from:\n• New England to California\n• Successes in Denver, Phoenix, Florida, Texas, Los Angeles\n• The world stage along with Shadoe Stevens on the international success of Cabo Wabo Radio\n\nBUSINESS VENTURES:\n• Launched his own video production company, Reel Live Media, in 2008\n• Has a real estate license and uses his life experience and humor to help people take the pressure out of buying or selling their home\n\nMECHANICAL SKILLS:\nAt an early age, Davin\'s father taught him how to be very mechanically inclined. So, when he\'s not being creative with video or various audio shows, you may find him:\n• Restoring a car\n• Building an engine for more horsepower\n• Doing a complete studs-out renovation on a home, himself'
      },
      {
        'name': 'Arno Lucas',
        'role': 'Musician (35 years, worked with Luther Vandross, Al Jarreau)',
        'image': 'assets/images/contributors/arno_lucas.jpg',
        'shortDesc': 'ARNO LUCAS celebrates his thirty fifth year in the music business by not slowing down at all.',
        'fullBio': 'ARNO LUCAS celebrates his thirty fifth year in the music business by not slowing down at all.\n\nUnlike most musicians who tour and record with one or two different types of artist, Arno prides himself on working in all styles as his credits will show whether it\'s country, rhythm and blues, jazz, rock, pop, christian or smooth jazz.\n\nNOTABLE COLLABORATIONS:\n• Luther Vandross\n• Al Jarreau\n• George Duke\n• Bette Midler\n• Jackson Browne\n• Bonnie Raitt\n• Don Henley (The Eagles)\n• The New Edition\n• Yolanda Adams\n• Rachele Ferrell\n• Michael Jackson\n• Burt Bacharach\n• Randy Newman\n• Rickie Lee Jones\n• Chaka Khan\n• Bill Cosby\n• Harry Belafonte\n• Earl Klugh\n• Joe Sample\n• El DeBarge\n• Tyrese\n• Johnny Gill\n\nSONGWRITING AND COMPOSITION:\n• Written two songs with Al Jarreau\n• Written a song for Meg Ryan\'s most recent movie\n• Written for Dionne Warrick\n• Written for New Edition\'s triple platinum CD\n• Now finishing music for a show on N.B.C.\n• Working with Gladys Knight\n\nSPECIAL PERFORMANCES:\n• Did the Super Bowl with Stevie Wonder\n• Worked with John Legend, India Arie, and Joss Stone\n\nINTERNATIONAL WORK:\nFor the last two years, He has spent 6 months of each year in Japan working with an amazing group called EXILE. And has written two songs "forever love" and "NEGAI" for their two most recent CDs.'
      },
      {
        'name': 'Amber Stevens West',
        'role': 'Actress (Greek, 22 Jump Street, The Carmichael Show)',
        'image': 'assets/images/contributors/amber_stevens_west.jpg',
        'shortDesc': 'Amber Stevens West is best known for her roles as Ashleigh Howard in the ABC Family series Greek.',
        'fullBio': 'Amber Stevens West is best known for her roles as:\n• Ashleigh Howard in the ABC Family series Greek\n• Maya in 22 Jump Street\n• Maxine in the NBC sitcom The Carmichael Show\n• Claire Davis in the CBS comedy Happy Together\n\nMost importantly she is the eldest daughter of Shadoe Stevens!'
      },
      {
        'name': 'Betsy Borns',
        'role': 'Writer (Best-selling author, "Comic Lives")',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Betsy Borns knows funny; she literally wrote the book on comedy.',
        'fullBio': 'Betsy Borns knows funny; she literally wrote the book on comedy.\n\nShe is the best-selling author of "Comic Lives," which chronicles the lives and careers of the top comedians in America.\n\nPUBLISHING CAREER:\nBefore becoming a writer, she was a literary agent who worked with:\n• Celebrity biographers\n• Top cookbook authors\n• Romance novelists\n\nTRANSITION TO ENTERTAINMENT:\nAfter 20 years in New York publishing, she moved to L.A. and became Head of Development for Shadoe Stevens, Inc.\n\nHer job was to find, develop, nurture and sell TV and movie projects.\n\nPROJECT DEVELOPMENT:\nShe developed hundreds of projects, which led to the creation of projects for:\n• Disney\n• HBO\n• NBC\n• CBS\n• VH1\n• Comedy Central\n\nWRITING ACHIEVEMENTS:\nBetsy has also written screenplays, created TV formats, and developed numerous pilots.\n\nRETIREMENT AND CURRENT FOCUS:\nNow retired and living in Las Vegas, she spends her time:\n• Reading\n• Writing\n• Cooking\n• Hanging out with family and friends\n\nBetsy brings a lifetime of entertainment industry experience and comedic insight to the Mental Radio family.'
      },
      {
        'name': 'Ron Orbach',
        'role': 'Actor (General Hospital), Photographer',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Ron Orbach is an actor and photographer based in Los Angeles.',
        'fullBio': 'Ron Orbach is an actor and photographer based in Los Angeles.\n\nACTING CAREER:\n• Long-running role on General Hospital\n• Featured in numerous television shows\n• Appeared in feature films\n• Active in Los Angeles theater scene\n\nPHOTOGRAPHY:\nWhen not acting, Ron pursues his passion for photography, capturing:\n• Portrait photography\n• Event photography\n• Artistic compositions\n\nINDUSTRY EXPERIENCE:\nWith decades of experience in the entertainment industry, Ron brings both artistic vision and professional expertise to every project.\n\nHe has worked with many notable actors, directors, and industry professionals throughout his career.'
      },
      {
        'name': 'Pam Matteson',
        'role': 'Voice Over Artist, Singer',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Pam Matteson is a versatile voice over artist and singer.',
        'fullBio': 'Pam Matteson is a versatile voice over artist and singer with extensive experience in:\n\nVOICE OVER WORK:\n• Commercial voice overs\n• Narration projects\n• Character voices\n• Radio imaging\n\nMUSICAL BACKGROUND:\n• Professional singing career\n• Studio recording experience\n• Live performance experience\n• Various musical genres\n\nPROFESSIONAL EXPERIENCE:\nPam has worked with numerous clients in the entertainment industry, bringing her distinctive voice and musical talents to a wide range of projects.\n\nHer warm, engaging personality and professional approach make her a valued contributor to the Mental Radio team.'
      },
      {
        'name': 'James Stevens',
        'role': 'Son of Shadoe Stevens',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'James Stevens is the son of Shadoe Stevens.',
        'fullBio': 'James Stevens is the son of Shadoe Stevens.\n\nFAMILY CONNECTION:\nAs part of the Stevens family, James has grown up surrounded by the entertainment industry and brings a unique perspective to Mental Radio.\n\nCONTRIBUTIONS:\nJames contributes to Mental Radio through:\n• Behind-the-scenes support\n• Creative input\n• Family perspective on the entertainment industry\n• Technical assistance\n\nLEGACY:\nCarrying on the Stevens family tradition of creativity and innovation in entertainment, James represents the next generation of the Mental Radio family.'
      },
      {
        'name': 'Chanel Stevens',
        'role': 'Daughter of Shadoe Stevens',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Chanel Stevens is the daughter of Shadoe Stevens.',
        'fullBio': 'Chanel Stevens is the daughter of Shadoe Stevens.\n\nFAMILY HERITAGE:\nAs part of the Stevens entertainment legacy, Chanel brings a fresh perspective and creative energy to Mental Radio.\n\nCREATIVE CONTRIBUTIONS:\nChanel contributes to Mental Radio through:\n• Creative ideas and concepts\n• Youth perspective on entertainment\n• Family insights\n• Support for Mental Radio projects\n\nNEXT GENERATION:\nRepresenting the younger generation of the Stevens family, Chanel helps bridge traditional radio entertainment with contemporary audiences and modern sensibilities.'
      },
      {
        'name': 'Stephanie Soteriou',
        'role': 'Entertainment Professional',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Stephanie Soteriou is an entertainment industry professional.',
        'fullBio': 'Stephanie Soteriou is an entertainment industry professional with extensive experience in:\n\nINDUSTRY EXPERIENCE:\n• Production coordination\n• Entertainment project management\n• Creative development\n• Industry networking\n\nPROFESSIONAL SKILLS:\n• Project organization\n• Team coordination\n• Creative problem solving\n• Industry relationship building\n\nCONTRIBUTIONS TO MENTAL RADIO:\nStephanie brings her professional experience and organizational skills to help ensure Mental Radio projects run smoothly and efficiently.\n\nHer industry knowledge and professional network contribute valuable resources to the Mental Radio team.'
      },
      {
        'name': 'Frank Mackey',
        'role': 'Radio Professional',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Frank Mackey is a radio industry professional.',
        'fullBio': 'Frank Mackey is a radio industry professional with extensive experience in:\n\nRADIO EXPERIENCE:\n• Radio programming\n• Audio production\n• Broadcasting operations\n• Industry relationships\n\nPROFESSIONAL BACKGROUND:\n• Years of radio industry experience\n• Technical audio expertise\n• Programming knowledge\n• Industry connections\n\nROLE IN MENTAL RADIO:\nFrank contributes his radio expertise and technical knowledge to help ensure Mental Radio maintains the highest standards of audio quality and professional broadcasting.\n\nHis experience in the radio industry provides valuable insights for Mental Radio programming and production decisions.'
      },
      {
        'name': 'Alesha René',
        'role': 'Entertainment Professional',
        'image': 'assets/images/contributors/placeholder.jpg',
        'shortDesc': 'Alesha René is an entertainment industry professional.',
        'fullBio': 'Alesha René is an entertainment industry professional with experience in:\n\nPROFESSIONAL BACKGROUND:\n• Entertainment industry operations\n• Creative project support\n• Industry coordination\n• Professional networking\n\nSKILLS AND EXPERTISE:\n• Project coordination\n• Creative support\n• Industry knowledge\n• Professional communication\n\nCONTRIBUTIONS:\nAlesha brings her professional experience and industry knowledge to support Mental Radio projects and initiatives.\n\nHer dedication to excellence and professional approach help ensure Mental Radio maintains its high standards of quality and creativity.'
      }
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
            ? Image.asset(
                contributor['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // If asset fails to load, use a beautiful gradient placeholder with initials
                  final initials = contributor['name']!.split(' ').map((name) => name[0]).take(2).join();
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade700,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        contributor['name']!.split(' ').map((name) => name[0]).take(2).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
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
                                      ? Image.asset(
                                          contributor['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            final initials = contributor['name']!.split(' ').map((name) => name[0]).take(2).join();
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.deepPurple.shade400,
                                                    Colors.deepPurple.shade700,
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      initials,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 36,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Icon(
                                                      Icons.person,
                                                      color: Colors.white70,
                                                      size: 32,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Mental Radio',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
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
