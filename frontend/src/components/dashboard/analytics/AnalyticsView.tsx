import { useMemo } from 'react';

import { ChartsLocalizationProvider } from '@mui/x-charts/ChartsLocalizationProvider';
import { ptBRLocaleText } from '@mui/x-charts/locales';

import MonthlyComparisonChart, { type AccountBalanceTrendDataset } from './MonthlyComparisonChart';
import CategoryImpactChart, { type CategoryChartItem } from './CategoryImpactChart';
import DailyFlowChart from './DailyFlowChart';
import AccountDistributionChart from './AccountDistributionChart';
import GoalsOverview from './GoalsOverview';
import GoalsDeadlineTable from './GoalsDeadlineTable';
import MetricTrendChart, { type MonthlyMetricTrend } from './MetricTrendChart';
import ChartErrorBoundary from './ChartErrorBoundary';
import type {
  BankAccount,
  DashboardOverview,
  FinancialGoal,
  Transaction,
  CategoryAggregation,
  MonthlyTrendPoint,
} from '../../../types/finance';
import { toNumeric } from '../../../utils/number';
import type { AccountDistributionItem, DailyFlowPoint } from './types';

interface AnalyticsViewProps {
  overview: DashboardOverview | null;
  accounts: BankAccount[];
  transactions: Transaction[];
  allTransactions: Transaction[];
  financialGoals: FinancialGoal[];
  formatCurrency: (value?: number) => string;
  isLoading: boolean;
}

const AnalyticsView = ({
  overview,
  accounts,
  transactions,
  allTransactions,
  financialGoals,
  formatCurrency,
  isLoading,
}: AnalyticsViewProps) => {
  const accountBalanceTrend = useMemo(
    () => buildAccountBalanceTrend(accounts, transactions, overview?.timeRange ?? null),
    [accounts, transactions, overview?.timeRange]
  );

  const topExpenseCategories = useMemo(
    () =>
      overview?.categoryBreakdown
        ? buildCategoryDataset(overview.categoryBreakdown, 'expense')
        : [],
    [overview?.categoryBreakdown]
  );

  const topIncomeCategories = useMemo(
    () =>
      overview?.categoryBreakdown
        ? buildCategoryDataset(overview.categoryBreakdown, 'income')
        : [],
    [overview?.categoryBreakdown]
  );

  const dailyDataset = useMemo(
    () => buildRecentDailyDataset(allTransactions),
    [allTransactions]
  );

  const expenseTrend = useMemo(
    () => buildMonthlyMetricTrend(overview?.monthlyTrend ?? [], 'expenses'),
    [overview?.monthlyTrend]
  );

  const incomeTrend = useMemo(
    () => buildMonthlyMetricTrend(overview?.monthlyTrend ?? [], 'income'),
    [overview?.monthlyTrend]
  );

  const trendRangeLabel = overview?.timeRange?.label ?? null;

  const accountDistribution = useMemo(
    () => buildAccountDistribution(accounts),
    [accounts]
  );

  const goalsSnapshot = overview?.goals ?? null;
  const goalsWithDeadline = useMemo(
    () =>
      financialGoals
        .filter((goal) => Boolean(goal.endDate))
        .sort((a, b) => {
          if (!a.endDate || !b.endDate) {
            return 0;
          }
          return new Date(a.endDate).getTime() - new Date(b.endDate).getTime();
        }),
    [financialGoals]
  );

  if (isLoading) {
    return (
      <div className="grid gap-6 lg:grid-cols-2">
        {Array.from({ length: 4 }).map((_, index) => (
          <div
            key={index}
            className="h-64 animate-pulse rounded-3xl border border-orange-100 bg-white shadow-lg shadow-orange-100/40"
          />
        ))}
      </div>
    );
  }

  if (!overview) {
    return (
      <div className="rounded-3xl border border-orange-100 bg-white p-6 text-sm text-gray-500">
        Não encontramos dados consolidados suficientes para montar os gráficos no momento.
      </div>
    );
  }

  return (
    <ChartsLocalizationProvider localeText={ptBRLocaleText}>
      <div className="space-y-6">
        <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
          <h3 className="text-lg font-semibold text-gray-900">Variação do saldo por conta</h3>
          <ChartErrorBoundary>
            <MonthlyComparisonChart data={accountBalanceTrend} formatCurrency={formatCurrency} />
          </ChartErrorBoundary>
        </div>

        <div className="grid gap-6 xl:grid-cols-2">
          <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
            <h3 className="text-lg font-semibold text-gray-900">Categorias com maiores despesas</h3>
            <ChartErrorBoundary>
              <CategoryImpactChart data={topExpenseCategories} formatCurrency={formatCurrency} />
            </ChartErrorBoundary>
          </div>
          <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
            <h3 className="text-lg font-semibold text-gray-900">Categorias com maiores receitas</h3>
            <ChartErrorBoundary>
              <CategoryImpactChart data={topIncomeCategories} formatCurrency={formatCurrency} />
            </ChartErrorBoundary>
          </div>
        </div>

        <div className="grid gap-6 xl:grid-cols-2">
          <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
            <h3 className="text-lg font-semibold text-gray-900">
              Evolução das despesas{trendRangeLabel ? ` (${trendRangeLabel})` : ''}
            </h3>
            <ChartErrorBoundary>
              <MetricTrendChart
                data={expenseTrend}
                formatCurrency={formatCurrency}
                color="#dc2626"
                invertTrend
              />
            </ChartErrorBoundary>
          </div>
          <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
            <h3 className="text-lg font-semibold text-gray-900">
              Evolução das receitas{trendRangeLabel ? ` (${trendRangeLabel})` : ''}
            </h3>
            <ChartErrorBoundary>
              <MetricTrendChart data={incomeTrend} formatCurrency={formatCurrency} color="#16a34a" />
            </ChartErrorBoundary>
          </div>
        </div>

        <div className="grid gap-6 xl:grid-cols-2">
          <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
            <h3 className="text-lg font-semibold text-gray-900">Fluxo diário recente</h3>
            <ChartErrorBoundary>
              <DailyFlowChart data={dailyDataset} formatCurrency={formatCurrency} />
            </ChartErrorBoundary>
          </div>
          <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
            <h3 className="text-lg font-semibold text-gray-900">Saldo por tipo de conta</h3>
            <ChartErrorBoundary>
              <AccountDistributionChart data={accountDistribution} formatCurrency={formatCurrency} />
            </ChartErrorBoundary>
          </div>
        </div>

        <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
          <h3 className="text-lg font-semibold text-gray-900">Metas financeiras</h3>
          <ChartErrorBoundary>
            <GoalsOverview
              snapshot={goalsSnapshot}
              activeGoals={goalsSnapshot?.activeGoals}
              formatCurrency={formatCurrency}
            />
          </ChartErrorBoundary>
        </div>

        <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
          <h3 className="text-lg font-semibold text-gray-900">Metas com prazo definido</h3>
          <ChartErrorBoundary>
            <GoalsDeadlineTable goals={goalsWithDeadline} />
          </ChartErrorBoundary>
        </div>
      </div>
    </ChartsLocalizationProvider>
  );
};

const buildAccountBalanceTrend = (
  accounts: BankAccount[],
  transactions: Transaction[],
  timeRange: DashboardOverview['timeRange'] | null
): AccountBalanceTrendDataset => {
  if (accounts.length === 0) {
    return { months: [], series: [] };
  }

  const transactionsByAccount = new Map<string, Transaction[]>();

  accounts.forEach((account) => {
    transactionsByAccount.set(account.id, []);
  });

  transactions.forEach((transaction) => {
    const accountTransactions = transactionsByAccount.get(transaction.bankAccountId);
    if (!accountTransactions) {
      return;
    }
    accountTransactions.push(transaction);
  });

  let earliestMonthValue: number | null = null;
  let latestMonthValue: number | null = null;

  const applyFixedRange = () => {
    if (!timeRange) {
      return false;
    }
    const startDate = new Date(`${timeRange.startDate}T00:00:00`);
    const endDate = new Date(`${timeRange.endDate}T00:00:00`);
    if (Number.isNaN(startDate.getTime()) || Number.isNaN(endDate.getTime())) {
      return false;
    }
    earliestMonthValue = new Date(startDate.getFullYear(), startDate.getMonth(), 1).getTime();
    latestMonthValue = new Date(endDate.getFullYear(), endDate.getMonth(), 1).getTime();
    return true;
  };

  const hasFixedRange = applyFixedRange();

  const updateMonthBounds = (candidate: Date) => {
    if (Number.isNaN(candidate.getTime()) || hasFixedRange) {
      return;
    }
    const monthStart = new Date(candidate.getFullYear(), candidate.getMonth(), 1).getTime();
    if (earliestMonthValue === null || monthStart < earliestMonthValue) {
      earliestMonthValue = monthStart;
    }
    if (latestMonthValue === null || monthStart > latestMonthValue) {
      latestMonthValue = monthStart;
    }
  };

  if (!hasFixedRange) {
    accounts.forEach((account) => {
      updateMonthBounds(new Date(account.createdAt));
    });

    transactions.forEach((transaction) => {
      updateMonthBounds(new Date(transaction.transactionDate));
    });

    updateMonthBounds(new Date());
  }

  if (earliestMonthValue === null || latestMonthValue === null) {
    return { months: [], series: [] };
  }

  const startMonth = new Date(earliestMonthValue);
  const endMonth = new Date(latestMonthValue);

  const months: { year: number; month: number }[] = [];
  const cursor = new Date(startMonth);

  while (cursor.getTime() <= endMonth.getTime()) {
    months.push({ year: cursor.getFullYear(), month: cursor.getMonth() + 1 });
    cursor.setMonth(cursor.getMonth() + 1);
  }

  const toMonthKey = (year: number, month: number) =>
    `${year}-${String(month).padStart(2, '0')}`;

  const currencyToCents = (value: number) => Math.round(toNumeric(value) * 100);
  const centsToCurrency = (value: number) => value / 100;

  const series = accounts.map((account) => {
    const accountTransactions = transactionsByAccount.get(account.id) ?? [];
    const monthlyDeltas = new Map<string, number>();
    let totalDeltaCents = 0;

    accountTransactions.forEach((transaction) => {
      const transactionDate = new Date(transaction.transactionDate);
      if (Number.isNaN(transactionDate.getTime())) {
        return;
      }
      const monthKey = toMonthKey(transactionDate.getFullYear(), transactionDate.getMonth() + 1);
      const rawAmount = currencyToCents(transaction.amount);
      let deltaCents = 0;

      if (transaction.type === 'INCOME' || transaction.type === 'TRANSFER_IN') {
        deltaCents = rawAmount;
      } else if (transaction.type === 'EXPENSE' || transaction.type === 'TRANSFER_OUT') {
        deltaCents = -rawAmount;
      }

      if (deltaCents === 0) {
        return;
      }

      monthlyDeltas.set(monthKey, (monthlyDeltas.get(monthKey) ?? 0) + deltaCents);
      totalDeltaCents += deltaCents;
    });

    const currentBalanceCents = currencyToCents(account.currentBalance);
    const initialBalanceCents = currentBalanceCents - totalDeltaCents;
    let runningBalanceCents = initialBalanceCents;

    const balances = months.map((monthPoint) => {
      const monthKey = toMonthKey(monthPoint.year, monthPoint.month);
      runningBalanceCents += monthlyDeltas.get(monthKey) ?? 0;
      return centsToCurrency(runningBalanceCents);
    });

    return {
      accountId: account.id,
      label: getAccountLabel(account),
      data: balances,
    };
  });

  const MAX_MONTHS = 24;
  if (months.length > MAX_MONTHS) {
    const startIndex = months.length - MAX_MONTHS;
    const trimmedMonths = months.slice(startIndex);
    const trimmedSeries = series.map((serie) => ({
      ...serie,
      data: serie.data.slice(startIndex),
    }));

    return {
      months: trimmedMonths,
      series: trimmedSeries,
    };
  }

  return { months, series };
};

type CategoryMetric = 'income' | 'expense';

const buildCategoryDataset = (
  categories: CategoryAggregation[],
  metric: CategoryMetric
): CategoryChartItem[] =>
  categories
    .map((category) => ({
      id: category.categoryId,
      label: category.name,
      value:
        metric === 'income'
          ? Math.abs(toNumeric(category.totalIncome))
          : Math.abs(toNumeric(category.totalExpenses)),
      color: category.color,
    }))
    .filter((category) => category.value > 0)
    .sort((a, b) => b.value - a.value)
    .slice(0, 8);

const getAccountLabel = (account: BankAccount) => {
  if (account.nickname) {
    return account.nickname;
  }

  const accountNumber = account.accountNumber ?? '';
  const maskedDigits = accountNumber.slice(-4);
  const suffix = maskedDigits ? ` ••••${maskedDigits}` : '';
  return `${account.institutionName}${suffix}`;
};

const buildRecentDailyDataset = (
  transactions: Transaction[],
  referenceDate: Date = new Date()
): DailyFlowPoint[] => {
  if (transactions.length === 0) {
    return [];
  }

  const toDateKey = (date: Date) =>
    `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(
      date.getDate()
    ).padStart(2, '0')}`;

  const today = new Date(referenceDate);
  today.setHours(0, 0, 0, 0);
  const start = new Date(today);
  start.setDate(start.getDate() - 6);

  const dailyTotals = new Map<string, { income: number; expense: number }>();

  transactions.forEach((transaction) => {
    const transactionDate = new Date(`${transaction.transactionDate}T00:00:00`);
    if (Number.isNaN(transactionDate.getTime())) {
      return;
    }

    if (transactionDate.getTime() < start.getTime() || transactionDate.getTime() > today.getTime()) {
      return;
    }

    const dateKey = toDateKey(transactionDate);
    const totals = dailyTotals.get(dateKey) ?? { income: 0, expense: 0 };
    const amount = toNumeric(transaction.amount);

    if (transaction.type === 'INCOME' || transaction.type === 'TRANSFER_IN') {
      totals.income += amount;
    } else if (transaction.type === 'EXPENSE' || transaction.type === 'TRANSFER_OUT') {
      totals.expense += amount;
    }

    dailyTotals.set(dateKey, totals);
  });

  const result: DailyFlowPoint[] = [];
  const cursor = new Date(start);

  while (cursor.getTime() <= today.getTime()) {
    const dateKey = toDateKey(cursor);
    const totals = dailyTotals.get(dateKey) ?? { income: 0, expense: 0 };
    result.push({
      date: dateKey,
      income: Number(totals.income.toFixed(2)),
      expense: Number(totals.expense.toFixed(2)),
    });
    cursor.setDate(cursor.getDate() + 1);
  }

  return result;
};

const buildMonthlyMetricTrend = (
  monthlyTrend: MonthlyTrendPoint[],
  metric: 'income' | 'expenses'
): MonthlyMetricTrend | null => {
  if (monthlyTrend.length === 0) {
    return null;
  }

  const sortedTrend = [...monthlyTrend].sort((a, b) => {
    const aValue = new Date(a.year, a.month - 1).getTime();
    const bValue = new Date(b.year, b.month - 1).getTime();
    return aValue - bValue;
  });

  const labels = sortedTrend.map((point) =>
    new Date(point.year, point.month - 1).toLocaleDateString('pt-BR', {
      month: 'short',
      year: 'numeric',
    })
  );

  const values = sortedTrend.map((point) => (metric === 'income' ? point.income : point.expenses));

  const firstValueRaw = values.at(0);
  const lastValueRaw = values.at(-1);
  const firstValue = firstValueRaw !== undefined ? Number(firstValueRaw.toFixed(2)) : null;
  const lastValue = lastValueRaw !== undefined ? Number(lastValueRaw.toFixed(2)) : null;
  const totalChange =
    firstValue !== null && lastValue !== null ? Number((lastValue - firstValue).toFixed(2)) : 0;
  const changePercentage =
    firstValue !== null && lastValue !== null && firstValue !== 0
      ? Number((((lastValue - firstValue) / firstValue) * 100).toFixed(2))
      : null;

  return {
    labels,
    values: values.map((value) => Number(value.toFixed(2))),
    firstValue,
    lastValue,
    totalChange,
    changePercentage,
  };
};

const buildAccountDistribution = (accounts: BankAccount[]): AccountDistributionItem[] => {
  if (accounts.length === 0) {
    return [];
  }

  const labels: Record<string, string> = {
    CHECKING: 'Contas correntes',
    SAVINGS: 'Poupança',
    INVESTMENT: 'Investimentos',
    CREDIT_CARD: 'Cartões de crédito',
  };

  const totals = accounts.reduce<Record<string, number>>((acc, account) => {
    const balance = toNumeric(account.currentBalance);
    acc[account.accountType] = (acc[account.accountType] ?? 0) + balance;
    return acc;
  }, {});

  return Object.entries(totals)
    .map(([type, balance]) => ({
      type,
      label: labels[type] ?? type,
      balance: Number(balance.toFixed(2)),
    }))
    .sort((a, b) => b.balance - a.balance);
};

export default AnalyticsView;
