import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Подписка',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Payment Methods Section
              const Text(
                'Способы оплаты',
                style: TextStyle(
                  color: Color(0xFFFF8E30),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3135),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildPaymentMethodItem(
                      icon: Icons.add_card,
                      label: 'Добавить карту',
                      isFirst: true,
                    ),
                    const Divider(height: 1, color: Color(0xFFABABAB), indent: 20, endIndent: 20),
                    _buildPaymentMethodItem(
                      icon: Icons.credit_card,
                      label: 'MIR • 7850',
                      trailing: const Icon(Icons.delete_outline, color: Color(0xFF557578), size: 18),
                    ),
                    const Divider(height: 1, color: Color(0xFFABABAB), indent: 20, endIndent: 20),
                    _buildPaymentMethodItem(
                      icon: Icons.account_balance,
                      label: 'СБП',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Subscription Plans
              _buildPlanCard(
                title: 'Кредит',
                role: 'Фрилансер',
                tags: 'Страхование • КАСКО',
                buttonText: 'Сменить тариф',
                isActive: true,
              ),
              const SizedBox(height: 15),
              _buildPlanCard(
                title: 'Кредит',
                role: 'Фрилансер',
                tags: 'Страхование • КАСКО',
                buttonText: 'Выбрать тариф',
                isActive: false,
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFC6C6C6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF0C3135)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String role,
    required String tags,
    required String buttonText,
    required bool isActive,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage("https://ui-avatars.com/api/?name=Plan&background=334D50&color=fff"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role,
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tags,
                      style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF334D50),
              borderRadius: BorderRadius.circular(10),
              border: isActive ? Border.all(color: const Color(0xFFFF8E30), width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Russo One',
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
