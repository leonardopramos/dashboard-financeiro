import DashboardMetric from '../../dashboard/DashboardMetric';
import PaginationControls from '../../dashboard/PaginationControls';
import { toNumeric } from '../../../utils/number';
import type {
  BankAccount,
  CategoryAggregation,
  DashboardOverview,
  MonthlyTrendPoint,
} from '../../../types/finance';

interface SummaryMetricsGridProps {
  overview: DashboardOverview | null;
  accounts: BankAccount[];
  formatCurrency: (value?: number) => string;
}

export const SummaryMetricsGrid = ({
  overview,
  accounts,
  formatCurrency,
}: SummaryMetricsGridProps) => (
  <div className="mt-6 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
    <DashboardMetric
      title="Receitas"
      subtitle="Total do período"
      value={formatCurrency(toNumeric(overview?.totalIncome))}
      trend={toNumeric(overview?.totalIncome) > 0 ? '+ mais entradas' : 'Sem dados'}
      variant="positive"
    />
    <DashboardMetric
      title="Despesas"
      subtitle="Total do período"
      value={formatCurrency(toNumeric(overview?.totalExpenses))}
      trend={toNumeric(overview?.totalExpenses) > 0 ? 'Acompanhando gastos' : 'Sem dados'}
      variant="negative"
    />
    <DashboardMetric
      title="Saldo líquido"
      subtitle="Receitas - Despesas"
      value={formatCurrency(toNumeric(overview?.netBalance))}
      trend={toNumeric(overview?.netBalance) >= 0 ? 'Você está no azul' : 'Atenção ao fluxo'}
      variant={toNumeric(overview?.netBalance) >= 0 ? 'positive' : 'negative'}
    />
    <DashboardMetric
      title="Saldo consolidado"
      subtitle="Soma de contas"
      value={formatCurrency(toNumeric(overview?.totalBalance))}
      trend={`${accounts.length} conta(s) cadastrada(s)`}
      variant="neutral"
    />
  </div>
);

interface SummaryViewProps {
  accounts: BankAccount[];
  trendData: MonthlyTrendPoint[];
  formatCurrency: (value?: number) => string;
  displayedAccounts: BankAccount[];
  accountPage: number;
  totalAccountPages: number;
  onAccountPrev: () => void;
  onAccountNext: () => void;
  onAccountSelect: (page: number) => void;
  displayedCategories: CategoryAggregation[];
  categoryPage: number;
  totalCategoryPages: number;
  onCategoryPrev: () => void;
  onCategoryNext: () => void;
  onCategorySelect: (page: number) => void;
}

const SummaryView = ({
  accounts,
  trendData,
  formatCurrency,
  displayedAccounts,
  accountPage,
  totalAccountPages,
  onAccountPrev,
  onAccountNext,
  onAccountSelect,
  displayedCategories,
  categoryPage,
  totalCategoryPages,
  onCategoryPrev,
  onCategoryNext,
  onCategorySelect,
}: SummaryViewProps) => {
  return (
    <>
      <div className="grid gap-6 lg:grid-cols-3">
        <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50 lg:col-span-2">
          <h3 className="text-lg font-semibold text-gray-900">Evolução mensal</h3>
          {trendData.length === 0 ? (
            <p className="mt-4 text-sm text-gray-500">
              Ainda não há dados suficientes para exibir a evolução mensal.
            </p>
          ) : (
            <div className="mt-4 space-y-3">
              {trendData.map((point) => (
                <div
                  key={`${point.year}-${point.month}`}
                  className="flex items-center justify-between rounded-2xl border border-orange-100 bg-orange-50/40 px-4 py-3 text-sm"
                >
                  <div>
                    <p className="font-semibold text-gray-900">
                      {new Date(point.year, point.month - 1).toLocaleDateString('pt-BR', {
                        month: 'long',
                        year: 'numeric',
                      })}
                    </p>
                    <p className="text-xs text-gray-500">
                      Receitas {formatCurrency(toNumeric(point.income))} • Despesas{' '}
                      {formatCurrency(toNumeric(point.expenses))}
                    </p>
                  </div>
                  <span
                    className={`rounded-full px-3 py-1 text-xs font-semibold ${
                      toNumeric(point.net) >= 0
                        ? 'bg-green-100 text-green-700'
                        : 'bg-red-100 text-red-600'
                    }`}
                  >
                    {formatCurrency(toNumeric(point.net))}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50 flex h-full flex-col">
          <h3 className="text-lg font-semibold text-gray-900">Contas cadastradas</h3>
          {accounts.length === 0 ? (
            <p className="mt-4 text-sm text-gray-500">
              Nenhuma conta cadastrada até o momento. Adicione uma conta para acompanhar os saldos.
            </p>
          ) : (
            <div className="mt-4 flex h-full flex-col">
              <ul className="space-y-3 text-sm">
                {displayedAccounts.map((account) => (
                  <li
                    key={account.id}
                    className="rounded-2xl border border-orange-100 bg-orange-50/40 px-4 py-3"
                  >
                    <p className="font-semibold text-gray-900">
                      {account.nickname || account.institutionName}
                    </p>
                    <p className="text-xs text-gray-500">
                      Agência {account.branchNumber} • Conta {account.accountNumber}
                    </p>
                    <p className="text-sm font-semibold text-orange-600">
                      {formatCurrency(toNumeric(account.currentBalance))}
                    </p>
                  </li>
                ))}
              </ul>
              <div className="mt-auto">
                <PaginationControls
                  currentPage={accountPage}
                  totalPages={totalAccountPages}
                  onPrev={onAccountPrev}
                  onNext={onAccountNext}
                  onSelect={onAccountSelect}
                />
              </div>
            </div>
          )}
        </div>
      </div>

      <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
        <h3 className="text-lg font-semibold text-gray-900">Categorias em destaque</h3>
        {displayedCategories.length ? (
          <>
            <div className="mt-4 grid gap-4 md:grid-cols-3">
              {displayedCategories.map((category) => (
                <div
                  key={category.categoryId}
                  className="rounded-2xl border border-orange-100 bg-orange-50/40 px-4 py-3 text-sm"
                >
                  <p className="font-semibold text-gray-900">{category.name}</p>
                  <p className="text-xs uppercase tracking-wide text-gray-500">{category.type}</p>
                  <div className="mt-2 flex justify-between text-xs font-medium">
                    <span className="text-green-600">
                      + {formatCurrency(toNumeric(category.totalIncome))}
                    </span>
                    <span className="text-red-500">
                      - {formatCurrency(toNumeric(category.totalExpenses))}
                    </span>
                  </div>
                </div>
              ))}
            </div>
            <PaginationControls
              currentPage={categoryPage}
              totalPages={totalCategoryPages}
              onPrev={onCategoryPrev}
              onNext={onCategoryNext}
              onSelect={onCategorySelect}
            />
          </>
        ) : (
          <p className="mt-4 text-sm text-gray-500">
            Ainda não há movimentações categorizadas para este período.
          </p>
        )}
      </div>
    </>
  );
};

export default SummaryView;
