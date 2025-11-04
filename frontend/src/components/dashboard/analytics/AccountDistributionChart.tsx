import { BarChart } from '@mui/x-charts/BarChart';

import type { AccountDistributionItem } from './types';
import { toNumeric } from '../../../utils/number';

interface AccountDistributionChartProps {
  data: AccountDistributionItem[];
  formatCurrency: (value?: number) => string;
}

const AccountDistributionChart = ({ data, formatCurrency }: AccountDistributionChartProps) => {
  const normalizedData = data
    .map((item) => ({
      ...item,
      balance: toNumeric(item.balance),
    }))
    .filter((item) => Number.isFinite(item.balance));

  if (normalizedData.length === 0) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Cadastre contas para identificar a distribuição de saldos entre instituições.
      </p>
    );
  }

  const hasNonZeroBalance = normalizedData.some((item) => item.balance !== 0);
  if (!hasNonZeroBalance) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Todas as contas cadastradas estão com saldo zerado no momento.
      </p>
    );
  }

  const balances = normalizedData.map((item) => item.balance);
  const axisMin = Math.min(0, ...balances);
  const axisMax = Math.max(0, ...balances);

  const xAxisLimits =
    Math.abs(axisMax - axisMin) < Number.EPSILON
      ? { min: axisMin, max: axisMax === 0 ? 1 : axisMax }
      : { min: axisMin, max: axisMax };

  return (
    <div className="mt-4">
      <BarChart
        height={320}
        layout="horizontal"
        grid={{ horizontal: true }}
        yAxis={[
          {
            scaleType: 'band',
            data: normalizedData.map((item) => item.label),
          },
        ]}
        xAxis={[
          {
            ...xAxisLimits,
            valueFormatter: (value: number) => formatCurrency(value),
          },
        ]}
        series={[
          {
            id: 'account-balance',
            label: 'Saldo atual',
            data: normalizedData.map((item) => item.balance),
            color: '#f97316',
            valueFormatter: (value: number | null) => formatCurrency(value ?? 0),
          },
        ]}
        slotProps={{
          legend: { position: { vertical: 'top', horizontal: 'center' } },
        }}
      />
    </div>
  );
};

export default AccountDistributionChart;
