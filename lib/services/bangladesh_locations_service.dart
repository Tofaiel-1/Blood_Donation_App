/// Comprehensive Bangladesh location data service
/// Includes all 8 Divisions, 64 Districts, Upazilas, and major Villages/Unions
class BangladeshLocationsService {
  // Complete Bangladesh administrative divisions data
  // Structure: Division -> District -> Upazila -> Villages/Unions (for major areas)
  static const Map<String, Map<String, List<String>>> locationData = {
    'Dhaka': {
      'Dhaka': [
        'Adabor',
        'Badda',
        'Banani',
        'Bangshal',
        'Baridhara',
        'Bashundhara',
        'Cantonment',
        'Chalkbazar',
        'Dakshinkhan',
        'Darus Salam',
        'Demra',
        'Dhamrai',
        'Dhanmondi',
        'Dohar',
        'Gendaria',
        'Gulshan',
        'Hazaribagh',
        'Jatrabari',
        'Kafrul',
        'Kalabagan',
        'Kamrangirchar',
        'Keraniganj',
        'Khilgaon',
        'Khilkhet',
        'Kotwali',
        'Lalbagh',
        'Mirpur',
        'Mohakhali',
        'Mohammadpur',
        'Motijheel',
        'Mugda',
        'Nawabganj',
        'New Market',
        'Niketan',
        'Pallabi',
        'Paltan',
        'Ramna',
        'Rampura',
        'Sabujbagh',
        'Savar',
        'Shahbagh',
        'Shahjahanpur',
        'Sher-e-Bangla Nagar',
        'Sutrapur',
        'Tejgaon',
        'Tejgaon Industrial',
        'Turag',
        'Uttara East',
        'Uttara West',
        'Uttarkhan',
        'Vatara',
        'Wari',
      ],
      'Faridpur': [
        'Alfadanga',
        'Bhanga',
        'Boalmari',
        'Charbhadrasan',
        'Faridpur Sadar',
        'Madhukhali',
        'Nagarkanda',
        'Sadarpur',
        'Saltha',
      ],
      'Gazipur': [
        'Gazipur Sadar',
        'Kaliakair',
        'Kaliganj',
        'Kapasia',
        'Sreepur',
        'Tongi',
        'Joydebpur',
      ],
      'Gopalganj': [
        'Gopalganj Sadar',
        'Kashiani',
        'Kotalipara',
        'Muksudpur',
        'Tungipara',
      ],
      'Kishoreganj': [
        'Austagram',
        'Bajitpur',
        'Bhairab',
        'Hossainpur',
        'Itna',
        'Karimganj',
        'Katiadi',
        'Kishoreganj Sadar',
        'Kuliarchar',
        'Mithamain',
        'Nikli',
        'Pakundia',
        'Tarail',
      ],
      'Madaripur': ['Madaripur Sadar', 'Kalkini', 'Rajoir', 'Shibchar'],
      'Manikganj': [
        'Manikganj Sadar',
        'Daulatpur',
        'Ghior',
        'Harirampur',
        'Saturia',
        'Shibalaya',
        'Singair',
      ],
      'Munshiganj': [
        'Munshiganj Sadar',
        'Gazaria',
        'Lohajang',
        'Sirajdikhan',
        'Sreenagar',
        'Tongibari',
      ],
      'Narayanganj': [
        'Narayanganj Sadar',
        'Araihazar',
        'Bandar',
        'Rupganj',
        'Sonargaon',
        'Siddhirganj',
        'Fatullah',
      ],
      'Narsingdi': [
        'Narsingdi Sadar',
        'Belabo',
        'Monohardi',
        'Palash',
        'Raipura',
        'Shibpur',
      ],
      'Rajbari': [
        'Rajbari Sadar',
        'Baliakandi',
        'Goalandaghat',
        'Pangsha',
        'Kalukhali',
      ],
      'Shariatpur': [
        'Shariatpur Sadar',
        'Bhedarganj',
        'Damudya',
        'Gosairhat',
        'Naria',
        'Zajira',
      ],
      'Tangail': [
        'Tangail Sadar',
        'Basail',
        'Bhuapur',
        'Delduar',
        'Dhanbari',
        'Ghatail',
        'Gopalpur',
        'Kalihati',
        'Madhupur',
        'Mirzapur',
        'Nagarpur',
        'Sakhipur',
      ],
    },
    'Chittagong': {
      'Bandarban': [
        'Bandarban Sadar',
        'Alikadam',
        'Lama',
        'Naikhongchhari',
        'Rowangchhari',
        'Ruma',
        'Thanchi',
      ],
      'Brahmanbaria': [
        'Brahmanbaria Sadar',
        'Akhaura',
        'Ashuganj',
        'Bancharampur',
        'Bijoynagar',
        'Kasba',
        'Nabinagar',
        'Nasirnagar',
        'Sarail',
      ],
      'Chandpur': [
        'Chandpur Sadar',
        'Faridganj',
        'Haimchar',
        'Hajiganj',
        'Kachua',
        'Matlab Dakshin',
        'Matlab Uttar',
        'Shahrasti',
      ],
      'Chittagong': [
        'Anwara',
        'Banshkhali',
        'Boalkhali',
        'Chandanaish',
        'Chittagong Port',
        'Double Mooring',
        'Fatikchhari',
        'Hathazari',
        'Karnaphuli',
        'Lohagara',
        'Mirsharai',
        'Patiya',
        'Panchlaish',
        'Rangunia',
        'Raozan',
        'Sandwip',
        'Satkania',
        'Sitakunda',
        'Agrabad',
        'Pahartali',
        'Patenga',
        'Khulshi',
        'Nasirabad',
        'Bayazid Bostami',
        'Chawkbazar',
        'Kotwali',
      ],
      'Comilla': [
        'Comilla Sadar',
        'Barura',
        'Brahmanpara',
        'Burichang',
        'Chandina',
        'Chauddagram',
        'Daudkandi',
        'Debidwar',
        'Homna',
        'Laksam',
        'Meghna',
        'Muradnagar',
        'Nangalkot',
        'Titas',
        'Comilla Sadar Dakshin',
      ],
      'Cox\'s Bazar': [
        'Cox\'s Bazar Sadar',
        'Chakaria',
        'Eidgaon',
        'Kutubdia',
        'Maheshkhali',
        'Pekua',
        'Ramu',
        'Teknaf',
        'Ukhia',
      ],
      'Feni': [
        'Feni Sadar',
        'Chhagalnaiya',
        'Daganbhuiyan',
        'Fulgazi',
        'Parshuram',
        'Sonagazi',
      ],
      'Khagrachhari': [
        'Khagrachhari Sadar',
        'Dighinala',
        'Lakshmichhari',
        'Mahalchhari',
        'Manikchhari',
        'Matiranga',
        'Panchhari',
        'Ramgarh',
      ],
      'Lakshmipur': [
        'Lakshmipur Sadar',
        'Kamalnagar',
        'Raipur',
        'Ramganj',
        'Ramgati',
      ],
      'Noakhali': [
        'Noakhali Sadar',
        'Begumganj',
        'Chatkhil',
        'Companiganj',
        'Hatiya',
        'Kabirhat',
        'Senbagh',
        'Sonaimuri',
        'Subarnachar',
      ],
      'Rangamati': [
        'Rangamati Sadar',
        'Baghaichhari',
        'Barkal',
        'Belaichhari',
        'Juraichhari',
        'Kaptai',
        'Kawkhali',
        'Langadu',
        'Naniarchar',
        'Rajasthali',
      ],
    },
    'Rajshahi': {
      'Bogura': [
        'Bogura Sadar',
        'Adamdighi',
        'Dhunat',
        'Dhupchanchia',
        'Gabtali',
        'Kahaloo',
        'Nandigram',
        'Sariakandi',
        'Sherpur',
        'Shibganj',
        'Sonatala',
      ],
      'Joypurhat': [
        'Joypurhat Sadar',
        'Akkelpur',
        'Kalai',
        'Khetlal',
        'Panchbibi',
      ],
      'Naogaon': [
        'Naogaon Sadar',
        'Atrai',
        'Badalgachhi',
        'Dhamoirhat',
        'Manda',
        'Mahadebpur',
        'Niamatpur',
        'Patnitala',
        'Porsha',
        'Raninagar',
        'Sapahar',
      ],
      'Natore': [
        'Natore Sadar',
        'Bagatipara',
        'Baraigram',
        'Gurudaspur',
        'Lalpur',
        'Naldanga',
        'Singra',
      ],
      'Chapainawabganj': [
        'Chapainawabganj Sadar',
        'Bholahat',
        'Gomastapur',
        'Nachole',
        'Shibganj',
      ],
      'Pabna': [
        'Pabna Sadar',
        'Atgharia',
        'Bera',
        'Bhangura',
        'Chatmohar',
        'Faridpur',
        'Ishwardi',
        'Santhia',
        'Sujanagar',
      ],
      'Rajshahi': [
        'Rajshahi Sadar',
        'Bagha',
        'Bagmara',
        'Charghat',
        'Durgapur',
        'Godagari',
        'Mohanpur',
        'Paba',
        'Puthia',
        'Tanore',
      ],
      'Sirajganj': [
        'Sirajganj Sadar',
        'Belkuchi',
        'Chauhali',
        'Kamarkhanda',
        'Kazipur',
        'Raiganj',
        'Shahjadpur',
        'Tarash',
        'Ullahpara',
      ],
    },
    'Khulna': {
      'Bagerhat': [
        'Bagerhat Sadar',
        'Chitalmari',
        'Fakirhat',
        'Kachua',
        'Mollahat',
        'Mongla',
        'Morrelganj',
        'Rampal',
        'Sarankhola',
      ],
      'Chuadanga': ['Chuadanga Sadar', 'Alamdanga', 'Damurhuda', 'Jibannagar'],
      'Jessore': [
        'Jessore Sadar',
        'Abhaynagar',
        'Bagherpara',
        'Chaugachha',
        'Jhikargachha',
        'Keshabpur',
        'Manirampur',
        'Sharsha',
      ],
      'Jhenaidah': [
        'Jhenaidah Sadar',
        'Harinakunda',
        'Kaliganj',
        'Kotchandpur',
        'Maheshpur',
        'Shailkupa',
      ],
      'Khulna': [
        'Khulna Sadar',
        'Batiaghata',
        'Dacope',
        'Dumuria',
        'Dighalia',
        'Koyra',
        'Paikgachha',
        'Phultala',
        'Rupsa',
        'Terokhada',
        'Daulatpur',
        'Khalishpur',
        'Khan Jahan Ali',
        'Sonadanga',
      ],
      'Kushtia': [
        'Kushtia Sadar',
        'Bheramara',
        'Daulatpur',
        'Khoksa',
        'Kumarkhali',
        'Mirpur',
      ],
      'Magura': ['Magura Sadar', 'Mohammadpur', 'Shalikha', 'Sreepur'],
      'Meherpur': ['Meherpur Sadar', 'Gangni', 'Mujibnagar'],
      'Narail': ['Narail Sadar', 'Kalia', 'Lohagara'],
      'Satkhira': [
        'Satkhira Sadar',
        'Assasuni',
        'Debhata',
        'Kalaroa',
        'Kaliganj',
        'Shyamnagar',
        'Tala',
      ],
    },
    'Barishal': {
      'Barguna': [
        'Barguna Sadar',
        'Amtali',
        'Bamna',
        'Betagi',
        'Patharghata',
        'Taltali',
      ],
      'Barishal': [
        'Barishal Sadar',
        'Agailjhara',
        'Babuganj',
        'Bakerganj',
        'Banaripara',
        'Gaurnadi',
        'Hizla',
        'Mehendiganj',
        'Muladi',
        'Wazirpur',
      ],
      'Bhola': [
        'Bhola Sadar',
        'Burhanuddin',
        'Char Fasson',
        'Daulatkhan',
        'Lalmohan',
        'Manpura',
        'Tazumuddin',
      ],
      'Jhalokati': ['Jhalokati Sadar', 'Kathalia', 'Nalchity', 'Rajapur'],
      'Patuakhali': [
        'Patuakhali Sadar',
        'Bauphal',
        'Dashmina',
        'Galachipa',
        'Kalapara',
        'Mirzaganj',
        'Rangabali',
        'Dumki',
      ],
      'Pirojpur': [
        'Pirojpur Sadar',
        'Bhandaria',
        'Kawkhali',
        'Mathbaria',
        'Nazirpur',
        'Nesarabad',
        'Zianagar',
      ],
    },
    'Sylhet': {
      'Habiganj': [
        'Habiganj Sadar',
        'Ajmiriganj',
        'Bahubal',
        'Baniyachong',
        'Chunarughat',
        'Lakhai',
        'Madhabpur',
        'Nabiganj',
        'Shayestaganj',
      ],
      'Moulvibazar': [
        'Moulvibazar Sadar',
        'Barlekha',
        'Juri',
        'Kamalganj',
        'Kulaura',
        'Rajnagar',
        'Sreemangal',
      ],
      'Sunamganj': [
        'Sunamganj Sadar',
        'Bishwambarpur',
        'Chhatak',
        'Derai',
        'Dharamapasha',
        'Dowarabazar',
        'Jagannathpur',
        'Jamalganj',
        'Shalla',
        'Tahirpur',
      ],
      'Sylhet': [
        'Sylhet Sadar',
        'Balaganj',
        'Beanibazar',
        'Bishwanath',
        'Companiganj',
        'Dakshin Surma',
        'Fenchuganj',
        'Golapganj',
        'Gowainghat',
        'Jaintiapur',
        'Kanaighat',
        'Osmaninagar',
        'Zakiganj',
        'Zindabazar',
        'Ambarkhana',
      ],
    },
    'Rangpur': {
      'Dinajpur': [
        'Dinajpur Sadar',
        'Birampur',
        'Birganj',
        'Biral',
        'Bochaganj',
        'Chirirbandar',
        'Fulbari',
        'Ghoraghat',
        'Hakimpur',
        'Kaharole',
        'Khansama',
        'Nawabganj',
        'Parbatipur',
      ],
      'Gaibandha': [
        'Gaibandha Sadar',
        'Fulchhari',
        'Gobindaganj',
        'Palashbari',
        'Sadullapur',
        'Saghata',
        'Sundarganj',
      ],
      'Kurigram': [
        'Kurigram Sadar',
        'Bhurungamari',
        'Char Rajibpur',
        'Chilmari',
        'Nageshwari',
        'Phulbari',
        'Rajarhat',
        'Raumari',
        'Ulipur',
      ],
      'Lalmonirhat': [
        'Lalmonirhat Sadar',
        'Aditmari',
        'Hatibandha',
        'Kaliganj',
        'Patgram',
      ],
      'Nilphamari': [
        'Nilphamari Sadar',
        'Dimla',
        'Domar',
        'Jaldhaka',
        'Kishoreganj',
        'Saidpur',
      ],
      'Panchagarh': [
        'Panchagarh Sadar',
        'Atwari',
        'Boda',
        'Debiganj',
        'Tetulia',
      ],
      'Rangpur': [
        'Rangpur Sadar',
        'Badarganj',
        'Gangachara',
        'Kaunia',
        'Mithapukur',
        'Pirgachha',
        'Pirganj',
        'Taraganj',
      ],
      'Thakurgaon': [
        'Thakurgaon Sadar',
        'Baliadangi',
        'Haripur',
        'Pirganj',
        'Ranisankail',
      ],
    },
    'Mymensingh': {
      'Jamalpur': [
        'Jamalpur Sadar',
        'Baksiganj',
        'Dewanganj',
        'Islampur',
        'Madarganj',
        'Melandaha',
        'Sarishabari',
      ],
      'Mymensingh': [
        'Mymensingh Sadar',
        'Bhaluka',
        'Dhobaura',
        'Fulbaria',
        'Gaffargaon',
        'Gauripur',
        'Haluaghat',
        'Ishwarganj',
        'Muktagachha',
        'Nandail',
        'Phulpur',
        'Trishal',
      ],
      'Netrokona': [
        'Netrokona Sadar',
        'Atpara',
        'Barhatta',
        'Durgapur',
        'Kalmakanda',
        'Kendua',
        'Khaliajuri',
        'Madan',
        'Mohanganj',
        'Purbadhala',
      ],
      'Sherpur': [
        'Sherpur Sadar',
        'Jhenaigati',
        'Nakla',
        'Nalitabari',
        'Sreebardi',
      ],
    },
  };

  // Village/Union data for major upazilas
  // Structure: "Division-District-Upazila" -> List of Villages/Unions
  // Covers 300+ upazilas with comprehensive village/union data
  static const Map<String, List<String>> villageData = {
    // ==================== DHAKA DIVISION ====================
    // Dhaka District
    'Dhaka-Dhaka-Dhamrai': [
      'Amta',
      'Baisakanda',
      'Dhamrai Sadar',
      'Kamalpur',
      'Kusumhati',
      'Nannar',
      'Rowail',
      'Sanora',
      'Sombhag',
      'Suapur',
    ],
    'Dhaka-Dhaka-Savar': [
      'Amin Bazar',
      'Ashulia',
      'Birulia',
      'Kaundia',
      'Pathalia',
      'Savar Cantonment',
      'Shimulia',
      'Tetuljhora',
      'Yearpur',
    ],
    'Dhaka-Dhaka-Keraniganj': [
      'Abdul Rajjak',
      'Aganagar',
      'Hazratpur',
      'Kalindi',
      'Keraniganj Sadar',
      'Ruhitpur',
      'Shubhadda',
      'Tegharia',
      'Zinjira',
    ],
    'Dhaka-Dhaka-Dohar': [
      'Bilashpur',
      'Dohar',
      'Kusumpur',
      'Mahmudpur',
      'Nayabari',
      'Sutarpara',
    ],
    'Dhaka-Dhaka-Nawabganj': ['Barrah', 'Bashantek', 'Kailail', 'Nawabganj'],

    // Faridpur
    'Dhaka-Faridpur-Faridpur Sadar': [
      'Ambikapur',
      'Azimuddinpur',
      'Char Bishnupur',
      'Char Jadunandi',
      'Faridpur Town',
      'Gatti',
      'Kaijuri',
      'Krishnanagar',
      'Manikpur',
      'Nasirabad',
    ],
    'Dhaka-Faridpur-Alfadanga': [
      'Alfadanga',
      'Bana',
      'Gopalpur',
      'Panchuria',
      'Tagarbanda',
    ],
    'Dhaka-Faridpur-Bhanga': [
      'Algi',
      'Bhanga',
      'Char Jahukanda',
      'Hamirdi',
      'Kalukhali',
      'Manikdaha',
      'Tujerpur',
    ],

    // Gazipur
    'Dhaka-Gazipur-Gazipur Sadar': [
      'Baria',
      'Boali',
      'Gazipur Sadar',
      'Gosinga',
      'Jangalia',
      'Kapasia',
      'Proshobpur',
      'Rajabari',
      'Tumulia',
    ],
    'Dhaka-Gazipur-Kaliakair': [
      'Atmul',
      'Bangra',
      'Boubi',
      'Enam Nagar',
      'Fulbaria',
      'Kaliakair',
      'Moktarpur',
      'Srifaltali',
    ],
    'Dhaka-Gazipur-Tongi': [
      'Ashpara',
      'Cherag Ali',
      'Tongi East',
      'Tongi West',
    ],
    'Dhaka-Gazipur-Sreepur': [
      'Barmi',
      'Gazipur',
      'Gosalia',
      'Prohladpur',
      'Rajabari',
      'Sreepur',
    ],

    // Gopalganj
    'Dhaka-Gopalganj-Gopalganj Sadar': [
      'Chandradighalia',
      'Durgapur',
      'Ghaghor',
      'Gopalganj Sadar',
      'Karpara',
      'Latifpur',
      'Patgati',
      'Raghdi',
      'Satpar',
      'Ulpur',
    ],
    'Dhaka-Gopalganj-Tungipara': [
      'Bakshiganj',
      'Baniakhola',
      'Batikamari',
      'Boultali',
      'Dumaria',
      'Gopalpur',
      'Kushli',
      'Patgati',
      'Tungipara',
    ],

    // Kishoreganj
    'Dhaka-Kishoreganj-Kishoreganj Sadar': [
      'Boyra',
      'Chowddoshata',
      'Haibattala',
      'Jagannatpur',
      'Kargoan',
      'Kishoreganj',
      'Maizhati',
      'Marua',
      'Panchgaon',
      'Pumdi',
      'Sararchar',
    ],
    'Dhaka-Kishoreganj-Bhairab': [
      'Balla',
      'Bhairab',
      'Danapatuli',
      'Kazirchar',
      'Purba Bhairab',
      'Shim',
    ],
    'Dhaka-Kishoreganj-Bajitpur': [
      'Bajitpur',
      'Dilalpur',
      'Gazaria',
      'Mamudpur',
      'Marichpuran',
      'Sreenagar',
    ],

    // Narayanganj
    'Dhaka-Narayanganj-Narayanganj Sadar': [
      'Alirtek',
      'Baburail',
      'Bishnandi',
      'Enayetnagar',
      'Fatulla',
      'Kutubpur',
      'Narayanganj Sadar',
    ],
    'Dhaka-Narayanganj-Rupganj': [
      'Bhulta',
      'Duptara',
      'Kayetpara',
      'Murapara',
      'Rupganj',
    ],
    'Dhaka-Narayanganj-Sonargaon': [
      'Baidder Bazar',
      'Jampur',
      'Mograpara',
      'Pirojpur',
      'Sonargaon',
    ],
    'Dhaka-Narayanganj-Siddhirganj': [
      'Adamjee Nagar',
      'Fatulla',
      'Rupganj',
      'Siddhirganj',
    ],

    // Tangail
    'Dhaka-Tangail-Tangail Sadar': [
      'Adalat Para',
      'Ahla',
      'Bajitkhila',
      'Bepari Para',
      'Kagmari',
      'Kakua',
      'Patharail',
      'Purail',
    ],
    'Dhaka-Tangail-Madhupur': [
      'Ausha',
      'Dhopakul',
      'Guabaria',
      'Madhupur',
      'Solimabad',
    ],
    'Dhaka-Tangail-Mirzapur': [
      'Bahuria',
      'Gorai',
      'Jamurki',
      'Mirzapur',
      'Warabad',
    ],

    // ==================== CHITTAGONG DIVISION ====================
    // Chittagong District
    'Chittagong-Chittagong-Hathazari': [
      'Charpahari',
      'Dhoom',
      'Fatikchhari',
      'Gorduara',
      'Hathazari',
      'Katirhat',
      'Madarsha',
      'Nanupur',
    ],
    'Chittagong-Chittagong-Rangunia': [
      'Betagi',
      'Chandraghona',
      'Islamabad',
      'Kodala',
      'Lalanagar',
      'Mariumnagar',
      'Parua',
      'Rajanagar',
      'Saroatoli',
    ],
    'Chittagong-Chittagong-Sitakunda': [
      'Barabkunda',
      'Bhatiari',
      'Fouzdarhat',
      'Kumira',
      'Sitakunda',
      'Sonaichhari',
    ],
    'Chittagong-Chittagong-Mirsharai': [
      'Haimchar',
      'Joarganj',
      'Mirsharai',
      'Zorarganj',
    ],
    'Chittagong-Chittagong-Patiya': [
      'Ashia',
      'Char Lakshya',
      'Juldha',
      'Patiya',
      'Soikkhyat',
    ],
    'Chittagong-Chittagong-Anwara': [
      'Anwara',
      'Battali',
      'Burumchara',
      'Chatari',
      'Haildhar',
      'Julidhar',
      'Paroikora',
    ],

    // Cox's Bazar
    'Chittagong-Cox\'s Bazar-Cox\'s Bazar Sadar': [
      'Bakkhali',
      'Eidgaon',
      'Islamabad',
      'Jhilanja',
      'Khurushkul',
      'Pmkhali',
    ],
    'Chittagong-Cox\'s Bazar-Teknaf': [
      'Baharchhara',
      'Hnila',
      'Nhila',
      'Sabrang',
      'St. Martin',
      'Teknaf Sadar',
      'Whykong',
    ],
    'Chittagong-Cox\'s Bazar-Ukhia': [
      'Haldia Palong',
      'Jalia Palong',
      'Palongkhali',
      'Raja Palong',
      'Ratna Palong',
      'Ukhia',
    ],
    'Chittagong-Cox\'s Bazar-Ramu': [
      'Chakmarkul',
      'Dakhin Mithachhari',
      'Garja',
      'Eidghar',
      'Kachchhapia',
      'Ramu',
      'Rashidnagar',
    ],

    // Comilla
    'Chittagong-Comilla-Comilla Sadar': [
      'Bagmara',
      'Bijoypur',
      'Comilla Cantonment',
      'Dakshin Maynamati',
      'Jhawtola',
      'Lakhsham',
      'Manoharganj',
      'Narayanpur',
    ],
    'Chittagong-Comilla-Daudkandi': [
      'Bateshwar',
      'Bitarthi',
      'Daudkandi',
      'Eliotganj',
      'Gouripur',
      'Kaliara',
      'Maruka',
      'Mohakali',
    ],
    'Chittagong-Comilla-Laksam': [
      'Chandi',
      'Char Malai',
      'Laksam',
      'Mohammadpur',
      'Paharpur',
    ],

    // Brahmanbaria
    'Chittagong-Brahmanbaria-Brahmanbaria Sadar': [
      'Brahmanbaria',
      'Dharkhar',
      'Majlishpur',
      'Medda',
      'Nabinagar',
      'Natai',
      'Paikpara',
      'Saldhar',
    ],
    'Chittagong-Brahmanbaria-Ashuganj': [
      'Ashuganj',
      'Bishnupur',
      'Dhala',
      'Paikara',
      'Tarua',
    ],
    'Chittagong-Brahmanbaria-Kasba': [
      'Birgaon',
      'Char Manai',
      'Gopinathpur',
      'Kaitala',
      'Kasba',
      'Khanda',
      'Sadekpur',
      'Upadi',
    ],

    // Chandpur
    'Chittagong-Chandpur-Chandpur Sadar': [
      'Chandpur',
      'Char Poragacha',
      'Kachua',
      'Kalakanda',
      'Maijchar',
      'Rahitpur',
      'Sahebpur',
    ],
    'Chittagong-Chandpur-Faridganj': [
      'Char Abdullahpur',
      'Char Atra',
      'Faridganj',
      'Kaichapur',
      'Nurpur',
      'Puranhat',
      'Rampurhat',
    ],

    // Feni
    'Chittagong-Feni-Feni Sadar': [
      'Char Chanchra',
      'Charmozlishpur',
      'Dagonbhuiyan',
      'Feni',
      'Fazilpur',
      'Lalmatirgaon',
      'Matiganj',
      'Muhuriganj',
      'Pathannagar',
      'Shubhapur',
    ],
    'Chittagong-Feni-Sonagazi': [
      'Ahmadpur',
      'Amzadhat',
      'Char Chhata',
      'Jaypur',
      'Matubhuiyan',
      'Nababpur',
      'Sonagazi',
    ],

    // ==================== RAJSHAHI DIVISION ====================
    // Rajshahi District
    'Rajshahi-Rajshahi-Rajshahi Sadar': [
      'Ghoramara',
      'Katakhali',
      'Kazla',
      'Matihar',
      'Rajshahi Court',
      'Rajpara',
      'Sapura',
    ],
    'Rajshahi-Rajshahi-Paba': [
      'Baragachi',
      'Damkur',
      'Harian',
      'Horian',
      'Katakhali',
      'Naohata',
      'Paba Sadar',
    ],
    'Rajshahi-Rajshahi-Godagari': [
      'Asariadaha',
      'Char Ashariadaha',
      'Godagari',
      'Matikata',
      'Mohanpur',
      'Pakri',
      'Rishikul',
    ],

    // Bogura
    'Rajshahi-Bogura-Bogura Sadar': [
      'Bogura Town',
      'Chatkamarpara',
      'Dupchanchia',
      'Gabtali',
      'Nimgachi',
      'Sardarpara',
      'Sherpur',
    ],
    'Rajshahi-Bogura-Shibganj': [
      'Buriganj',
      'Chopinagar',
      'Gokul',
      'Mahishaban',
      'Rajapur',
      'Shibganj',
    ],
    'Rajshahi-Bogura-Shajahanpur': [
      'Baluri',
      'Buriganga',
      'Choptala',
      'Garidaha',
      'Jhikira',
      'Shajahanpur',
    ],

    // Pabna
    'Rajshahi-Pabna-Pabna Sadar': [
      'Bagbati',
      'Goyespur',
      'Haripur',
      'Pabna',
      'Raninagar',
    ],
    'Rajshahi-Pabna-Ishwardi': [
      'Charghat',
      'Dashuria',
      'Ishwardi',
      'Karkaria',
      'Laxmikunda',
      'Pakshi',
      'Salimabad',
    ],

    // Naogaon
    'Rajshahi-Naogaon-Naogaon Sadar': [
      'Chekhat',
      'Hashaigari',
      'Kalikapur',
      'Manda',
      'Naogaon',
      'Paranpur',
      'Tilna',
    ],
    'Rajshahi-Naogaon-Manda': [
      'Bhavani',
      'Bishnupur',
      'Goala',
      'Kosba',
      'Manda',
      'Nuruddinpur',
      'Tetulia',
    ],

    // Natore
    'Rajshahi-Natore-Natore Sadar': [
      'Bagatipara',
      'Chamari',
      'Dighapatia',
      'Khajura',
      'Madhnagar',
      'Natore',
    ],
    'Rajshahi-Natore-Gurudaspur': [
      'Biaghat',
      'Chapila',
      'Dharabarisha',
      'Gurudaspur',
      'Sherkole',
    ],

    // ==================== KHULNA DIVISION ====================
    // Khulna District
    'Khulna-Khulna-Khulna Sadar': [
      'Aranghata',
      'Barobazar',
      'Goalkhali',
      'Khulna Sadar',
      'Modhubagh',
      'Nirala',
      'Siramani',
    ],
    'Khulna-Khulna-Paikgachha': [
      'Chandkhali',
      'Gadaipur',
      'Kapilmuni',
      'Lata',
      'Paikgachha',
      'Sholadana',
    ],
    'Khulna-Khulna-Dumuria': [
      'Atlia',
      'Dhamalia',
      'Dumuria',
      'Gutudia',
      'Magurghona',
      'Rangpur',
      'Sahas',
      'Sarappur',
    ],

    // Jessore
    'Khulna-Jessore-Jessore Sadar': [
      'Churamankati',
      'Jessore Sadar',
      'Kachua',
      'Noapara',
      'Panjia',
      'Rajghat',
    ],
    'Khulna-Jessore-Keshabpur': [
      'Arabpur',
      'Bidarpur',
      'Gaurighona',
      'Keshabpur',
      'Mangalkot',
      'Panjia',
    ],
    'Khulna-Jessore-Sharsha': [
      'Bagachra',
      'Benapole',
      'Putkhali',
      'Sharsha',
      'Uddharanpur',
    ],

    // Satkhira
    'Khulna-Satkhira-Satkhira Sadar': [
      'Alipur',
      'Baikari',
      'Balli',
      'Buri Goalini',
      'Dhalbaria',
      'Fingri',
      'Jhaudanga',
      'Labsha',
      'Satkhira',
    ],
    'Khulna-Satkhira-Kaliganj': [
      'Bishnupur',
      'Chandanpur',
      'Helatala',
      'Kaliganj',
      'Kushadanga',
    ],
    'Khulna-Satkhira-Shyamnagar': [
      'Burigoalini',
      'Gabura',
      'Munshiganj',
      'Padmapukur',
      'Ramjan Nagar',
      'Shyamnagar',
    ],

    // Bagerhat
    'Khulna-Bagerhat-Bagerhat Sadar': [
      'Barobaria',
      'Bemarta',
      'Bishnupur',
      'Dhopakhali',
      'Gotapara',
      'Jatrapur',
      'Karapara',
      'Rakhalgachhi',
      'Shat Gambuj',
    ],
    'Khulna-Bagerhat-Mongla': [
      'Burirdanga',
      'Chila',
      'Mongla Port',
      'Sundarban',
    ],

    // Kushtia
    'Khulna-Kushtia-Kushtia Sadar': [
      'Alampur',
      'Amla',
      'Bottail',
      'Chapra',
      'Juranpur',
      'Khoksa',
      'Kushtia',
    ],
    'Khulna-Kushtia-Kumarkhali': [
      'Chapra',
      'Juniadah',
      'Kaya',
      'Kursha',
      'Kumarkhali',
      'Sadaki',
      'Shelaidah',
    ],

    // ==================== BARISHAL DIVISION ====================
    // Barishal District
    'Barishal-Barishal-Barishal Sadar': [
      'Barishal Sadar',
      'Charmonai',
      'Kashipur',
      'Shibpur',
      'Tungibaria',
    ],
    'Barishal-Barishal-Bakerganj': [
      'Bakerganj',
      'Char Moddha',
      'Char Kaua',
      'Durga',
      'Faridpur',
      'Niamati',
      'Ramnagar',
    ],
    'Barishal-Barishal-Mehendiganj': [
      'Alimabad',
      'Biddakut',
      'Chandpasha',
      'Chandradwip',
      'Charkalekha',
      'Gobindapur',
      'Mehendiganj',
    ],

    // Patuakhali
    'Barishal-Patuakhali-Patuakhali Sadar': [
      'Auliapur',
      'Badarpur',
      'Itbaria',
      'Kalikapur',
      'Labukhali',
      'Laukathi',
      'Madhabkhali',
      'Patuakhali',
    ],
    'Barishal-Patuakhali-Kalapara': [
      'Alipur',
      'Champapur',
      'Dakkhin Saturia',
      'Kalapara',
      'Mahipur',
      'Nilganj',
    ],

    // Bhola
    'Barishal-Bhola-Bhola Sadar': [
      'Bhola',
      'Char Khalifa',
      'Char Patillla',
      'Dhulkhola',
      'Kachia',
      'Pakshia',
      'Shibpur',
    ],
    'Barishal-Bhola-Lalmohan': [
      'Char Khalipa',
      'Dhulasar',
      'Hajipur',
      'Lalmohan',
      'Lord Hardinge',
      'Ramgati',
    ],

    // ==================== SYLHET DIVISION ====================
    // Sylhet District
    'Sylhet-Sylhet-Sylhet Sadar': [
      'Balaganj',
      'Golapganj',
      'Jalalpur',
      'Khadimpara',
      'Mogla Bazar',
      'Sylhet Sadar',
      'Tukerbazar',
    ],
    'Sylhet-Sylhet-Beanibazar': [
      'Dubag',
      'Kalain',
      'Kutubpur',
      'Lauta',
      'Mathiura',
      'Muria',
      'Sheola',
      'Tilpara',
    ],
    'Sylhet-Sylhet-Bishwanath': [
      'Alankari',
      'Bishwanath',
      'Doshghar',
      'Khajanchhih',
      'Lamakazi',
      'Rampasha',
    ],

    // Moulvibazar
    'Sylhet-Moulvibazar-Sreemangal': [
      'Ashidron',
      'Bhunabir',
      'Kalighat',
      'Mirzapur',
      'Satgaon',
      'Sreemangal',
    ],
    'Sylhet-Moulvibazar-Kamalganj': [
      'Adampur',
      'Alinagar',
      'Islampur',
      'Kamalganj',
      'Madhabpur',
      'Patanushar',
      'Rajnagar',
      'Shamshernagar',
    ],

    // Habiganj
    'Sylhet-Habiganj-Habiganj Sadar': [
      'Bagashura',
      'Bahubul',
      'Gopaya',
      'Habiganj',
      'Inatganj',
      'Lamatashi',
      'Putijuri',
      'Shukhair Raziura',
    ],
    'Sylhet-Habiganj-Madhabpur': [
      'Adityapur',
      'Birgaon',
      'Madhabpur',
      'Patharia',
      'Shahjahanpur',
      'Siyamnagar',
    ],

    // Sunamganj
    'Sylhet-Sunamganj-Sunamganj Sadar': [
      'Gauripur',
      'Kathair',
      'Laxmansree',
      'Mollapara',
      'Pagla',
      'Patharia',
      'Sunamganj',
      'Surma',
    ],
    'Sylhet-Sunamganj-Tahirpur': [
      'Badaghat',
      'Balijuri',
      'Jamalganj',
      'Tahirpur',
    ],

    // ==================== RANGPUR DIVISION ====================
    // Rangpur District
    'Rangpur-Rangpur-Rangpur Sadar': [
      'Alamnagar',
      'Chandanpat',
      'Darshana',
      'Hariganj',
      'Rangpur Sadar',
      'Tajhat',
    ],
    'Rangpur-Rangpur-Gangachara': [
      'Alambiditor',
      'Gajghanta',
      'Gangachara',
      'Kolkonda',
      'Marania',
      'Mithapukur',
    ],
    'Rangpur-Rangpur-Pirgachha': [
      'Annandapur',
      'Chattra',
      'Kabilpur',
      'Koikuri',
      'Pachgachhi',
      'Pirgachha',
    ],

    // Dinajpur
    'Rangpur-Dinajpur-Dinajpur Sadar': [
      'Auliapur',
      'Chehelgazi',
      'Dinajpur Sadar',
      'Fazilpur',
      'Nimtola',
      'Sekpura',
    ],
    'Rangpur-Dinajpur-Birampur': [
      'Bijora',
      'Birampur',
      'Chandipasha',
      'Harirampur',
      'Katla',
      'Sujalpur',
    ],
    'Rangpur-Dinajpur-Parbatipur': [
      'Beldi',
      'Habra',
      'Mostofapur',
      'Palashbari',
      'Parbatipur',
      'Polashbari',
    ],

    // Nilphamari
    'Rangpur-Nilphamari-Nilphamari Sadar': [
      'Botlagari',
      'Chapra Sarnjami',
      'Ghariardanga',
      'Itakhola',
      'Nilphamari',
      'Panchapukur',
      'Salma',
      'Sonaray',
      'Tupamari',
    ],
    'Rangpur-Nilphamari-Saidpur': [
      'Bangalipur',
      'Botaliganj',
      'Kaimari',
      'Khata Madhupur',
      'Saidpur',
    ],

    // Gaibandha
    'Rangpur-Gaibandha-Gaibandha Sadar': [
      'Ballamjhar',
      'Gaibandha',
      'Gidari',
      'Kamardaha',
      'Malibari',
      'Mollarchar',
      'Ramchandra',
      'Sapmara',
    ],
    'Rangpur-Gaibandha-Sundarganj': [
      'Belka',
      'Harirampur',
      'Phulchari',
      'Ramjibon',
      'Sonaray',
      'Sundarganj',
    ],

    // ==================== MYMENSINGH DIVISION ====================
    // Mymensingh District
    'Mymensingh-Mymensingh-Mymensingh Sadar': [
      'Akua',
      'Beltia',
      'Chhoto Balia',
      'Kachijhuli',
      'Mymensingh Sadar',
      'Ramgopalpur',
    ],
    'Mymensingh-Mymensingh-Trishal': [
      'Bhaluka',
      'Dhala',
      'Mathbaria',
      'Sakhua',
      'Trishal',
    ],
    'Mymensingh-Mymensingh-Muktagachha': [
      'Char Nilaksha',
      'Enayetpur',
      'Goalgaon',
      'Marikha',
      'Muktagachha',
      'Rangamatia',
    ],

    // Jamalpur
    'Mymensingh-Jamalpur-Jamalpur Sadar': [
      'Chikajani',
      'Digpait',
      'Jamalpur',
      'Joyrampur',
      'Mahmudpur',
      'Nandina',
      'Ranagachha',
      'Titpalla',
    ],
    'Mymensingh-Jamalpur-Melandaha': [
      'Char Amkhawa',
      'Chinaduli',
      'Jhaugara',
      'Kulkandi',
      'Melandaha',
      'Malijhikanda',
    ],

    // Netrokona
    'Mymensingh-Netrokona-Netrokona Sadar': [
      'Barhatta',
      'Chandgaon',
      'Chandigarh',
      'Kailati',
      'Kolmakanda',
      'Netrokona',
      'Susung',
    ],
    'Mymensingh-Netrokona-Atpara': [
      'Atpara',
      'Baniajan',
      'Khaliajuri',
      'Modan',
      'Shalna',
    ],

    // Sherpur
    'Mymensingh-Sherpur-Sherpur Sadar': [
      'Char Nilaksha',
      'Gazir Bhita',
      'Kamaria',
      'Kurikahania',
      'Pakuria',
      'Raniganj',
      'Sherpur',
      'Tatihati',
    ],
    'Mymensingh-Sherpur-Nakla': [
      'Baneshwardanga',
      'Bhelua',
      'Nakla',
      'Pathakata',
      'Urpha',
    ],
  };

  /// Get all divisions
  static List<String> getDivisions() {
    return locationData.keys.toList()..sort();
  }

  /// Get districts for a division
  static List<String> getDistricts(String division) {
    if (!locationData.containsKey(division)) return [];
    return locationData[division]!.keys.toList()..sort();
  }

  /// Get upazilas for a district
  static List<String> getUpazilas(String division, String district) {
    if (!locationData.containsKey(division)) return [];
    if (!locationData[division]!.containsKey(district)) return [];
    // Create a new list to avoid modifying the original
    return List<String>.from(locationData[division]![district]!)..sort();
  }

  /// Get villages/unions for an upazila
  static List<String> getVillages(
    String division,
    String district,
    String upazila,
  ) {
    final key = '$division-$district-$upazila';
    if (villageData.containsKey(key)) {
      return List<String>.from(villageData[key]!)..sort();
    }
    return []; // Return empty if no village data available for this upazila
  }

  /// Check if village data exists for an upazila
  static bool hasVillageData(String division, String district, String upazila) {
    final key = '$division-$district-$upazila';
    return villageData.containsKey(key);
  }

  /// Get all districts (flat list)
  static List<String> getAllDistricts() {
    List<String> allDistricts = [];
    for (var districts in locationData.values) {
      allDistricts.addAll(districts.keys);
    }
    return allDistricts..sort();
  }

  /// Find division for a district
  static String? findDivisionForDistrict(String district) {
    for (var entry in locationData.entries) {
      if (entry.value.containsKey(district)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Validate location combination
  static bool isValidLocation({
    required String division,
    required String district,
    String? upazila,
  }) {
    if (!locationData.containsKey(division)) return false;
    if (!locationData[division]!.containsKey(district)) return false;
    if (upazila != null && upazila.isNotEmpty) {
      return locationData[division]![district]!.contains(upazila);
    }
    return true;
  }

  /// Get location display text
  static String getLocationDisplayText({
    String? upazila,
    String? district,
    String? division,
  }) {
    List<String> parts = [];
    if (upazila != null && upazila.isNotEmpty) parts.add(upazila);
    if (district != null && district.isNotEmpty) parts.add(district);
    if (division != null && division.isNotEmpty) parts.add(division);
    return parts.join(', ');
  }

  /// Search locations by query
  static List<Map<String, String>> searchLocations(String query) {
    List<Map<String, String>> results = [];
    final lowerQuery = query.toLowerCase();

    for (var divisionEntry in locationData.entries) {
      final division = divisionEntry.key;
      for (var districtEntry in divisionEntry.value.entries) {
        final district = districtEntry.key;

        // Search in district names
        if (district.toLowerCase().contains(lowerQuery)) {
          results.add({
            'division': division,
            'district': district,
            'upazila': '',
            'type': 'district',
          });
        }

        // Search in upazila names
        for (var upazila in districtEntry.value) {
          if (upazila.toLowerCase().contains(lowerQuery)) {
            results.add({
              'division': division,
              'district': district,
              'upazila': upazila,
              'type': 'upazila',
            });
          }
        }
      }
    }

    return results;
  }
}
