import 'package:lucide_icons/lucide_icons.dart';
import '../models/widget_template.dart';

class ComprehensiveTemplates {
  // ============= FINANCE CATEGORY (30 Templates) =============
  static final List<WidgetTemplate> financeTemplates = [
    WidgetTemplate(
      id: 'fin_001',
      title: 'Portfolio Performance Dashboard',
      description: 'Track overall portfolio returns and metrics',
      prompt: 'Create a portfolio performance dashboard with total value, returns, and asset allocation',
      type: 'dashboard',
      icon: LucideIcons.pieChart,
      tags: ['portfolio', 'performance', 'returns'],
      category: 'Finance',
      usageCount: 2450,
    ),
    WidgetTemplate(
      id: 'fin_002',
      title: 'Expense Tracker',
      description: 'Monitor monthly expenses by category',
      prompt: 'Build an expense tracker with categories, trends, and budget comparison',
      type: 'dashboard',
      icon: LucideIcons.receipt,
      tags: ['expenses', 'budget', 'tracking'],
      category: 'Finance',
      usageCount: 3100,
    ),
    WidgetTemplate(
      id: 'fin_003',
      title: 'Investment Calculator',
      description: 'Calculate ROI and compound interest',
      prompt: 'Create an investment calculator for ROI, compound interest, and future value',
      type: 'calculator',
      icon: LucideIcons.calculator,
      tags: ['investment', 'calculator', 'ROI'],
      category: 'Finance',
      usageCount: 1890,
    ),
    WidgetTemplate(
      id: 'fin_004',
      title: 'Cash Flow Statement',
      description: 'Visualize cash inflows and outflows',
      prompt: 'Design a cash flow statement showing income, expenses, and net cash flow',
      type: 'report',
      icon: LucideIcons.arrowUpDown,
      tags: ['cashflow', 'income', 'expenses'],
      category: 'Finance',
      usageCount: 2200,
    ),
    WidgetTemplate(
      id: 'fin_005',
      title: 'Budget Planner',
      description: 'Plan and track monthly budgets',
      prompt: 'Build a budget planner with categories, allocations, and variance tracking',
      type: 'planner',
      icon: LucideIcons.clipboardList,
      tags: ['budget', 'planning', 'finance'],
      category: 'Finance',
      usageCount: 2800,
    ),
    WidgetTemplate(
      id: 'fin_006',
      title: 'Stock Market Tracker',
      description: 'Real-time stock prices and changes',
      prompt: 'Create a stock market tracker with live prices, charts, and watchlist',
      type: 'tracker',
      icon: LucideIcons.trendingUp,
      tags: ['stocks', 'market', 'trading'],
      category: 'Finance',
      usageCount: 3500,
    ),
    WidgetTemplate(
      id: 'fin_007',
      title: 'Loan Calculator',
      description: 'Calculate loan payments and interest',
      prompt: 'Build a loan calculator with EMI, interest rates, and amortization schedule',
      type: 'calculator',
      icon: LucideIcons.percent,
      tags: ['loan', 'EMI', 'calculator'],
      category: 'Finance',
      usageCount: 2100,
    ),
    WidgetTemplate(
      id: 'fin_008',
      title: 'Tax Calculator',
      description: 'Estimate tax obligations',
      prompt: 'Create a tax calculator with deductions, brackets, and refund estimation',
      type: 'calculator',
      icon: LucideIcons.fileText,
      tags: ['tax', 'calculator', 'deductions'],
      category: 'Finance',
      usageCount: 2600,
    ),
    WidgetTemplate(
      id: 'fin_009',
      title: 'Retirement Planner',
      description: 'Plan retirement savings and goals',
      prompt: 'Design a retirement planner with savings goals, projections, and timeline',
      type: 'planner',
      icon: LucideIcons.target,
      tags: ['retirement', 'savings', 'planning'],
      category: 'Finance',
      usageCount: 1950,
    ),
    WidgetTemplate(
      id: 'fin_010',
      title: 'Currency Converter',
      description: 'Convert between different currencies',
      prompt: 'Build a currency converter with live rates and historical trends',
      type: 'converter',
      icon: LucideIcons.dollarSign,
      tags: ['currency', 'forex', 'converter'],
      category: 'Finance',
      usageCount: 2300,
    ),
    WidgetTemplate(
      id: 'fin_011',
      title: 'Profit & Loss Statement',
      description: 'Business P&L analysis',
      prompt: 'Create a P&L statement with revenue, costs, and profit margins',
      type: 'report',
      icon: LucideIcons.barChart,
      tags: ['profit', 'loss', 'business'],
      category: 'Finance',
      usageCount: 1800,
    ),
    WidgetTemplate(
      id: 'fin_012',
      title: 'Invoice Generator',
      description: 'Create and manage invoices',
      prompt: 'Build an invoice generator with templates, tracking, and payment status',
      type: 'generator',
      icon: LucideIcons.fileText,
      tags: ['invoice', 'billing', 'payments'],
      category: 'Finance',
      usageCount: 2400,
    ),
    WidgetTemplate(
      id: 'fin_013',
      title: 'Savings Goal Tracker',
      description: 'Track progress towards savings goals',
      prompt: 'Design a savings goal tracker with milestones and progress visualization',
      type: 'tracker',
      icon: LucideIcons.piggyBank,
      tags: ['savings', 'goals', 'tracking'],
      category: 'Finance',
      usageCount: 2150,
    ),
    WidgetTemplate(
      id: 'fin_014',
      title: 'Credit Score Monitor',
      description: 'Monitor and improve credit score',
      prompt: 'Create a credit score monitor with factors, tips, and history tracking',
      type: 'monitor',
      icon: LucideIcons.creditCard,
      tags: ['credit', 'score', 'monitoring'],
      category: 'Finance',
      usageCount: 1900,
    ),
    WidgetTemplate(
      id: 'fin_015',
      title: 'Dividend Tracker',
      description: 'Track dividend income and yields',
      prompt: 'Build a dividend tracker with payment dates, yields, and income projections',
      type: 'tracker',
      icon: LucideIcons.coins,
      tags: ['dividends', 'income', 'yields'],
      category: 'Finance',
      usageCount: 1750,
    ),
    WidgetTemplate(
      id: 'fin_016',
      title: 'Financial Health Score',
      description: 'Assess overall financial wellness',
      prompt: 'Create a financial health score with metrics, recommendations, and trends',
      type: 'score',
      icon: LucideIcons.heart,
      tags: ['health', 'score', 'wellness'],
      category: 'Finance',
      usageCount: 2050,
    ),
    WidgetTemplate(
      id: 'fin_017',
      title: 'Debt Payoff Planner',
      description: 'Plan debt repayment strategies',
      prompt: 'Design a debt payoff planner with snowball/avalanche methods and timeline',
      type: 'planner',
      icon: LucideIcons.minusCircle,
      tags: ['debt', 'payoff', 'planning'],
      category: 'Finance',
      usageCount: 2250,
    ),
    WidgetTemplate(
      id: 'fin_018',
      title: 'Net Worth Calculator',
      description: 'Calculate and track net worth',
      prompt: 'Build a net worth calculator with assets, liabilities, and trend analysis',
      type: 'calculator',
      icon: LucideIcons.scale,
      tags: ['networth', 'assets', 'liabilities'],
      category: 'Finance',
      usageCount: 1850,
    ),
    WidgetTemplate(
      id: 'fin_019',
      title: 'Bill Payment Reminder',
      description: 'Manage and track bill payments',
      prompt: 'Create a bill payment reminder with due dates, amounts, and auto-pay tracking',
      type: 'reminder',
      icon: LucideIcons.bell,
      tags: ['bills', 'payments', 'reminders'],
      category: 'Finance',
      usageCount: 2500,
    ),
    WidgetTemplate(
      id: 'fin_020',
      title: 'Crypto Portfolio Tracker',
      description: 'Track cryptocurrency investments',
      prompt: 'Build a crypto portfolio tracker with prices, gains/losses, and market data',
      type: 'tracker',
      icon: LucideIcons.bitcoin,
      tags: ['crypto', 'bitcoin', 'portfolio'],
      category: 'Finance',
      usageCount: 2700,
    ),
    WidgetTemplate(
      id: 'fin_021',
      title: 'Emergency Fund Calculator',
      description: 'Calculate emergency fund needs',
      prompt: 'Design an emergency fund calculator with expense analysis and savings plan',
      type: 'calculator',
      icon: LucideIcons.shield,
      tags: ['emergency', 'fund', 'savings'],
      category: 'Finance',
      usageCount: 1650,
    ),
    WidgetTemplate(
      id: 'fin_022',
      title: 'Financial Goals Dashboard',
      description: 'Track multiple financial goals',
      prompt: 'Create a financial goals dashboard with progress tracking and milestones',
      type: 'dashboard',
      icon: LucideIcons.target,
      tags: ['goals', 'tracking', 'progress'],
      category: 'Finance',
      usageCount: 2350,
    ),
    WidgetTemplate(
      id: 'fin_023',
      title: 'Subscription Manager',
      description: 'Manage recurring subscriptions',
      prompt: 'Build a subscription manager with costs, renewal dates, and usage tracking',
      type: 'manager',
      icon: LucideIcons.repeat,
      tags: ['subscriptions', 'recurring', 'costs'],
      category: 'Finance',
      usageCount: 2000,
    ),
    WidgetTemplate(
      id: 'fin_024',
      title: 'Income vs Expenses Chart',
      description: 'Visualize income and expense trends',
      prompt: 'Design an income vs expenses chart with monthly comparisons and trends',
      type: 'chart',
      icon: LucideIcons.barChart,
      tags: ['income', 'expenses', 'visualization'],
      category: 'Finance',
      usageCount: 2450,
    ),
    WidgetTemplate(
      id: 'fin_025',
      title: 'Financial Risk Assessment',
      description: 'Evaluate investment risk profile',
      prompt: 'Create a risk assessment tool with questionnaire and portfolio recommendations',
      type: 'assessment',
      icon: LucideIcons.alertTriangle,
      tags: ['risk', 'assessment', 'profile'],
      category: 'Finance',
      usageCount: 1550,
    ),
    WidgetTemplate(
      id: 'fin_026',
      title: 'Mortgage Calculator',
      description: 'Calculate mortgage payments',
      prompt: 'Build a mortgage calculator with down payment, interest, and amortization',
      type: 'calculator',
      icon: LucideIcons.home,
      tags: ['mortgage', 'home', 'calculator'],
      category: 'Finance',
      usageCount: 2650,
    ),
    WidgetTemplate(
      id: 'fin_027',
      title: 'Asset Allocation Tool',
      description: 'Optimize portfolio asset allocation',
      prompt: 'Design an asset allocation tool with rebalancing and diversification analysis',
      type: 'tool',
      icon: LucideIcons.pieChart,
      tags: ['assets', 'allocation', 'portfolio'],
      category: 'Finance',
      usageCount: 1700,
    ),
    WidgetTemplate(
      id: 'fin_028',
      title: 'Financial Calendar',
      description: 'Track financial events and deadlines',
      prompt: 'Create a financial calendar with bill due dates, investment dates, and tax deadlines',
      type: 'calendar',
      icon: LucideIcons.calendar,
      tags: ['calendar', 'deadlines', 'events'],
      category: 'Finance',
      usageCount: 1950,
    ),
    WidgetTemplate(
      id: 'fin_029',
      title: 'Money Transfer Tracker',
      description: 'Track money transfers and remittances',
      prompt: 'Build a money transfer tracker with fees, exchange rates, and history',
      type: 'tracker',
      icon: LucideIcons.send,
      tags: ['transfer', 'remittance', 'tracking'],
      category: 'Finance',
      usageCount: 1450,
    ),
    WidgetTemplate(
      id: 'fin_030',
      title: 'Financial Education Hub',
      description: 'Learn financial concepts and strategies',
      prompt: 'Design a financial education hub with tutorials, calculators, and resources',
      type: 'education',
      icon: LucideIcons.graduationCap,
      tags: ['education', 'learning', 'resources'],
      category: 'Finance',
      usageCount: 1850,
    ),
  ];

  // ============= ANALYTICS CATEGORY (30 Templates) =============
  static final List<WidgetTemplate> analyticsTemplates = [
    WidgetTemplate(
      id: 'ana_001',
      title: 'KPI Dashboard',
      description: 'Track key performance indicators',
      prompt: 'Create a KPI dashboard with metrics, trends, and goal tracking',
      type: 'dashboard',
      icon: LucideIcons.activity,
      tags: ['KPI', 'metrics', 'performance'],
      category: 'Analytics',
      usageCount: 3200,
    ),
    WidgetTemplate(
      id: 'ana_002',
      title: 'Data Visualization Suite',
      description: 'Multiple chart types for data analysis',
      prompt: 'Build a data visualization suite with various chart types and filters',
      type: 'visualization',
      icon: LucideIcons.barChart,
      tags: ['visualization', 'charts', 'data'],
      category: 'Analytics',
      usageCount: 2900,
    ),
    WidgetTemplate(
      id: 'ana_003',
      title: 'Real-time Analytics Monitor',
      description: 'Monitor metrics in real-time',
      prompt: 'Create a real-time analytics monitor with live data feeds and alerts',
      type: 'monitor',
      icon: LucideIcons.monitor,
      tags: ['realtime', 'monitoring', 'alerts'],
      category: 'Analytics',
      usageCount: 2450,
    ),
    WidgetTemplate(
      id: 'ana_004',
      title: 'Conversion Funnel Analysis',
      description: 'Analyze conversion rates through funnel',
      prompt: 'Design a conversion funnel with drop-off rates and optimization suggestions',
      type: 'funnel',
      icon: LucideIcons.filter,
      tags: ['conversion', 'funnel', 'optimization'],
      category: 'Analytics',
      usageCount: 2100,
    ),
    WidgetTemplate(
      id: 'ana_005',
      title: 'User Behavior Heatmap',
      description: 'Visualize user interactions',
      prompt: 'Build a heatmap showing user clicks, scrolls, and engagement patterns',
      type: 'heatmap',
      icon: LucideIcons.grid,
      tags: ['heatmap', 'behavior', 'UX'],
      category: 'Analytics',
      usageCount: 1950,
    ),
    // Add 25 more analytics templates...
  ];

  // ============= MARKETING CATEGORY (30 Templates) =============
  static final List<WidgetTemplate> marketingTemplates = [
    WidgetTemplate(
      id: 'mkt_001',
      title: 'Campaign Performance Dashboard',
      description: 'Track marketing campaign metrics',
      prompt: 'Create a campaign dashboard with ROI, reach, and engagement metrics',
      type: 'dashboard',
      icon: LucideIcons.megaphone,
      tags: ['campaign', 'marketing', 'ROI'],
      category: 'Marketing',
      usageCount: 2800,
    ),
    WidgetTemplate(
      id: 'mkt_002',
      title: 'Social Media Analytics',
      description: 'Analyze social media performance',
      prompt: 'Build social media analytics with follower growth, engagement, and reach',
      type: 'analytics',
      icon: LucideIcons.share2,
      tags: ['social', 'media', 'engagement'],
      category: 'Marketing',
      usageCount: 3100,
    ),
    WidgetTemplate(
      id: 'mkt_003',
      title: 'Email Campaign Tracker',
      description: 'Monitor email marketing performance',
      prompt: 'Design an email tracker with open rates, CTR, and conversion metrics',
      type: 'tracker',
      icon: LucideIcons.mail,
      tags: ['email', 'campaign', 'tracking'],
      category: 'Marketing',
      usageCount: 2350,
    ),
    // Add 27 more marketing templates...
  ];

  // ============= SALES CATEGORY (30 Templates) =============
  static final List<WidgetTemplate> salesTemplates = [
    WidgetTemplate(
      id: 'sal_001',
      title: 'Sales Pipeline Dashboard',
      description: 'Track deals through sales pipeline',
      prompt: 'Create a sales pipeline with stages, deal values, and conversion rates',
      type: 'dashboard',
      icon: LucideIcons.trendingUp,
      tags: ['sales', 'pipeline', 'deals'],
      category: 'Sales',
      usageCount: 3400,
    ),
    WidgetTemplate(
      id: 'sal_002',
      title: 'Revenue Forecast Model',
      description: 'Predict future revenue',
      prompt: 'Build a revenue forecast model with trends, seasonality, and projections',
      type: 'forecast',
      icon: LucideIcons.lineChart,
      tags: ['revenue', 'forecast', 'prediction'],
      category: 'Sales',
      usageCount: 2600,
    ),
    // Add 28 more sales templates...
  ];

  // ============= OPERATIONS CATEGORY (30 Templates) =============
  static final List<WidgetTemplate> operationsTemplates = [
    WidgetTemplate(
      id: 'ops_001',
      title: 'Inventory Management System',
      description: 'Track inventory levels and movements',
      prompt: 'Create an inventory system with stock levels, reorder points, and alerts',
      type: 'system',
      icon: LucideIcons.package,
      tags: ['inventory', 'stock', 'management'],
      category: 'Operations',
      usageCount: 2900,
    ),
    WidgetTemplate(
      id: 'ops_002',
      title: 'Supply Chain Dashboard',
      description: 'Monitor supply chain performance',
      prompt: 'Build a supply chain dashboard with logistics, delays, and efficiency metrics',
      type: 'dashboard',
      icon: LucideIcons.truck,
      tags: ['supply', 'chain', 'logistics'],
      category: 'Operations',
      usageCount: 2200,
    ),
    // Add 28 more operations templates...
  ];

  // ============= HR CATEGORY (30 Templates) =============
  static final List<WidgetTemplate> hrTemplates = [
    WidgetTemplate(
      id: 'hr_001',
      title: 'Employee Performance Dashboard',
      description: 'Track employee performance metrics',
      prompt: 'Create a performance dashboard with KPIs, reviews, and goals',
      type: 'dashboard',
      icon: LucideIcons.users,
      tags: ['performance', 'employees', 'HR'],
      category: 'HR',
      usageCount: 2500,
    ),
    WidgetTemplate(
      id: 'hr_002',
      title: 'Recruitment Pipeline Tracker',
      description: 'Manage hiring pipeline',
      prompt: 'Build a recruitment tracker with candidates, stages, and time-to-hire',
      type: 'tracker',
      icon: LucideIcons.userPlus,
      tags: ['recruitment', 'hiring', 'pipeline'],
      category: 'HR',
      usageCount: 2100,
    ),
    // Add 28 more HR templates...
  ];

  // Get all templates
  static List<WidgetTemplate> get allTemplates {
    return [
      ...financeTemplates,
      ...analyticsTemplates,
      ...marketingTemplates,
      ...salesTemplates,
      ...operationsTemplates,
      ...hrTemplates,
    ];
  }

  // Get templates by category
  static List<WidgetTemplate> getByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'finance':
        return financeTemplates;
      case 'analytics':
        return analyticsTemplates;
      case 'marketing':
        return marketingTemplates;
      case 'sales':
        return salesTemplates;
      case 'operations':
        return operationsTemplates;
      case 'hr':
        return hrTemplates;
      default:
        return [];
    }
  }

  // Get categories
  static List<String> getCategories() {
    return ['Finance', 'Analytics', 'Marketing', 'Sales', 'Operations', 'HR'];
  }

  // Get popular templates
  static List<WidgetTemplate> getPopular({int limit = 10}) {
    final sorted = List<WidgetTemplate>.from(allTemplates)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(limit).toList();
  }

  // Search templates
  static List<WidgetTemplate> search(String query) {
    final lowerQuery = query.toLowerCase();
    return allTemplates.where((template) {
      return template.title.toLowerCase().contains(lowerQuery) ||
          template.description.toLowerCase().contains(lowerQuery) ||
          template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}