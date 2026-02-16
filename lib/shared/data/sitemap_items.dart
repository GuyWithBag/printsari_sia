import 'package:printsari_sia/shared/types/types.dart';

const siteMapItems = <SiteMapItem>[
  SiteMapItem(
    title: 'Dashboard',
    iconPath: 'assets/house.svg',
    path: '/',
    roles: [UserRoleType.cashier, UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'POS Terminal',
    iconPath: 'assets/shopping-cart.svg',
    path: '/pos',
    roles: [UserRoleType.cashier, UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Activity Log',
    iconPath: 'assets/clipboard-list.svg',
    path: '/activity-log',
    roles: [UserRoleType.cashier, UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Inventory',
    iconPath: 'assets/package.svg',
    path: '/inventory',
    roles: [UserRoleType.cashier, UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Financial Reports',
    iconPath: 'assets/chart-column.svg',
    path: '/financial-reports',
    roles: [UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Products & Services',
    iconPath: 'assets/settings.svg',
    path: '/products-services',
    roles: [UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Business Expenses',
    iconPath: 'assets/dollar-sign.svg',
    path: '/expenses',
    roles: [UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'User Management',
    iconPath: 'assets/users.svg',
    path: '/users',
    roles: [UserRoleType.owner],
  ),
];
