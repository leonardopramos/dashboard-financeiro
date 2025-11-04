import { toNumeric } from '../../../utils/number';
import type { FinancialGoal } from '../../../types/finance';

interface GoalsDeadlineTableProps {
  goals: FinancialGoal[];
}

const statusLabel: Record<string, string> = {
  IN_PROGRESS: 'Em andamento',
  ACHIEVED: 'Concluída',
  EXCEEDED: 'Ultrapassada',
  EXPIRED: 'Expirada',
};

const GoalsDeadlineTable = ({ goals }: GoalsDeadlineTableProps) => {
  if (goals.length === 0) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Metas com data de término aparecerão aqui para facilitar o acompanhamento.
      </p>
    );
  }

  return (
    <div className="mt-4 overflow-x-auto">
      <table className="min-w-full divide-y divide-orange-100 text-sm">
        <thead>
          <tr className="text-left text-xs font-semibold uppercase tracking-wide text-gray-500">
            <th className="py-3 pr-4">Meta</th>
            <th className="py-3 pr-4">Status</th>
            <th className="py-3 pr-4">Prazo</th>
            <th className="py-3 pr-4 text-right">Progresso</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-orange-50">
          {goals.map((goal) => {
            const endDate = goal.endDate ? new Date(goal.endDate) : null;
            const now = new Date();
            const daysToEnd =
              endDate && !Number.isNaN(endDate.getTime())
                ? Math.ceil((endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
                : null;
            const currentAmount = toNumeric(goal.currentAmount);
            const targetAmount = toNumeric(goal.targetAmount);
            const progressBase = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
            const progress = Math.min(100, Math.max(0, Math.round(progressBase)));

            const isAboutToExpire =
              goal.status === 'IN_PROGRESS' && daysToEnd !== null && daysToEnd > 0 && daysToEnd <= 30;
            const isExpired = goal.status === 'EXPIRED' || (daysToEnd !== null && daysToEnd <= 0);

            return (
              <tr
                key={goal.id}
                className={`transition ${
                  isExpired
                    ? 'bg-red-50'
                    : isAboutToExpire
                    ? 'bg-orange-50/70'
                    : 'hover:bg-orange-50/40'
                }`}
              >
                <td className="py-3 pr-4 font-semibold text-gray-900">{goal.name}</td>
                <td className="py-3 pr-4 text-xs font-semibold uppercase tracking-wide text-gray-500">
                  {statusLabel[goal.status] ?? goal.status}
                </td>
                <td className="py-3 pr-4 text-sm text-gray-700">
                  {endDate
                    ? `${endDate.toLocaleDateString('pt-BR')} ${
                        daysToEnd !== null
                          ? daysToEnd > 0
                            ? `• ${daysToEnd} dia(s) restante(s)`
                            : '• Prazo encerrado'
                          : ''
                      }`
                    : 'Sem prazo'}
                </td>
                <td className="py-3 pr-4">
                  <div className="flex items-center justify-end gap-3">
                    <span className="text-xs font-semibold text-gray-500">{progress}%</span>
                    <div className="h-2 w-32 rounded-full bg-orange-100">
                      <div
                        className={`h-full rounded-full ${isExpired ? 'bg-red-500' : 'bg-orange-500'}`}
                        style={{ width: `${progress}%` }}
                      />
                    </div>
                  </div>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
};

export default GoalsDeadlineTable;
