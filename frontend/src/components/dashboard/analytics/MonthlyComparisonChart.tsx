import { LineChart } from '@mui/x-charts/LineChart';

export interface AccountBalanceSeries {
  accountId: string;
  label: string;
  data: number[];
}

export interface AccountBalanceTrendDataset {
  months: { year: number; month: number }[];
  series: AccountBalanceSeries[];
}

interface MonthlyComparisonChartProps {
  data: AccountBalanceTrendDataset;
  formatCurrency: (value?: number) => string;
}

const colorPalette = [
  '#2563eb',
  '#16a34a',
  '#f97316',
  '#dc2626',
  '#9333ea',
  '#0891b2',
  '#facc15',
  '#6366f1',
];

const MonthlyComparisonChart = ({ data, formatCurrency }: MonthlyComparisonChartProps) => {
  if (data.months.length === 0 || data.series.length === 0) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Ainda não há dados suficientes para exibir a evolução de saldo das contas.
      </p>
    );
  }

  const monthLabels = data.months.map((point) =>
    new Date(point.year, point.month - 1).toLocaleDateString('pt-BR', {
      month: 'short',
      year: 'numeric',
    })
  );

  return (
    <div className="mt-4">
      <LineChart
        height={320}
        xAxis={[
          {
            scaleType: 'point',
            data: monthLabels,
          },
        ]}
        series={data.series.map((serie, index) => ({
          id: serie.accountId,
          label: serie.label,
          data: serie.data,
          color: colorPalette[index % colorPalette.length],
          valueFormatter: (value: number | null) => formatCurrency(value ?? 0),
          showMark: false,
        }))}
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

export default MonthlyComparisonChart;
