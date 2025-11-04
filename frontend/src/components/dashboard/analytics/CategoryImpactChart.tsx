import { PieChart } from '@mui/x-charts/PieChart';

export interface CategoryChartItem {
  id: string;
  label: string;
  value: number;
  color?: string;
}

interface CategoryImpactChartProps {
  data: CategoryChartItem[];
  formatCurrency: (value?: number) => string;
}

const fallbackPalette = [
  '#fb923c',
  '#f97316',
  '#facc15',
  '#34d399',
  '#60a5fa',
  '#a855f7',
  '#f472b6',
  '#38bdf8',
];

const CategoryImpactChart = ({ data, formatCurrency }: CategoryImpactChartProps) => {
  if (data.length === 0) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Ainda não há movimentações categorizadas suficientes para este gráfico.
      </p>
    );
  }

  return (
    <div className="mt-4 flex flex-col items-center gap-4">
      <PieChart
        height={320}
        series={[
          {
            data: data.map((category, index) => ({
              id: category.id,
              label: category.label,
              value: category.value,
              color: category.color ?? fallbackPalette[index % fallbackPalette.length],
            })),
            innerRadius: 40,
            outerRadius: 120,
            paddingAngle: 3,
            cornerRadius: 4,
            valueFormatter: (item) => formatCurrency(item.value ?? 0),
          },
        ]}
        slotProps={{
          legend: {
            position: { vertical: 'bottom', horizontal: 'center' },
          },
        }}
      />
    </div>
  );
};

export default CategoryImpactChart;
