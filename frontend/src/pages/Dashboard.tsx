import { useCallback, useEffect, useMemo, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useDashboardRange } from '../contexts/DashboardRangeContext';
import financeService from '../services/finance';
import SummaryView, {
  SummaryMetricsGrid,
} from '../components/dashboard/summary/SummaryView';
import AnalyticsView from '../components/dashboard/analytics/AnalyticsView';
import type {
  BankAccount,
  DashboardOverview,
  FinancialGoal,
  MonthlyTrendPoint,
  Transaction,
} from '../types/finance';

type DashboardState = {
  overview: DashboardOverview | null;
  accounts: BankAccount[];
  transactions: Transaction[];
  goals: FinancialGoal[];
  isLoading: boolean;
};

const Dashboard = () => {
  const { selectedRange } = useDashboardRange();
  const { user } = useAuth();
  const firstName = useMemo(() => user?.name?.split(' ')[0] ?? 'Usuário', [user?.name]);
  const [{ overview, accounts, transactions, goals, isLoading }, setDashboardState] =
    useState<DashboardState>({
      overview: null,
      accounts: [],
      transactions: [],
      goals: [],
      isLoading: true,
    });
  const [error, setError] = useState<string | null>(null);
  const [accountPage, setAccountPage] = useState(0);
  const [categoryPage, setCategoryPage] = useState(0);
  const [viewMode, setViewMode] = useState<'summary' | 'analytics'>('summary');

  const ACCOUNTS_PER_PAGE = 4;
  const CATEGORIES_PER_PAGE = 6;

  const loadDashboard = useCallback(async () => {
    setDashboardState((prev) => ({ ...prev, isLoading: true }));
    setError(null);
    try {
      const [overviewResponse, accountsResponse, transactionsResponse, goalsResponse] =
        await Promise.all([
          financeService.getDashboardOverview({ range: selectedRange }),
          financeService.listBankAccounts(),
          financeService.listTransactions(),
          financeService.listFinancialGoals(),
        ]);

      setDashboardState({
        overview: overviewResponse,
        accounts: accountsResponse,
        transactions: transactionsResponse,
        goals: goalsResponse,
        isLoading: false,
      });
      setAccountPage(0);
      setCategoryPage(0);
    } catch (loadError) {
      console.error('Erro ao carregar dados do dashboard:', loadError);
      setError('Não foi possível carregar os dados do dashboard.');
      setDashboardState((prev) => ({ ...prev, isLoading: false }));
    }
  }, [selectedRange]);

  useEffect(() => {
    void loadDashboard();
  }, [loadDashboard]);

  const currencyFormatter = useMemo(
    () =>
      new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 2,
      }),
    []
  );

  const formatCurrency = (value?: number) =>
    currencyFormatter.format(value !== undefined ? value : 0);

  const periodLabel = useMemo(() => {
    if (overview?.timeRange) {
      if (overview.timeRange.label) {
        return overview.timeRange.label;
      }
      const start = new Date(`${overview.timeRange.startDate}T00:00:00`);
      const end = new Date(`${overview.timeRange.endDate}T23:59:59`);
      const formatter = new Intl.DateTimeFormat('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
      });
      if (!Number.isNaN(start.getTime()) && !Number.isNaN(end.getTime())) {
        return `${formatter.format(start)} a ${formatter.format(end)}`;
      }
    }

    if (overview?.period) {
      return new Date(overview.period.year, overview.period.month - 1).toLocaleDateString(
        'pt-BR',
        {
          month: 'long',
          year: 'numeric',
        }
      );
    }

    return 'Últimos dados consolidados';
  }, [overview?.period, overview?.timeRange]);

  const trendData: MonthlyTrendPoint[] = overview?.monthlyTrend ?? [];
  const categoryBreakdown = overview?.categoryBreakdown ?? [];
  const filteredTransactions = useMemo(() => {
    if (!overview?.timeRange) {
      return transactions;
    }
    const rangeStart = new Date(`${overview.timeRange.startDate}T00:00:00`);
    const rangeEnd = new Date(`${overview.timeRange.endDate}T23:59:59`);
    if (Number.isNaN(rangeStart.getTime()) || Number.isNaN(rangeEnd.getTime())) {
      return transactions;
    }
    const startTime = rangeStart.getTime();
    const endTime = rangeEnd.getTime();
    return transactions.filter((transaction) => {
      const ts = new Date(`${transaction.transactionDate}T00:00:00`).getTime();
      return ts >= startTime && ts <= endTime;
    });
  }, [transactions, overview?.timeRange]);

  const totalAccountPages =
    accounts.length > 0 ? Math.ceil(accounts.length / ACCOUNTS_PER_PAGE) : 0;
  const totalCategoryPages =
    categoryBreakdown.length > 0 ? Math.ceil(categoryBreakdown.length / CATEGORIES_PER_PAGE) : 0;

  useEffect(() => {
    if (totalAccountPages === 0) {
      setAccountPage(0);
      return;
    }
    setAccountPage((prev) => Math.min(prev, totalAccountPages - 1));
  }, [totalAccountPages]);

  useEffect(() => {
    if (totalCategoryPages === 0) {
      setCategoryPage(0);
      return;
    }
    setCategoryPage((prev) => Math.min(prev, totalCategoryPages - 1));
  }, [totalCategoryPages]);

  const accountStartIndex = accountPage * ACCOUNTS_PER_PAGE;
  const displayedAccounts = accounts.slice(
    accountStartIndex,
    accountStartIndex + ACCOUNTS_PER_PAGE
  );

  const categoryStartIndex = categoryPage * CATEGORIES_PER_PAGE;
  const displayedCategories = categoryBreakdown.slice(
    categoryStartIndex,
    categoryStartIndex + CATEGORIES_PER_PAGE
  );

  const toggleButtonClass = (mode: 'summary' | 'analytics') =>
    `rounded-full px-4 py-1 text-sm font-semibold transition ${
      viewMode === mode
        ? 'bg-orange-500 text-white shadow-sm shadow-orange-400/40'
        : 'bg-white text-orange-500 hover:bg-orange-50'
    }`;

  return (
    <section className="space-y-6">
      <div className="rounded-3xl bg-white p-8 shadow-lg shadow-orange-100/50">
        <div className="flex flex-col gap-4 border-b border-orange-100 pb-4 md:flex-row md:items-start md:justify-between">
          <div>
            <p className="text-sm font-medium uppercase tracking-wider text-orange-400">
              Visão geral
            </p>
            <h2 className="text-2xl font-semibold text-gray-900">Saúde financeira</h2>
            <p className="text-sm text-gray-500">
              Olá, {firstName}! Aqui está o resumo mais recente das suas finanças.
            </p>
          </div>
          <div className="flex flex-col items-start gap-3 md:items-end">
            <p className="text-sm text-gray-500">{periodLabel}</p>
            <div className="flex rounded-full border border-orange-100 bg-orange-50 p-1">
              <button
                type="button"
                onClick={() => setViewMode('summary')}
                className={toggleButtonClass('summary')}
              >
                Quadros
              </button>
              <button
                type="button"
                onClick={() => setViewMode('analytics')}
                className={toggleButtonClass('analytics')}
              >
                Gráficos
              </button>
            </div>
          </div>
        </div>

        {error && (
          <div className="mt-6 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            {error}
          </div>
        )}

        {isLoading ? (
          <div className="mt-6 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {Array.from({ length: 4 }).map((_, index) => (
              <div
                key={index}
                className="h-32 animate-pulse rounded-3xl border border-orange-100 bg-orange-50/40"
              />
            ))}
          </div>
        ) : viewMode === 'summary' ? (
          <SummaryMetricsGrid
            overview={overview}
            accounts={accounts}
            formatCurrency={formatCurrency}
          />
        ) : (
          <p className="mt-6 text-sm text-gray-500">
            Explore os gráficos abaixo para analisar tendências e distribuição das suas finanças.
          </p>
        )}
      </div>

      {viewMode === 'summary' ? (
        <SummaryView
          accounts={accounts}
          trendData={trendData}
          formatCurrency={formatCurrency}
          displayedAccounts={displayedAccounts}
          accountPage={accountPage}
          totalAccountPages={totalAccountPages}
          onAccountPrev={() => setAccountPage((prev) => Math.max(prev - 1, 0))}
          onAccountNext={() =>
            setAccountPage((prev) => Math.min(prev + 1, totalAccountPages - 1))
          }
          onAccountSelect={(page) => setAccountPage(page)}
          displayedCategories={displayedCategories}
          categoryPage={categoryPage}
          totalCategoryPages={totalCategoryPages}
          onCategoryPrev={() => setCategoryPage((prev) => Math.max(prev - 1, 0))}
          onCategoryNext={() =>
            setCategoryPage((prev) => Math.min(prev + 1, totalCategoryPages - 1))
          }
          onCategorySelect={(page) => setCategoryPage(page)}
        />
      ) : (
        <AnalyticsView
          overview={overview}
          accounts={accounts}
          transactions={filteredTransactions}
          allTransactions={transactions}
          financialGoals={goals}
          formatCurrency={formatCurrency}
          isLoading={isLoading}
        />
      )}
    </section>
  );
};

export default Dashboard;
