import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import type { LucideIcon } from 'lucide-react';
import {
  ArrowRightLeft,
  BookOpenCheck,
  CheckCircle2,
  GraduationCap,
  Landmark,
  Lightbulb,
  LineChart,
  PiggyBank,
  Sparkles,
  Tags,
  Target,
  TrendingUp,
} from 'lucide-react';
import financeService from '../services/finance';
import { useDashboardRange } from '../contexts/DashboardRangeContext';
import type { DashboardOverview } from '../types/finance';

const formatter = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
  minimumFractionDigits: 2,
});

type ModuleCard = {
  title: string;
  description: string;
  tip: string;
  to: string;
  actionLabel: string;
  icon: LucideIcon;
};

type DailyChecklistItem = {
  id: string;
  label: string;
};

const moduleGuide: ModuleCard[] = [
  {
    title: 'Visão Geral',
    description:
      'Consolida saldos, entradas e saídas para você entender em segundos se o dia começou equilibrado.',
    tip: 'Comece o dia revisando este painel.',
    to: '/app',
    actionLabel: 'Abrir Visão Geral',
    icon: LineChart,
  },
  {
    title: 'Transações',
    description:
      'É o diário de bordo. Registre tudo, crie notas e identifique padrões que merecem atenção.',
    tip: 'Atualize sempre antes de encerrar o dia.',
    to: '/app/transacoes',
    actionLabel: 'Lançar Transações',
    icon: ArrowRightLeft,
  },
  {
    title: 'Categorias',
    description: 'Molde categorias conforme sua rotina para descobrir gatilhos de consumo sem esforço.',
    tip: 'Revise quando sentir que um gasto “sumiu”.',
    to: '/app/categorias',
    actionLabel: 'Organizar Categorias',
    icon: Tags,
  },
  {
    title: 'Contas Bancárias',
    description:
      'Centralize instituições, apelide saldos e acompanhe o propósito de cada conta sem abrir vários apps.',
    tip: 'Separe contas de uso diário das de objetivos.',
    to: '/app/contas',
    actionLabel: 'Gerenciar Contas',
    icon: Landmark,
  },
  {
    title: 'Metas',
    description:
      'Transforme excedentes em metas claras. Depósitos e percentuais mostram se o plano está decolando.',
    tip: 'Relacione cada meta a um motivo pessoal.',
    to: '/app/metas',
    actionLabel: 'Criar Meta',
    icon: Target,
  },
];

const financialMantras = [
  {
    title: 'Nomeie cada real',
    mantra: 'Dinheiro com propósito não desaparece.',
    detail: 'Use Categorias + Metas para contar ao seu cérebro por que cada valor existe. Isso reduz compras impulsivas.',
  },
  {
    title: 'Fluxo antes de foto',
    mantra: 'Aprenda com o movimento, não só com o saldo final.',
    detail:
      'Verifique Transações e escreva mini lições nas notas. O registro diário sustenta decisões melhores ao longo do mês.',
  },
  {
    title: 'Pequenas vitórias contam',
    mantra: 'Consistência vence intensidade.',
    detail:
      'Preferira aportes menores, porém frequentes. Metas com progresso semanal evitam que você abandone o plano.',
  },
];

const learningRituals = [
  {
    title: 'Mini meta de 7 dias',
    detail: 'Escolha uma categoria para limitar nesta semana e acompanhe o impacto no saldo livre.',
  },
  {
    title: 'Reforço positivo',
    detail: 'Valor economizado? Transfira imediatamente para uma meta ativa para sinalizar ao cérebro que valeu a pena.',
  },
  {
    title: 'Respira e revisa',
    detail: 'Reserve cinco minutos no fim do dia para reler notas e reconhecer o que aprendeu com cada decisão.',
  },
];

const dailyChecklistSeed: DailyChecklistItem[] = [
  {
    id: 'expenses',
    label: 'Registrei todas as despesas do dia?',
  },
  {
    id: 'income',
    label: 'Registrei todas as receitas do dia?',
  },
  {
    id: 'categories',
    label: 'Atualizei minhas categorias de receitas e despesas?',
  },
  {
    id: 'goals',
    label: 'Verifiquei minhas metas financeiras?',
  },
  {
    id: 'victory',
    label: 'Separei um valor para a próxima meta ou reserva?',
  },
];

const Education = () => {
  const { selectedRange } = useDashboardRange();
  const [overview, setOverview] = useState<DashboardOverview | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [learningGoal, setLearningGoal] = useState(3000);
  const [learningMonths, setLearningMonths] = useState(6);
  const [dailyChecklist, setDailyChecklist] = useState(
    () => dailyChecklistSeed.map((item) => ({ ...item, done: false }))
  );

  useEffect(() => {
    let isMounted = true;
    const loadOverview = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const data = await financeService.getDashboardOverview({ range: selectedRange });
        if (isMounted) {
          setOverview(data);
        }
      } catch (loadError) {
        console.error('Erro ao carregar educação financeira', loadError);
        if (isMounted) {
          setError('Não conseguimos carregar seus dados agora. Tente novamente em instantes.');
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    void loadOverview();

    return () => {
      isMounted = false;
    };
  }, [selectedRange]);

  const savingsRate = useMemo(() => {
    if (!overview || overview.totalIncome <= 0) {
      return 0;
    }
    return Math.max(0, (overview.netBalance / overview.totalIncome) * 100);
  }, [overview]);

  const studyFocus = useMemo(() => {
    if (!overview) {
      return 'Assim que os dados carregarem, vamos indicar em qual frente vale focar primeiro.';
    }

    if (overview.totalExpenses > overview.totalIncome) {
      return 'O consumo está acima da renda no período. Use a aba de Categorias para descobrir onde reduzir.';
    }

    if (savingsRate < 20) {
      return 'Você já mantém saldo positivo. Experimente turbinar a reserva destinando ao menos 20% da renda líquida.';
    }

    return 'Excelente! Que tal transformar parte do excedente em metas de longo prazo dentro da aba Metas?';
  }, [overview, savingsRate]);

  const recommendedMonthlyContribution = useMemo(() => {
    if (learningMonths <= 0) {
      return 0;
    }
    const base = learningGoal / learningMonths;
    const buffer = overview ? Math.min(overview.totalExpenses * 0.05, base * 0.5) : base * 0.2;
    return Math.round((base + buffer) * 100) / 100;
  }, [learningGoal, learningMonths, overview]);

  const completedChecklist = dailyChecklist.filter((item) => item.done).length;

  const toggleChecklistItem = (id: string) => {
    setDailyChecklist((items) =>
      items.map((item) => (item.id === id ? { ...item, done: !item.done } : item))
    );
  };

  return (
    <section className="space-y-8">
      <div className="rounded-3xl bg-gradient-to-r from-orange-500 via-orange-400 to-orange-300 p-8 text-white shadow-xl">
        <div className="grid gap-6 md:grid-cols-[2fr,1fr] md:items-center">
          <div>
            <p className="text-sm font-semibold uppercase tracking-wider text-white/80">
              Educação Financeira aplicada
            </p>
            <h1 className="text-3xl font-bold">Entenda a ferramenta, pratique com seus números</h1>
            <p className="mt-3 text-sm text-white/90">
              O Dashboard Financeiro foi desenhado como um laboratório pessoal: você registra fatos, entende padrões
              e reage rapidamente. Nesta página mostramos como cada módulo funciona e qual hábito ele estimula.
            </p>
            <ul className="mt-4 grid gap-2 text-sm text-white/90 md:grid-cols-2">
              <li className="rounded-2xl bg-white/15 px-4 py-3">
                <p className="font-semibold">1. Contextualize</p>
                <p className="text-xs text-white/80">Leia a Visão Geral e identifique tendências.</p>
              </li>
              <li className="rounded-2xl bg-white/15 px-4 py-3">
                <p className="font-semibold">2. Investigue</p>
                <p className="text-xs text-white/80">Registre transações, notas e categorias fiéis à vida real.</p>
              </li>
              <li className="rounded-2xl bg-white/15 px-4 py-3">
                <p className="font-semibold">3. Decide</p>
                <p className="text-xs text-white/80">Use Metas e Contas para transformar saldo em ação.</p>
              </li>
              <li className="rounded-2xl bg-white/15 px-4 py-3">
                <p className="font-semibold">4. Reforça</p>
                <p className="text-xs text-white/80">Volte ao módulo Educação para novos desafios.</p>
              </li>
            </ul>
          </div>
          <div className="flex flex-col gap-4 rounded-3xl bg-white/10 p-5">
            <div className="flex items-center gap-3">
              <GraduationCap className="h-10 w-10 text-white" />
              <div>
                <p className="text-xs uppercase tracking-wide text-white/70">Foco do momento</p>
                <p className="text-lg font-semibold leading-tight">{studyFocus}</p>
              </div>
            </div>
            <div className="rounded-2xl bg-white/10 p-4 text-sm text-white/90">
              <p className="font-semibold">Como usar:</p>
              <p>
                Leia o diagnóstico acima, escolha um módulo específico e aplique imediatamente. Educação financeira só
                acontece quando mexemos no orçamento real.
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
          <div className="flex items-center gap-3">
            <PiggyBank className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
            <div>
              <p className="text-sm font-medium text-gray-500">Saldo educativo</p>
              <p className="text-2xl font-semibold text-gray-900">
                {isLoading ? '...' : formatter.format(overview?.netBalance ?? 0)}
              </p>
            </div>
          </div>
          <p className="mt-4 text-sm text-gray-500">
            Net balance do período. Use-o como termômetro principal para avaliar se está aprendendo a viver abaixo da renda.
          </p>
        </div>

        <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
          <div className="flex items-center gap-3">
            <TrendingUp className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
            <div>
              <p className="text-sm font-medium text-gray-500">Taxa de poupança</p>
              <p className="text-2xl font-semibold text-gray-900">
                {isLoading ? '...' : `${savingsRate.toFixed(1)}%`}
              </p>
            </div>
          </div>
          <p className="mt-4 text-sm text-gray-500">
            Representa quanto da sua renda ficou disponível para construir patrimônio. Mire acima de 20% para acelerar metas.
          </p>
        </div>

        <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
          <div className="flex items-center gap-3">
            <Lightbulb className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
            <div>
              <p className="text-sm font-medium text-gray-500">Carta de aprendizado</p>
              <p className="text-sm font-semibold text-gray-900">
                {error ? 'Tente novamente mais tarde.' : studyFocus}
              </p>
            </div>
          </div>
          <p className="mt-4 text-sm text-gray-500">
            Diagnóstico automático construído com base no seu comportamento recente dentro do Dashboard.
          </p>
        </div>
      </div>

      <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
        <div className="flex items-center gap-3">
          <BookOpenCheck className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Guia rápido da plataforma</h2>
            <p className="text-sm text-gray-500">Entenda o papel de cada módulo e como ele sustenta sua educação financeira.</p>
          </div>
        </div>
        <div className="mt-6 grid gap-4 md:grid-cols-2">
          {moduleGuide.map((module) => {
            const Icon = module.icon;
            return (
              <div key={module.title} className="flex flex-col rounded-2xl border border-orange-50 p-4">
                <div className="flex items-center gap-3">
                  <Icon className="h-8 w-8 rounded-2xl bg-orange-50 p-2 text-orange-500" />
                  <div>
                    <p className="text-sm font-semibold text-gray-900">{module.title}</p>
                    <p className="text-xs text-orange-500">{module.tip}</p>
                  </div>
                </div>
                <p className="mt-3 flex-1 text-sm text-gray-600">{module.description}</p>
                <Link
                  to={module.to}
                  className="mt-4 inline-flex items-center justify-center rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-3 py-2 text-xs font-semibold text-white shadow-sm shadow-orange-200 transition hover:opacity-90"
                >
                  {module.actionLabel}
                </Link>
              </div>
            );
          })}
        </div>
      </div>

      <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold text-gray-900">Laboratório de decisões</h2>
          <Sparkles className="h-5 w-5 text-orange-500" />
        </div>
        <p className="mt-2 text-sm text-gray-500">
          Simule quanto precisa separar com base em metas reais e transforme a projeção em uma nova meta.
        </p>

        <div className="mt-6 space-y-4">
          <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
            Valor da meta
          </label>
          <input
            type="range"
            min={500}
            max={50000}
            step={500}
            value={learningGoal}
            onChange={(event) => setLearningGoal(Number(event.target.value))}
            className="w-full accent-orange-500"
          />
          <p className="text-sm font-semibold text-gray-900">{formatter.format(learningGoal)}</p>

          <label className="text-xs font-semibold uppercase tracking-wider text-gray-500">
            Prazo (meses)
          </label>
          <input
            type="range"
            min={3}
            max={24}
            step={1}
            value={learningMonths}
            onChange={(event) => setLearningMonths(Number(event.target.value))}
            className="w-full accent-orange-500"
          />
          <p className="text-sm font-semibold text-gray-900">{learningMonths} meses</p>
        </div>

        <div className="mt-6 rounded-2xl bg-orange-50 p-4">
          <p className="text-xs font-semibold uppercase tracking-wider text-orange-500">Sugestão</p>
          <p className="text-2xl font-bold text-gray-900">
            {formatter.format(recommendedMonthlyContribution)} / mês
          </p>
          <p className="mt-2 text-sm text-gray-600">
            Crie uma meta no módulo Metas com o valor acima e monitore o quanto cada depósito aproxima sua conclusão.
          </p>
        </div>
      </div>

      <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
        <div className="flex items-center gap-3">
          <Lightbulb className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Lemas de educação financeira</h2>
            <p className="text-sm text-gray-500">Relembre princípios para orientar suas decisões dentro da ferramenta.</p>
          </div>
        </div>
        <div className="mt-6 grid gap-4 md:grid-cols-3">
          {financialMantras.map((mantra) => (
            <div key={mantra.title} className="flex flex-col rounded-2xl border border-orange-50 p-4">
              <p className="text-xs font-semibold uppercase tracking-wider text-orange-500">
                {mantra.title}
              </p>
              <p className="mt-2 text-sm font-semibold text-gray-900">{mantra.mantra}</p>
              <p className="mt-3 text-sm text-gray-600">{mantra.detail}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
          <div className="flex items-center gap-3">
            <Target className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
            <div>
              <h2 className="text-xl font-semibold text-gray-900">Rituais de aplicação</h2>
              <p className="text-sm text-gray-500">Pequenas ações que conectam teoria, números e comportamento.</p>
            </div>
          </div>
          <ul className="mt-6 space-y-4">
            {learningRituals.map((step) => (
              <li key={step.title} className="flex items-start gap-3 rounded-2xl border border-orange-50 p-4">
                <CheckCircle2 className="mt-1 h-5 w-5 text-orange-500" />
                <div>
                  <p className="text-sm font-semibold text-gray-900">{step.title}</p>
                  <p className="text-sm text-gray-500">{step.detail}</p>
                </div>
              </li>
            ))}
          </ul>
        </div>

        <div className="rounded-3xl border border-orange-100 bg-white p-6 shadow-sm shadow-orange-100/40">
          <div className="flex items-center gap-3">
            <BookOpenCheck className="h-10 w-10 rounded-2xl bg-orange-50 p-2 text-orange-500" />
            <div>
              <h2 className="text-xl font-semibold text-gray-900">Checklist diário</h2>
              <p className="text-sm text-gray-500">Perguntas rápidas para encerrar o dia com consciência financeira.</p>
            </div>
          </div>
          <p className="mt-6 text-sm font-semibold text-orange-600">
            {completedChecklist} de {dailyChecklist.length} tarefas concluídas
          </p>
          <ul className="mt-4 space-y-2">
            {dailyChecklist.map((item) => (
              <li key={item.id} className="rounded-2xl border border-gray-100 bg-white">
                <label className="flex cursor-pointer items-center gap-3 px-4 py-3 text-sm text-gray-900">
                  <input
                    type="checkbox"
                    checked={item.done}
                    onChange={() => toggleChecklistItem(item.id)}
                    className="h-4 w-4 rounded border-gray-300 text-orange-500 focus:ring-orange-500"
                  />
                  <span className={item.done ? 'line-through text-gray-500' : ''}>{item.label}</span>
                </label>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
};

export default Education;
