
/*
PART 1 - LIFECYCLE ANSWERS

a) On first opening:
   initState(), didChangeDependencies(), then build().

b) After pressing the favorite button:
   setState() triggers build() again.

c) When leaving a page:
   deactivate() runs when the State leaves the tree.
   dispose() runs when its State is permanently removed.

d) When resizing the browser:
   didChangeDependencies() can run when MediaQuery changes.
   build() runs again to update the UI.

PART 4 - NAVIGATION ANSWERS

1) context.go replaces the current navigation location.
   context.push adds a page on top of the current page.

2) Use go for Login -> Products.
   Use push for Products -> Details to return with a result.

3) Path parameter:
   /details/Laptop/1200

   Query parameter:
   /products?user=Guest

Navigator version will be added and commented out later.
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'product_widgets.dart';

void main() {
  runApp(const MyApp());
}

final List<Map<String, dynamic>> products = [
  {'name': 'Laptop', 'price': 1200},
  {'name': 'Phone', 'price': 800},
  {'name': 'Headphones', 'price': 150},
  {'name': 'Keyboard', 'price': 100},
];

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) {
        final username =
            state.uri.queryParameters['user'] ?? 'Guest';

        return ProductsPage(username: username);
      },
    ),
    GoRoute(
      path: '/details/:name/:price',
      name: 'details',
      builder: (context, state) {
        final name = state.pathParameters['name']!;
        final price = int.parse(state.pathParameters['price']!);

        return DetailsPage(
          name: name,
          price: price,
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mini Product Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print('LoginPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('LoginPage: didChangeDependencies');
  }

  @override
  void deactivate() {
    print('LoginPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('LoginPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('LoginPage: build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.goNamed(
              'products',
              queryParameters: {'user': 'Guest'},
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  final String username;

  const ProductsPage({
    super.key,
    required this.username,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int favorites = 0;
  String cartMessage = '';

  @override
  void initState() {
    super.initState();
    print('ProductsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.sizeOf(context);

    print(
      'ProductsPage: didChangeDependencies -> '
          'width: ${size.width}, height: ${size.height}',
    );
  }

  @override
  void deactivate() {
    print('ProductsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('ProductsPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ProductsPage: build');

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${widget.username}'),
            Text('Favorites: $favorites'),
            Text(
              'Screen width: ${screenWidth.toStringAsFixed(1)}',
            ),
            if (cartMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  cartMessage,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            SizedBox(
              height: isSmallScreen ? 420 : 280,
              child: isSmallScreen
                  ? ProductsListView(
                products: products,
                onFavoritePressed: () {
                  setState(() {
                    favorites++;
                  });
                },
                onProductTap: (index) {
                  _openDetails(index);
                },
              )
                  : ProductsGridView(
                products: products,
                onFavoritePressed: () {
                  setState(() {
                    favorites++;
                  });
                },
                onProductTap: (index) {
                  _openDetails(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(int index) async {
    final product = products[index];

    final result = await context.push<String>(
      '/details/'
          '${Uri.encodeComponent(product['name'].toString())}/'
          '${product['price']}',
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        cartMessage = result;
      });
    }
  }
}

class DetailsPage extends StatefulWidget {
  final String name;
  final int price;

  const DetailsPage({
    super.key,
    required this.name,
    required this.price,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
    print('DetailsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DetailsPage: didChangeDependencies');
  }

  @override
  void deactivate() {
    print('DetailsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('DetailsPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DetailsPage: build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('Price: \$${widget.price}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.pop('${widget.name} added to cart');
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}




/*
========================================================
NAVIGATOR VERSION - PART 2
Kept commented out because go_router is the active version.
========================================================
*/

/*
NAVIGATOR VERSION - PART 2


import 'package:flutter/material.dart';
import 'product_widgets.dart';

void main() {
  runApp(const MyApp());
}

final List<Map<String, dynamic>> products = [
  {'name': 'Laptop', 'price': 1200},
  {'name': 'Phone', 'price': 800},
  {'name': 'Headphones', 'price': 150},
  {'name': 'Keyboard', 'price': 100},
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Product Catalog - Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/products': (context) => const ProductsPage(),
      },
    );
  }
}

// ==================== LOGIN PAGE ====================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print('LoginPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('LoginPage: didChangeDependencies');
  }

  @override
  void deactivate() {
    print('LoginPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('LoginPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('LoginPage: build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/products',
              arguments: 'Guest',
            );
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}

// ==================== PRODUCTS PAGE ====================

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int favorites = 0;
  String cartMessage = '';

  @override
  void initState() {
    super.initState();
    print('ProductsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.sizeOf(context);

    print(
      'ProductsPage: didChangeDependencies -> '
          'width: ${size.width}, height: ${size.height}',
    );
  }

  @override
  void deactivate() {
    print('ProductsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('ProductsPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ProductsPage: build');

    final username =
        ModalRoute.of(context)?.settings.arguments as String? ??
            'Guest';

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $username'),
            Text('Favorites: $favorites'),
            Text(
              'Screen width: ${screenWidth.toStringAsFixed(1)}',
            ),
            if (cartMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  cartMessage,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: isSmallScreen ? 420 : 280,
              child: isSmallScreen
                  ? ProductsListView(
                products: products,
                onFavoritePressed: () {
                  setState(() {
                    favorites++;
                  });
                },
                onProductTap: (index) {
                  _openDetails(index);
                },
              )
                  : ProductsGridView(
                products: products,
                onFavoritePressed: () {
                  setState(() {
                    favorites++;
                  });
                },
                onProductTap: (index) {
                  _openDetails(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(int index) async {
    final product = products[index];

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          name: product['name'].toString(),
          price: product['price'] as int,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        cartMessage = result;
      });
    }
  }
}

// ==================== DETAILS PAGE ====================

class DetailsPage extends StatefulWidget {
  final String name;
  final int price;

  const DetailsPage({
    super.key,
    required this.name,
    required this.price,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
    print('DetailsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DetailsPage: didChangeDependencies');
  }

  @override
  void deactivate() {
    print('DetailsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('DetailsPage: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DetailsPage: build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('Price: \$${widget.price}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  '${widget.name} added to cart',
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

*/

