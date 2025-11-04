import { BarChart } from '@mui/x-charts/BarChart';

import type { DailyFlowPoint } from './types';

interface DailyFlowChartProps {
  data: DailyFlowPoint[];
  formatCurrency: (value?: number) => string;
}

const DailyFlowChart = ({ data, formatCurrency }: DailyFlowChartProps) => {
  if (data.length === 0) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Registre movimentações para visualizar a distribuição diária de entradas e saídas.
      </p>
    );
  }

  return (
    <div className="mt-4">
      <BarChart
        height={320}
        grid={{ horizontal: true }}
        xAxis={[
          {
            scaleType: 'band',
            data: data.map((day) =>
              new Date(day.date).toLocaleDateString('pt-BR', {
                day: '2-digit',
                month: '2-digit',
              })
            ),
          },
        ]}
        series={[
          {
            id: 'daily-income',
            label: 'Entradas',
            data: data.map((day) => day.income),
            color: '#16a34a',
            valueFormatter: (value: number | null) => formatCurrency(value ?? 0),
          },
          {
            id: 'daily-expense',
            label: 'Saídas',
            data: data.map((day) => day.expense),
            color: '#dc2626',
            valueFormatter: (value: number | null) => formatCurrency(value ?? 0),
          },
        ]}
        yAxis={[
          {
            valueFormatter: (value: number) => formatCurrency(value),
            width: 96,
            tickLabelStyle: {
              fill: '#374151',
              fontSize: 12,
            },
          },
        ]}
        slotProps={{
          legend: { position: { vertical: 'top', horizontal: 'center' } },
        }}
      />
    </div>
  );
};

export default DailyFlowChart;
