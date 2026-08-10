import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import 'delivery_tracker_screen.dart';

class MedicalShopScreen extends StatefulWidget {
  MedicalShopScreen({super.key});

  @override
  State<MedicalShopScreen> createState() => _MedicalShopScreenState();
}

class _MedicalShopScreenState extends State<MedicalShopScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Analgesics',
    'Antibiotics',
    'Antihistamines',
    'NSAIDs',
    'Antidiarrheals',
    'Antidiabetics',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final cart = provider.cart;

    // Filter logic
    final filteredMedicines = provider.medicines.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || m.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medicate Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      SizedBox(height: 4),
                      Text('Secure Pharmaceutical Dispenser', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  // Cart button with badge
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: () => _showCartBottomSheet(context, provider),
                        icon: Icon(Icons.shopping_cart_rounded, color: AppTheme.primaryCyan, size: 28),
                      ),
                      if (cart.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            cart.length.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),

              // Search Bar
              GlassCard(
                radius: 16,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                borderColor: AppTheme.borderCard,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: AppTheme.primaryCyan, size: 20),
                    hintText: 'Search medicines (e.g. Paracetamol)...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 18),

              // Category Scroller
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSel = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryTeal : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? AppTheme.primaryCyan : AppTheme.borderCard),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSel ? Colors.white : AppTheme.textSecondary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Medicines Grid
              Expanded(
                child: filteredMedicines.isEmpty
                    ? Center(child: Text('No medicines found in this category.', style: TextStyle(color: AppTheme.textSecondary)))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: filteredMedicines.length,
                        itemBuilder: (context, idx) {
                          final med = filteredMedicines[idx];
                          return _buildMedicineCard(context, provider, med);
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context, MedicateProvider provider, Medicine med) {
    final hasStock = med.stock > 0;

    return GlassCard(
      radius: 18,
      padding: EdgeInsets.all(12.0),
      borderColor: hasStock ? AppTheme.borderCard : Colors.redAccent.withOpacity(0.2),
      fillColor: hasStock ? Color(0x05FFFFFF) : Colors.redAccent.withOpacity(0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              med.category,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
            ),
          ),
          SizedBox(height: 12),
          Text(
            med.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            med.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${med.price.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryCyan),
              ),
              Text(
                hasStock ? '${med.stock} left' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: hasStock ? AppTheme.textSecondary : Colors.redAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasStock ? () => provider.addToCart(med) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasStock ? AppTheme.primaryTeal : Colors.grey[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              child: Text(
                hasStock ? 'ADD TO CART' : 'UNAVAILABLE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context, MedicateProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cart = provider.cart;
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.only(top: 10),
              child: GlassCard(
                radius: 30,
                borderColor: AppTheme.primaryCyan.withOpacity(0.3),
                fillColor: AppTheme.background.withOpacity(0.98),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryCyan),
                        SizedBox(width: 10),
                        Text('My Medical Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      ],
                    ),
                    SizedBox(height: 20),

                    Expanded(
                      child: cart.isEmpty
                          ? Center(child: Text('Your cart is currently empty.', style: TextStyle(color: AppTheme.textSecondary)))
                          : ListView.builder(
                              itemCount: cart.length,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemBuilder: (context, index) {
                                final item = cart[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: GlassCard(
                                    radius: 16,
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.medicine.name, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                              SizedBox(height: 4),
                                              Text('₹${item.medicine.price.toStringAsFixed(2)} each', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryCyan, size: 20),
                                              onPressed: () {
                                                setModalState(() {
                                                  provider.adjustCartQuantity(item.medicine.id, -1);
                                                });
                                              },
                                            ),
                                            Text(item.quantity.toString(), style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryCyan, size: 20),
                                              onPressed: () {
                                                setModalState(() {
                                                  provider.adjustCartQuantity(item.medicine.id, 1);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () {
                                            setModalState(() {
                                              provider.removeFromCart(item.medicine.id);
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Total & Checkout
                    if (cart.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Cost:', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                                Text(
                                  '₹${provider.cartTotal.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  provider.checkoutCart();
                                  provider.startDeliverySimulation();
                                  Navigator.pop(context); // Close sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DeliveryTrackerScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryTeal,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('CHECKOUT NOW', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


}
