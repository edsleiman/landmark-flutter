enum AccountType { customer, realtor, admin, developer }

extension AccountTypeLabel on AccountType {
  String get label {
    switch (this) {
      case AccountType.customer:
        return 'Customer';
      case AccountType.realtor:
        return 'Realtor';
      case AccountType.admin:
        return 'Admin';
      case AccountType.developer:
        return 'Developer';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final AccountType accountType;
  final bool isBuyer;
  final bool isSeller;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    this.isBuyer = false,
    this.isSeller = false,
  });

  String get roleLabel {
    if (accountType != AccountType.customer) return accountType.label;
    if (isBuyer && isSeller) return 'Buyer & Seller';
    if (isSeller) return 'Seller';
    return 'Buyer';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'accountType': accountType.name,
        'isBuyer': isBuyer,
        'isSeller': isSeller,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        accountType: AccountType.values.byName(j['accountType']),
        isBuyer: j['isBuyer'] ?? false,
        isSeller: j['isSeller'] ?? false,
      );
}
