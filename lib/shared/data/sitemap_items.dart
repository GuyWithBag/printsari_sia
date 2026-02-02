import 'package:printsari_sia/shared/types/types.dart';

const siteMapItems = <SiteMapItem>[
  SiteMapItem(
    title: 'Dashboard',
    iconPath: 'assets/house.svg',
    path: '/',
    roles: [Role.cashier, Role.admin],
  ),
  SiteMapItem(
    title: 'POS Terminal',
    iconPath: 'assets/shopping-cart.svg',
    path: '/pos',
    roles: [Role.cashier, Role.admin],
  ),
  SiteMapItem(
    title: 'Activity Log',
    iconPath: 'assets/clipboard-list.svg',
    path: '/activity-log',
    roles: [Role.cashier, Role.admin],
  ),
  SiteMapItem(
    title: 'Inventory',
    iconPath: 'assets/package.svg',
    path: '/inventory',
    roles: [Role.cashier, Role.admin],
  ),
  SiteMapItem(
    title: 'Financial Reports',
    iconPath: 'assets/chart-column.svg',
    path: '/financial-reports',
    roles: [Role.admin],
  ),
  SiteMapItem(
    title: 'Products & Services',
    iconPath: 'assets/settings.svg',
    path: '/products-services',
    roles: [Role.admin],
  ),
  SiteMapItem(
    title: 'Business Expenses',
    iconPath: 'assets/dollar-sign.svg',
    path: '/expenses',
    roles: [Role.admin],
  ),
  SiteMapItem(
    title: 'User Management',
    iconPath: 'assets/users.svg',
    path: '/users',
    roles: [Role.admin],
  ),
];
