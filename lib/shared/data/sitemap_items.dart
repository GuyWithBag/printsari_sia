import 'package:printsari_sia/shared/types/types.dart';

const siteMapItems = <SiteMapItem>[
  SiteMapItem(
    title: 'Dashboard',
    iconPath: 'assets/house.svg',
    path: '/',
    roles: [UserRoleType.cashier, UserRoleType.owner, UserRoleType.manager],
  ),
  SiteMapItem(
    title: 'Products & Services',
    iconPath: 'assets/settings.svg',
    path: '/products-services',
    roles: [UserRoleType.cashier, UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'POS Terminal',
    iconPath: 'assets/shopping-cart.svg',
    path: '/pos',
    roles: [UserRoleType.cashier, UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Transactions',
    iconPath: 'assets/clipboard-list.svg',
    path: '/transactions',
    roles: [UserRoleType.owner, UserRoleType.manager],
  ),
  SiteMapItem(
    title: 'Activity Log',
    iconPath: 'assets/clipboard-list.svg',
    path: '/activity-log',
    roles: [UserRoleType.owner, UserRoleType.manager],
  ),
  SiteMapItem(
    title: 'Inventory',
    iconPath: 'assets/package.svg',
    path: '/inventory',
    roles: [UserRoleType.owner, UserRoleType.manager],
  ),
  SiteMapItem(
    title: 'Financial Reports',
    iconPath: 'assets/chart-column.svg',
    path: '/financial-reports',
    roles: [UserRoleType.owner, UserRoleType.manager],
  ),
  SiteMapItem(
    title: 'Business Expenses',
    iconPath: 'assets/dollar-sign.svg',
    path: '/expenses',
    roles: [UserRoleType.owner, UserRoleType.manager],
  ),
  SiteMapItem(
    title: 'Customers',
    iconPath: 'assets/users.svg',
    path: '/customers',
    roles: [UserRoleType.owner, UserRoleType.manager, UserRoleType.cashier],
  ),
  SiteMapItem(
    title: 'User Management',
    iconPath: 'assets/users.svg',
    path: '/users',
    roles: [UserRoleType.owner],
  ),
  SiteMapItem(
    title: 'Archives',
    iconPath: 'assets/package.svg',
    path: '/archives',
    roles: [UserRoleType.owner],
  ),
];
