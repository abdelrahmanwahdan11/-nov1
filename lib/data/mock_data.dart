import '../models/car_item.dart';
import '../models/jewelry_item.dart';
import '../models/offer.dart';
import '../models/user.dart';

class MockData {
  const MockData._();

  static List<UserModel> get users => const [
        UserModel(
          id: 'u1',
          email: 'guest@jewelx.app',
          displayName: 'Guest',
          isGuest: true,
        ),
      ];

  static List<JewelryItem> get jewelry => _jewelry;
  static List<CarItem> get cars => _cars;

  static final List<JewelryItem> _jewelry = [
    JewelryItem(
      id: 'j1',
      name: 'خاتم سوليتير ماسي',
      brand: 'Royal Gems',
      category: JewelryCategory.ring,
      images: const [
        'https://picsum.photos/seed/ring_a/900/900',
        'https://picsum.photos/seed/ring_b/900/900',
      ],
      model3d: 'https://example.com/models/solitaire.glb',
      material: JewelryMaterial.gold,
      gem: 'Diamond',
      carat: 1.2,
      weightGrams: 4.8,
      ringSize: '43',
      color: 'G',
      condition: JewelryCondition.likeNew,
      certificate: 'GIA 123456',
      price: 4050.0,
      negotiable: true,
      forSale: true,
      awaitOffers: false,
      tips: 'يحفظ منفردًا بعيدًا عن الخدش',
      description: 'خاتم سوليتير ذهبي عيار 18 مع ماسة بقصّة رائعة.',
      createdAt: 1710000000,
    ),
    JewelryItem(
      id: 'j2',
      name: 'قلادة زمرد كلاسيكية',
      brand: 'Emerald Studio',
      category: JewelryCategory.necklace,
      images: const [
        'https://picsum.photos/seed/necklace_a/900/900',
        'https://picsum.photos/seed/necklace_b/900/900',
      ],
      model3d: 'https://example.com/models/emerald_necklace.glb',
      material: JewelryMaterial.platinum,
      gem: 'Emerald',
      carat: 2.0,
      weightGrams: 7.2,
      ringSize: '',
      color: 'Deep Green',
      condition: JewelryCondition.veryGood,
      certificate: '',
      price: null,
      negotiable: true,
      forSale: false,
      awaitOffers: true,
      tips: 'يفضل تنظيفه بقطعة قماش ناعمة.',
      description: 'قلادة بلاتينية بحجر زمرد مركزي، مع انتظار عروض شراء.',
      createdAt: 1710000100,
    ),
  ];

  static final List<CarItem> _cars = [
    CarItem(
      id: 'c1',
      name: 'Sedan S',
      brand: 'BrandX',
      images: const ['https://picsum.photos/seed/car1/1000/600'],
      year: 2022,
      mileage: 15000,
      price: 20000.0,
      specs: const {'hp': '180', 'transmission': 'AT', 'fuel': 'Petrol'},
    ),
    CarItem(
      id: 'c2',
      name: 'SUV Z',
      brand: 'BrandY',
      images: const ['https://picsum.photos/seed/car2/1000/600'],
      year: 2021,
      mileage: 23000,
      price: 28000.0,
      specs: const {'hp': '220', 'transmission': 'AT', 'fuel': 'Hybrid'},
    ),
  ];

  static List<Offer> mockOffers(String itemId) {
    return [
      Offer(
        id: 'o1',
        itemId: itemId,
        amount: 3990,
        message: 'هل السعر قابل للتفاوض؟',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        from: 'buyer@jewelx.app',
      ),
    ];
  }
}
