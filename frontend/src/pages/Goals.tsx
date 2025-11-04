import { useCallback, useEffect, useMemo, useState, type ChangeEvent, type FormEvent } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import financeService from '../services/finance';
import type {
  AllocateGoalAmountPayload,
  Category,
  CreateFinancialGoalPayload,
  FinancialGoal,
  GoalAllocationOverview,
  GoalStatus,
  GoalType,
  UpdateFinancialGoalPayload,
} from '../types/finance';
import { useDashboardRange } from '../contexts/DashboardRangeContext';

type Feedback =
  | { type: 'success'; message: string }
  | { type: 'error'; message: string }
  | null;

interface GoalFormState {
  name: string;
  type: GoalType;
  categoryId: string;
  targetAmount: string;
  startDate: string;
  endDate: string;
  description: string;
  notifyOnAchieve: boolean;
  notifyOnExceed: boolean;
  active: boolean;
}

const goalTypeLabels: Record<GoalType, string> = {
  SAVINGS: 'Acúmulo de reservas',
  EXPENSE_LIMIT: 'Limite de gastos',
};

const goalStatusStyles: Record<GoalStatus, { label: string; className: string }> = {
  IN_PROGRESS: { label: 'Em andamento', className: 'bg-blue-100 text-blue-700' },
  ACHIEVED: { label: 'Atingida', className: 'bg-green-100 text-green-700' },
  EXCEEDED: { label: 'Ultrapassada', className: 'bg-red-100 text-red-600' },
  EXPIRED: { label: 'Expirada', className: 'bg-gray-200 text-gray-600' },
};

const extractErrorMessage = (error: unknown, fallback: string): string => {
  if (typeof error === 'object' && error !== null) {
    const maybeResponse = (error as { response?: unknown }).response;
    if (typeof maybeResponse === 'object' && maybeResponse !== null) {
      const data = (maybeResponse as { data?: unknown }).data;
      if (typeof data === 'object' && data !== null) {
        const detail = (data as { detail?: unknown }).detail;
        if (typeof detail === 'string' && detail.trim().length > 0) {
          return detail;
        }
        const message = (data as { message?: unknown }).message;
        if (typeof message === 'string' && message.trim().length > 0) {
          return message;
        }
      }
    }
  }
  return fallback;
};

const buildDefaultGoalFormState = (): GoalFormState => ({
  name: '',
  type: 'SAVINGS',
  categoryId: '',
  targetAmount: '',
  startDate: new Date().toISOString().split('T')[0],
  endDate: '',
  description: '',
  notifyOnAchieve: true,
  notifyOnExceed: true,
  active: true,
});

const Goals = () => {
  const { selectedRange } = useDashboardRange();
  const [categories, setCategories] = useState<Category[]>([]);
  const [goals, setGoals] = useState<FinancialGoal[]>([]);
  const [formData, setFormData] = useState<GoalFormState>(() => buildDefaultGoalFormState());
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [feedback, setFeedback] = useState<Feedback>(null);
  const [editingGoalId, setEditingGoalId] = useState<string | null>(null);
  const [processingGoalId, setProcessingGoalId] = useState<string | null>(null);
  const [allocationOverview, setAllocationOverview] = useState<GoalAllocationOverview | null>(null);
  const [isAllocationLoading, setIsAllocationLoading] = useState(false);
  const [allocationInputs, setAllocationInputs] = useState<
    Record<string, { amount: string; description: string }>
  >({});
  const [allocatingGoalId, setAllocatingGoalId] = useState<string | null>(null);

  const currencyFormatter = useMemo(
    () =>
      new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 2,
      }),
    []
  );

  const availableCategories = useMemo(() => {
    if (formData.type === 'SAVINGS') {
      return categories.filter((category) => category.type === 'INCOME');
    }
    if (formData.type === 'EXPENSE_LIMIT') {
      return categories.filter((category) => category.type === 'EXPENSE');
    }
    return categories;
  }, [categories, formData.type]);

  const loadAllocation = useCallback(async () => {
    setIsAllocationLoading(true);
    try {
      const response = await financeService.getGoalAllocationOverview(selectedRange);
      setAllocationOverview(response);
    } catch (error) {
      console.error('Erro ao carregar saldo acumulado para metas:', error);
      setFeedback((prev) =>
        prev?.type === 'error'
          ? prev
          : {
              type: 'error',
              message: 'Não foi possível carregar o saldo acumulado. Tente novamente em instantes.',
            }
      );
    } finally {
      setIsAllocationLoading(false);
    }
  }, [selectedRange]);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [categoriesResponse, goalsResponse] = await Promise.all([
        financeService.listCategories(),
        financeService.listFinancialGoals(),
      ]);
      setCategories(categoriesResponse.filter((category) => category.active));
      setGoals(goalsResponse);
      setAllocationInputs({});
    } catch (error) {
      console.error('Erro ao carregar dados de metas:', error);
      setFeedback({
        type: 'error',
        message: 'Não foi possível carregar categorias ou metas financeiras. Tente novamente.',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    void loadData();
  }, []);

  useEffect(() => {
    void loadAllocation();
  }, [loadAllocation]);

  const allocationRangeLabel = useMemo(() => {
    const timeRange = allocationOverview?.timeRange;
    if (!timeRange) {
      return 'Período não informado';
    }
    if (timeRange.label) {
      return timeRange.label;
    }
    const start = new Date(`${timeRange.startDate}T00:00:00`);
    const end = new Date(`${timeRange.endDate}T23:59:59`);
    const formatter = new Intl.DateTimeFormat('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      return 'Período não informado';
    }
    return `${formatter.format(start)} a ${formatter.format(end)}`;
  }, [allocationOverview?.timeRange]);

  const allocationMap = useMemo(() => {
    const map = new Map<string, GoalAllocationOverview['goals'][number]>();
    allocationOverview?.goals.forEach((item) => {
      map.set(item.goalId, item);
    });
    return map;
  }, [allocationOverview]);

  const getAllocationInput = (goalId: string) =>
    allocationInputs[goalId] ?? { amount: '', description: '' };

  const handleAllocationInputChange = (
    goalId: string,
    field: 'amount' | 'description',
    value: string
  ) => {
    setAllocationInputs((prev) => {
      const existing = prev[goalId] ?? { amount: '', description: '' };
      return {
        ...prev,
        [goalId]: {
          ...existing,
          [field]: field === 'amount' ? value.replace(/[^0-9.,]/g, '').replace(',', '.') : value,
        },
      };
    });
  };

  const handleChange = (
    event: ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = event.target;
    setFormData((prev) => ({
      ...prev,
      [name]:
        name === 'targetAmount'
          ? value.replace(/[^0-9.,]/g, '').replace(',', '.')
          : value,
    }));
  };

  const handleCheckboxChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { name, checked } = event.target;
    setFormData((prev) => ({
      ...prev,
      [name]: checked,
    }));
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setFeedback(null);

    if (!formData.targetAmount) {
      setFeedback({ type: 'error', message: 'Informe o valor objetivo da meta.' });
      return;
    }

    const targetAmount = Number(formData.targetAmount);
    if (!Number.isFinite(targetAmount) || targetAmount <= 0) {
      setFeedback({ type: 'error', message: 'O valor objetivo deve ser maior que zero.' });
      return;
    }

    if (formData.endDate && formData.endDate < formData.startDate) {
      setFeedback({
        type: 'error',
        message: 'A data final deve ser igual ou posterior à data inicial.',
      });
      return;
    }

    setIsSubmitting(true);

    const payloadBase = {
      name: formData.name.trim(),
      type: formData.type,
      categoryId: formData.categoryId || undefined,
      targetAmount,
      startDate: formData.startDate,
      endDate: formData.endDate || undefined,
      description: formData.description.trim() || undefined,
      notifyOnAchieve: formData.notifyOnAchieve,
      notifyOnExceed: formData.notifyOnExceed,
    } satisfies CreateFinancialGoalPayload;

    try {
      if (editingGoalId) {
        const updatePayload: UpdateFinancialGoalPayload = {
          ...payloadBase,
          active: formData.active,
        };
        await financeService.updateFinancialGoal(editingGoalId, updatePayload);
        setFeedback({ type: 'success', message: 'Meta financeira atualizada com sucesso.' });
      } else {
        await financeService.createFinancialGoal(payloadBase);
        setFeedback({ type: 'success', message: 'Meta financeira cadastrada com sucesso.' });
      }
      setFormData(buildDefaultGoalFormState());
      setEditingGoalId(null);
      await loadData();
    } catch (error: unknown) {
      console.error('Erro ao cadastrar meta financeira:', error);
      const detail = extractErrorMessage(error, 'Não foi possível salvar a meta financeira.');
      setFeedback({ type: 'error', message: detail });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEdit = (goal: FinancialGoal) => {
    setEditingGoalId(goal.id);
    setFormData({
      name: goal.name,
      type: goal.type,
      categoryId: goal.category?.id ?? '',
      targetAmount: goal.targetAmount.toString(),
      startDate: goal.startDate,
      endDate: goal.endDate ?? '',
      description: goal.description ?? '',
      notifyOnAchieve: goal.notifyOnAchieve,
      notifyOnExceed: goal.notifyOnExceed,
      active: goal.active,
    });
    setFeedback(null);
  };

  const handleDelete = async (goal: FinancialGoal) => {
    const confirmed = window.confirm(
      `Deseja remover a meta "${goal.name}"? Essa ação não poderá ser desfeita.`
    );
    if (!confirmed) {
      return;
    }

    setProcessingGoalId(goal.id);
    setFeedback(null);
    try {
      await financeService.deleteFinancialGoal(goal.id);
      setFeedback({ type: 'success', message: 'Meta financeira removida com sucesso.' });
      if (editingGoalId === goal.id) {
        setEditingGoalId(null);
        setFormData(buildDefaultGoalFormState());
      }
      await loadData();
      await loadAllocation();
    } catch (error: unknown) {
      console.error('Erro ao excluir meta financeira:', error);
      const detail = extractErrorMessage(error, 'Não foi possível remover a meta financeira.');
      setFeedback({ type: 'error', message: detail });
    } finally {
      setProcessingGoalId(null);
    }
  };

  const handleAllocate = async (goal: FinancialGoal) => {
    const entry = getAllocationInput(goal.id);
    const rawAmount = entry.amount.trim();
    if (!rawAmount) {
      setFeedback({ type: 'error', message: 'Informe o valor que deseja destinar para a meta.' });
      return;
    }

    const amount = Number(rawAmount);
    if (!Number.isFinite(amount) || amount <= 0) {
      setFeedback({ type: 'error', message: 'O valor informado deve ser maior que zero.' });
      return;
    }

    const available = allocationOverview?.available ?? 0;
    if (amount > available) {
      setFeedback({
        type: 'error',
        message: 'O valor excede o saldo disponível para destinação.',
      });
      return;
    }

    const allocationData = allocationMap.get(goal.id);
    const remaining = allocationData?.remainingAmount ?? Math.max(goal.targetAmount - goal.currentAmount, 0);
    if (amount > remaining) {
      setFeedback({
        type: 'error',
        message: 'O valor excede o que falta para concluir esta meta.',
      });
      return;
    }

    setAllocatingGoalId(goal.id);
    setFeedback(null);
    try {
      const payload: AllocateGoalAmountPayload = {
        amount,
        description: entry.description.trim() ? entry.description.trim() : undefined,
      };
      const updatedGoal = await financeService.allocateGoalAmount(goal.id, payload);
      setGoals((prev) => prev.map((item) => (item.id === goal.id ? updatedGoal : item)));
      setAllocationInputs((prev) => ({
        ...prev,
        [goal.id]: { amount: '', description: '' },
      }));
      setFeedback({
        type: 'success',
        message: `Destinamos ${currencyFormatter.format(amount)} para "${goal.name}".`,
      });
      await loadAllocation();
    } catch (error: unknown) {
      console.error('Erro ao destinar valor para meta:', error);
      const detail = extractErrorMessage(error, 'Não foi possível destinar o valor informado.');
      setFeedback({ type: 'error', message: detail });
    } finally {
      setAllocatingGoalId(null);
    }
  };

  const computeProgress = (goal: FinancialGoal) => {
    if (!goal.targetAmount || goal.targetAmount <= 0) {
      return 0;
    }
    const ratio = (goal.currentAmount / goal.targetAmount) * 100;
    return Number.isFinite(ratio) ? Math.max(0, Math.round(ratio)) : 0;
  };

  const formatDate = (value?: string) => {
    if (!value) {
      return 'Sem data definida';
    }
    return new Date(value).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
    });
  };

  return (
    <section className="space-y-6">
      <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
        <div className="flex flex-col gap-3 border-b border-orange-100 pb-4 md:flex-row md:items-start md:justify-between">
          <div>
            <h2 className="text-2xl font-semibold text-gray-900">Saldo destinado às metas</h2>
            <p className="text-sm text-gray-500">Período considerado: {allocationRangeLabel}</p>
          </div>
          <p className="text-xs text-gray-500 md:text-right">
            Ajuste o período pelos botões no topo do painel.
          </p>
        </div>

        {isAllocationLoading ? (
          <p className="mt-6 text-sm text-gray-500">Carregando saldo acumulado...</p>
        ) : allocationOverview ? (
          <div className="mt-6 grid gap-4 sm:grid-cols-3">
            <div className="rounded-2xl border border-orange-100 bg-orange-50/40 p-4">
              <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
                Dinheiro acumulado
              </p>
              <p className="mt-2 text-lg font-semibold text-gray-900">
                {currencyFormatter.format(allocationOverview.accumulated)}
              </p>
            </div>
            <div className="rounded-2xl border border-orange-100 bg-orange-50/40 p-4">
              <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
                Já destinado
              </p>
              <p className="mt-2 text-lg font-semibold text-gray-900">
                {currencyFormatter.format(allocationOverview.allocated)}
              </p>
            </div>
            <div className="rounded-2xl border border-orange-100 bg-orange-50/40 p-4">
              <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
                Disponível para metas
              </p>
              <p className="mt-2 text-lg font-semibold text-gray-900">
                {currencyFormatter.format(allocationOverview.available)}
              </p>
              {allocationOverview.available <= 0 ? (
                <p className="mt-2 text-xs text-gray-500">
                  Cadastre novas receitas ou ajuste o período para liberar saldo disponível.
                </p>
              ) : null}
            </div>
          </div>
        ) : (
          <p className="mt-6 text-sm text-gray-500">
            Não foi possível obter o saldo acumulado no momento. Tente atualizar a página.
          </p>
        )}
      </div>

      <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
        <div className="border-b border-orange-100 pb-4">
          <h2 className="text-2xl font-semibold text-gray-900">Metas financeiras</h2>
          <p className="text-sm text-gray-500">
            Defina objetivos de economia ou limites de gastos e acompanhe o progresso ao longo do tempo.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Nome da meta</label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                maxLength={120}
                placeholder="Ex.: Reserva de emergência, Gastos com alimentação"
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Tipo</label>
              <select
                name="type"
                value={formData.type}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                {(Object.keys(goalTypeLabels) as GoalType[]).map((type) => (
                  <option key={type} value={type}>
                    {goalTypeLabels[type]}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Valor objetivo</label>
              <input
                type="text"
                name="targetAmount"
                value={formData.targetAmount}
                onChange={handleChange}
                placeholder="0,00"
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
                required
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Categoria (opcional)</label>
              <select
                name="categoryId"
                value={formData.categoryId}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                <option value="">Aplicar a todas as categorias compatíveis</option>
                {availableCategories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Data de início</label>
              <input
                type="date"
                name="startDate"
                value={formData.startDate}
                onChange={handleChange}
                required
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Data de conclusão (opcional)</label>
              <input
                type="date"
                name="endDate"
                value={formData.endDate}
                onChange={handleChange}
                min={formData.startDate}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="lg:col-span-2">
              <label className="text-sm font-medium text-gray-700">Descrição (opcional)</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleChange}
                maxLength={255}
                rows={2}
                placeholder="Compartilhe detalhes, como a motivação ou critérios da meta."
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-2.5 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="flex flex-col gap-2 rounded-2xl border border-orange-100 bg-orange-50/40 p-3 text-sm text-gray-600 lg:col-span-2">
              <label className="inline-flex items-center gap-3">
                <input
                  type="checkbox"
                  name="notifyOnAchieve"
                  checked={formData.notifyOnAchieve}
                  onChange={handleCheckboxChange}
                  className="h-4 w-4 rounded border-orange-300 text-orange-500 focus:ring-orange-400"
                />
                Avisar quando eu atingir esta meta
              </label>
              <label className="inline-flex items-center gap-3">
                <input
                  type="checkbox"
                  name="notifyOnExceed"
                  checked={formData.notifyOnExceed}
                  onChange={handleCheckboxChange}
                  className="h-4 w-4 rounded border-orange-300 text-orange-500 focus:ring-orange-400"
                />
                Avisar caso eu ultrapasse o limite definido
              </label>
              <p className="text-xs text-gray-500">
                Essas notificações serão utilizadas pelo serviço de alertas para manter você informado.
              </p>
              <label className="inline-flex items-center gap-3">
                <input
                  type="checkbox"
                  name="active"
                  checked={formData.active}
                  onChange={(event) =>
                    setFormData((prev) => ({ ...prev, active: event.target.checked }))
                  }
                  className="h-4 w-4 rounded border-orange-300 text-orange-500 focus:ring-orange-400"
                />
                Manter meta ativa
              </label>
            </div>
          </div>

          {feedback && (
            <div
              className={`rounded-2xl border px-4 py-3 text-sm font-medium ${
                feedback.type === 'success'
                  ? 'border-green-200 bg-green-50 text-green-700'
                  : 'border-red-200 bg-red-50 text-red-600'
              }`}
            >
              {feedback.message}
            </div>
          )}

          <div className="flex flex-wrap items-center justify-end gap-3">
            <button
              type="submit"
              disabled={isSubmitting}
              className="rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-8 py-3 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:from-orange-600 hover:to-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSubmitting
                ? editingGoalId
                  ? 'Atualizando...'
                  : 'Cadastrando...'
                : editingGoalId
                ? 'Atualizar meta'
                : 'Cadastrar meta'}
            </button>
            {editingGoalId && (
              <button
                type="button"
                onClick={() => {
                  setEditingGoalId(null);
                  setFormData(buildDefaultGoalFormState());
                }}
                className="rounded-2xl border border-orange-200 px-6 py-3 text-sm font-semibold text-orange-500 transition hover:bg-orange-50"
              >
                Cancelar edição
              </button>
            )}
          </div>
        </form>
      </div>

      <div className="space-y-4">
        {isLoading ? (
          <div className="flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-orange-100 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Carregando metas cadastradas...
          </div>
        ) : goals.length === 0 ? (
          <div className="flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-dashed border-orange-200 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Nenhuma meta criada por enquanto. Use o formulário acima para definir seu primeiro objetivo.
          </div>
        ) : (
          goals.map((goal) => {
            const status = goalStatusStyles[goal.status];
            const progress = computeProgress(goal);
            const progressWidth = Math.max(0, Math.min(progress, 100));
            const allocationData = allocationMap.get(goal.id);
            const remainingAmount = allocationData?.remainingAmount ?? Math.max(goal.targetAmount - goal.currentAmount, 0);
            const allocationEntry = getAllocationInput(goal.id);
            const availableAmount = allocationOverview?.available ?? 0;
            const canAllocate = goal.status === 'IN_PROGRESS' && remainingAmount > 0 && availableAmount > 0;

            return (
              <div
                key={goal.id}
                className="rounded-3xl border border-orange-100 bg-white p-6 shadow-md shadow-orange-100/30 transition hover:shadow-lg hover:shadow-orange-100/60"
              >
                <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">{goal.name}</h3>
                    <p className="text-sm text-gray-500">
                      {goalTypeLabels[goal.type]} • {formatDate(goal.startDate)}
                      {goal.endDate ? ` → ${formatDate(goal.endDate)}` : ''}
                    </p>
                    {goal.category && (
                      <p className="text-xs text-orange-500">
                        Categoria acompanhada: {goal.category.name}
                      </p>
                    )}
                    {goal.description && (
                      <p className="mt-2 text-sm text-gray-600">{goal.description}</p>
                    )}
                  </div>
                  <div className="flex items-center gap-2">
                    <span
                      className={`rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-wide ${status.className}`}
                    >
                      {status.label}
                    </span>
                    <button
                      type="button"
                      onClick={() => handleEdit(goal)}
                      className="rounded-full border border-orange-100 p-2 text-orange-500 transition hover:bg-orange-50"
                      title="Editar meta"
                    >
                      <Pencil className="h-4 w-4" />
                    </button>
                    <button
                      type="button"
                      onClick={() => handleDelete(goal)}
                      className="rounded-full border border-red-100 p-2 text-red-500 transition hover:bg-red-50"
                      title="Excluir meta"
                      disabled={processingGoalId === goal.id}
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>

                <div className="mt-4 space-y-3">
                  <div className="flex flex-col gap-2 text-sm text-gray-700 md:flex-row md:items-center md:justify-between">
                    <span>
                      Acumulado: <strong>{currencyFormatter.format(goal.currentAmount)}</strong>
                    </span>
                    <span>
                      Objetivo: <strong>{currencyFormatter.format(goal.targetAmount)}</strong>
                    </span>
                  </div>
                  <div>
                    <div className="flex items-center justify-between text-xs text-gray-500">
                      <span>Progresso</span>
                      <span>{progress}%</span>
                    </div>
                    <div className="mt-2 h-2 rounded-full bg-orange-100">
                      <div
                        className={`h-full rounded-full ${
                          goal.status === 'ACHIEVED'
                            ? 'bg-green-500'
                            : goal.status === 'EXCEEDED'
                            ? 'bg-red-500'
                            : 'bg-orange-500'
                        }`}
                        style={{ width: `${progressWidth}%` }}
                      ></div>
                    </div>
                  </div>
                </div>
                {allocationOverview && goal.status === 'IN_PROGRESS' && (
                  <div className="mt-4 space-y-3 rounded-2xl border border-orange-100 bg-orange-50/40 p-4">
                    <div className="flex flex-col gap-1 text-sm text-gray-700 md:flex-row md:items-center md:justify-between">
                      <span className="font-semibold text-gray-800">
                        Destinar recursos para esta meta
                      </span>
                      <span className="text-xs text-gray-500">
                        Falta {currencyFormatter.format(remainingAmount)} | Disponível {currencyFormatter.format(availableAmount)}
                      </span>
                    </div>
                    <div className="grid gap-3 md:grid-cols-[1fr_auto]">
                      <div className="space-y-2">
                        <label className="text-xs font-medium text-gray-600">Valor a destinar</label>
                        <input
                          type="text"
                          value={allocationEntry.amount}
                          onChange={(event) =>
                            handleAllocationInputChange(goal.id, 'amount', event.target.value)
                          }
                          placeholder="0,00"
                          className="w-full rounded-2xl border border-orange-200 bg-white px-4 py-2 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
                          disabled={allocatingGoalId === goal.id || !canAllocate}
                        />
                      </div>
                      <div className="space-y-2 md:col-span-full">
                        <label className="text-xs font-medium text-gray-600">Observações (opcional)</label>
                        <input
                          type="text"
                          value={allocationEntry.description}
                          onChange={(event) =>
                            handleAllocationInputChange(goal.id, 'description', event.target.value)
                          }
                          maxLength={255}
                          placeholder="Ex.: bônus, renda extra, transferência..."
                          className="w-full rounded-2xl border border-orange-200 bg-white px-4 py-2 text-sm text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
                          disabled={allocatingGoalId === goal.id}
                        />
                      </div>
                    </div>
                    <div className="flex flex-wrap items-center justify-between gap-3 text-xs text-gray-500">
                      <span>
                        Valores destinados reduzem o saldo disponível exibido acima.
                      </span>
                      <button
                        type="button"
                        onClick={() => handleAllocate(goal)}
                        disabled={allocatingGoalId === goal.id || !canAllocate || allocationEntry.amount.trim() === ''}
                        className={`rounded-full px-4 py-2 text-sm font-semibold transition ${
                          allocatingGoalId === goal.id || !canAllocate || allocationEntry.amount.trim() === ''
                            ? 'cursor-not-allowed bg-gray-200 text-gray-500'
                            : 'bg-orange-500 text-white hover:bg-orange-600'
                        }`}
                      >
                        {allocatingGoalId === goal.id ? 'Destinando...' : 'Destinar valor'}
                      </button>
                    </div>
                  </div>
                )}
                {processingGoalId === goal.id && (
                  <p className="mt-3 text-xs text-red-500">Processando exclusão...</p>
                )}
              </div>
            );
          })
        )}
      </div>
    </section>
  );
};

export default Goals;
