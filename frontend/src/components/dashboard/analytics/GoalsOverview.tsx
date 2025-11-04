import { PieChart } from '@mui/x-charts/PieChart';

import { toNumeric } from '../../../utils/number';
import type { GoalsSnapshot, GoalProgress } from '../../../types/finance';

interface GoalsOverviewProps {
  snapshot: GoalsSnapshot | null | undefined;
  activeGoals: GoalProgress[] | undefined;
  formatCurrency: (value?: number) => string;
}

const GoalsOverview = ({ snapshot, activeGoals, formatCurrency }: GoalsOverviewProps) => {
  if (!snapshot) {
    return (
      <p className="text-sm text-gray-500">
        Ainda não recebemos o snapshot de metas da API.
      </p>
    );
  }

  const stats = {
    total: toNumeric(snapshot.total),
    achieved: toNumeric(snapshot.achieved),
    exceeded: toNumeric(snapshot.exceeded),
    expired: toNumeric(snapshot.expired),
  };

  const inProgress = Math.max(
    0,
    stats.total - stats.achieved - stats.exceeded - stats.expired
  );

  return (
    <div className="mt-6 grid gap-6 lg:grid-cols-2">
      <div className="flex flex-col items-center justify-center">
        {stats.total === 0 ? (
          <p className="text-sm text-gray-500">
            Cadastre metas para acompanhar este painel consolidado.
          </p>
        ) : (
          <PieChart
            height={300}
            series={[
              {
                data: [
                  { id: 'in-progress', label: 'Ativas', value: inProgress, color: '#f97316' },
                  { id: 'achieved', label: 'Concluídas', value: stats.achieved, color: '#16a34a' },
                  { id: 'exceeded', label: 'Ultrapassadas', value: stats.exceeded, color: '#2563eb' },
                  { id: 'expired', label: 'Expiradas', value: stats.expired, color: '#6b7280' },
                ],
                innerRadius: 50,
                outerRadius: 120,
                paddingAngle: 2,
                cornerRadius: 4,
              },
            ]}
            slotProps={{
              legend: { position: { vertical: 'bottom', horizontal: 'center' } },
            }}
          />
        )}
      </div>
      <div>
        <h4 className="text-sm font-semibold uppercase tracking-wide text-orange-400">
          Metas em andamento
        </h4>
        <div className="mt-4 space-y-4">
          {activeGoals?.length ? (
            activeGoals.map((goal) => {
              const progressValue = Math.round(toNumeric(goal.progressPercentage));
              const progress = Math.min(100, Math.max(0, progressValue));
              const currentAmount = toNumeric(goal.currentAmount);
              const targetAmount = toNumeric(goal.targetAmount);

              return (
                <div
                  key={goal.id}
                  className="rounded-2xl border border-orange-100 bg-orange-50/40 p-4"
                >
                  <div className="flex items-center justify-between text-sm">
                    <p className="font-semibold text-gray-900">{goal.name}</p>
                    <span className="text-xs font-semibold text-gray-500">{progress}%</span>
                  </div>
                  <div className="mt-2 h-2 rounded-full bg-orange-100">
                    <div
                      className="h-full rounded-full bg-orange-500 transition-all"
                      style={{ width: `${progress}%` }}
                    />
                  </div>
                  <p className="mt-2 text-xs text-gray-500">
                    {formatCurrency(currentAmount)} de {formatCurrency(targetAmount)}
                  </p>
                </div>
              );
            })
          ) : (
            <p className="text-sm text-gray-500">
              Sem metas ativas para exibir progressos no momento.
            </p>
          )}
        </div>
      </div>
    </div>
  );
};

export default GoalsOverview;
