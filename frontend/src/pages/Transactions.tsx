import { useEffect, useMemo, useState, type ChangeEvent, type FormEvent } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import financeService from '../services/finance';
import type {
  BankAccount,
  Category,
  CreateTransactionPayload,
  UpdateTransactionPayload,
  Transaction,
  TransactionType,
  DashboardRangeKey,
} from '../types/finance';
import { useDashboardRange } from '../contexts/DashboardRangeContext';

type Feedback =
  | { type: 'success'; message: string }
  | { type: 'error'; message: string }
  | null;

const transactionTypeLabels: Record<TransactionType, string> = {
  INCOME: 'Receita',
  EXPENSE: 'Despesa',
  TRANSFER_IN: 'Transferência recebida',
  TRANSFER_OUT: 'Transferência enviada',
};

interface TransactionFormState {
  bankAccountId: string;
  type: TransactionType;
  amount: string;
  transactionDate: string;
  description: string;
  categoryId: string;
  notes: string;
}

const buildDefaultFormState = (accounts: BankAccount[]): TransactionFormState => ({
  bankAccountId: accounts[0]?.id ?? '',
  type: 'INCOME',
  amount: '',
  transactionDate: new Date().toISOString().split('T')[0],
  description: '',
  categoryId: '',
  notes: '',
});

const resolveRangeStart = (range: DashboardRangeKey): Date => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const start = new Date(today);

  const shiftMonths = (months: number) => {
    start.setMonth(start.getMonth() - months);
  };

  switch (range) {
    case '12M':
      shiftMonths(12);
      break;
    case '6M':
      shiftMonths(6);
      break;
    case '1M':
      shiftMonths(1);
      break;
    case '1W':
      start.setDate(start.getDate() - 7);
      break;
    default:
      break;
  }

  if (start.getTime() < today.getTime()) {
    start.setDate(start.getDate() + 1);
  }

  return start;
};

const Transactions = () => {
  const [accounts, setAccounts] = useState<BankAccount[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [formData, setFormData] = useState<TransactionFormState>(buildDefaultFormState([]));
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [feedback, setFeedback] = useState<Feedback>(null);
  const [editingTransactionId, setEditingTransactionId] = useState<string | null>(null);
  const [processingTransactionId, setProcessingTransactionId] = useState<string | null>(null);
  const { selectedRange } = useDashboardRange();

  const transactionTypes = useMemo(
    () => Object.keys(transactionTypeLabels) as TransactionType[],
    []
  );

  const loadDependencies = async () => {
    setIsLoading(true);
    try {
      const [accountsData, categoriesData, transactionsData] = await Promise.all([
        financeService.listBankAccounts(),
        financeService.listCategories(),
        financeService.listTransactions(),
      ]);
      setAccounts(accountsData);
      setCategories(categoriesData.filter((category) => category.active));
      if (Array.isArray(transactionsData)) {
        const sortedTransactions = [...transactionsData].sort(
          (a, b) =>
            new Date(b.transactionDate).getTime() - new Date(a.transactionDate).getTime()
        );
        setTransactions(sortedTransactions);
      } else {
        console.warn('Formato inesperado de transações recebido:', transactionsData);
        setTransactions([]);
      }
      setFormData((prev) => ({
        ...buildDefaultFormState(accountsData),
        description: prev.description,
      }));
    } catch (error) {
      console.error('Erro ao carregar dados iniciais de transações:', error);
      setFeedback({
        type: 'error',
        message: 'Não foi possível carregar suas contas, categorias ou transações.',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    void loadDependencies();
  }, []);

  const handleChange = (event: ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = event.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === 'amount' ? value.replace(/[^0-9.,]/g, '').replace(',', '.') : value,
    }));
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    const amount = Number(formData.amount);
    if (!Number.isFinite(amount) || amount <= 0) {
      setFeedback({ type: 'error', message: 'Informe um valor válido maior que zero.' });
      return;
    }

    setIsSubmitting(true);
    setFeedback(null);

    const payloadBase = {
      bankAccountId: formData.bankAccountId,
      type: formData.type,
      amount,
      transactionDate: formData.transactionDate,
      description: formData.description.trim(),
      categoryId: formData.categoryId || undefined,
      notes: formData.notes.trim() || undefined,
    } satisfies CreateTransactionPayload;

    try {
      if (editingTransactionId) {
        const updatePayload: UpdateTransactionPayload = payloadBase;
        await financeService.updateTransaction(editingTransactionId, updatePayload);
        setFeedback({ type: 'success', message: 'Transação atualizada com sucesso.' });
      } else {
        await financeService.createTransaction(payloadBase);
        setFeedback({ type: 'success', message: 'Transação registrada com sucesso.' });
      }
      setFormData(buildDefaultFormState(accounts));
      setEditingTransactionId(null);
      void loadDependencies();
    } catch (error: any) {
      console.error('Erro ao registrar transação:', error);
      if (error.code === 'ECONNABORTED') {
        setFeedback({
          type: 'error',
          message:
            'O serviço demorou para responder. Verifique se o backend está em execução e tente novamente.',
        });
        return;
      }
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível registrar a transação.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEdit = (transaction: Transaction) => {
    setEditingTransactionId(transaction.id);
    setFormData({
      bankAccountId: transaction.bankAccountId,
      type: transaction.type,
      amount: transaction.amount.toString(),
      transactionDate: transaction.transactionDate,
      description: transaction.description,
      categoryId: transaction.category?.id ?? '',
      notes: transaction.notes ?? '',
    });
    setFeedback(null);
  };

  const handleDelete = async (transaction: Transaction) => {
    const confirmed = window.confirm(
      `Deseja remover a transação "${transaction.description}"?`);
    if (!confirmed) {
      return;
    }

    setProcessingTransactionId(transaction.id);
    setFeedback(null);
    try {
      await financeService.deleteTransaction(transaction.id);
      setFeedback({ type: 'success', message: 'Transação removida com sucesso.' });
      if (editingTransactionId === transaction.id) {
        setEditingTransactionId(null);
        setFormData(buildDefaultFormState(accounts));
      }
      void loadDependencies();
    } catch (error: any) {
      console.error('Erro ao excluir transação:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível remover a transação.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setProcessingTransactionId(null);
    }
  };

  const filteredTransactions = useMemo(() => {
    if (transactions.length === 0) {
      return [];
    }
    const start = resolveRangeStart(selectedRange);
    const startTime = start.getTime();
    return transactions.filter((transaction) => {
      const txDate = new Date(`${transaction.transactionDate}T00:00:00`);
      if (Number.isNaN(txDate.getTime())) {
        return false;
      }
      return txDate.getTime() >= startTime;
    });
  }, [transactions, selectedRange]);

  return (
    <section className="space-y-6">
      <div className="rounded-3xl bg-white p-8 shadow-lg shadow-orange-100/50">
        <div className="border-b border-orange-100 pb-4">
          <h2 className="text-2xl font-semibold text-gray-900">Transações</h2>
          <p className="text-sm text-gray-500">
            Registre entradas e saídas para manter seu controle financeiro sempre atualizado.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-6">
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Conta bancária</label>
              <select
                name="bankAccountId"
                value={formData.bankAccountId}
                onChange={handleChange}
                disabled={accounts.length === 0}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                {accounts.length === 0 ? (
                  <option value="">Cadastre uma conta antes de registrar transações</option>
                ) : (
                  accounts.map((account) => (
                    <option key={account.id} value={account.id}>
                      {account.nickname || account.institutionName} • Agência {account.branchNumber}
                    </option>
                  ))
                )}
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Tipo de transação</label>
              <select
                name="type"
                value={formData.type}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                {transactionTypes.map((type) => (
                  <option key={type} value={type}>
                    {transactionTypeLabels[type]}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Valor</label>
              <input
                type="text"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                placeholder="0,00"
                required
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Data</label>
              <input
                type="date"
                name="transactionDate"
                value={formData.transactionDate}
                onChange={handleChange}
                required
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2 md:col-span-2">
              <label className="text-sm font-medium text-gray-700">Descrição</label>
              <input
                type="text"
                name="description"
                value={formData.description}
                onChange={handleChange}
                required
                placeholder="Ex.: Salário, Aluguel, Supermercado..."
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Categoria</label>
              <select
                name="categoryId"
                value={formData.categoryId}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                <option value="">Sem categoria</option>
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2 md:col-span-2">
              <label className="text-sm font-medium text-gray-700">Observações (opcional)</label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows={3}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
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
              disabled={isSubmitting || accounts.length === 0}
              className="rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-8 py-3 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:from-orange-600 hover:to-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSubmitting
                ? editingTransactionId
                  ? 'Atualizando...'
                  : 'Registrando...'
                : editingTransactionId
                ? 'Atualizar transação'
                : 'Registrar transação'}
            </button>
            {editingTransactionId && (
              <button
                type="button"
                onClick={() => {
                  setEditingTransactionId(null);
                  setFormData(buildDefaultFormState(accounts));
                }}
                className="rounded-2xl border border-orange-200 px-6 py-3 text-sm font-semibold text-orange-500 transition hover:bg-orange-50"
              >
                Cancelar edição
              </button>
            )}
          </div>
        </form>
      </div>

      <div className="rounded-3xl bg-white p-6 shadow-lg shadow-orange-100/50">
        <h3 className="text-lg font-semibold text-gray-900">Todas as transações</h3>

        {isLoading ? (
          <div className="mt-4 flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-orange-100 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Carregando transações...
          </div>
        ) : filteredTransactions.length === 0 ? (
          <div className="mt-4 flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-dashed border-orange-200 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Nenhuma transação encontrada para o período selecionado. Altere o filtro ou registre uma
            nova movimentação.
          </div>
        ) : (
          <ul className="mt-4 space-y-3">
            {filteredTransactions.map((transaction) => (
              <li
                key={transaction.id}
                className="relative flex items-center gap-4 rounded-2xl border border-orange-100 bg-orange-50/40 px-6 py-3 text-sm"
              >
                <div className="flex-1">
                  <p className="font-semibold text-gray-900">
                    {transaction.description}{' '}
                    <span className="text-xs uppercase tracking-wide text-orange-500">
                      {transactionTypeLabels[transaction.type]}
                    </span>
                  </p>
                  <p className="text-xs text-gray-500">
                    {new Date(transaction.transactionDate).toLocaleDateString('pt-BR')} •{' '}
                    {transaction.category?.name ?? 'Sem categoria'}
                  </p>
                </div>
                <p
                  className={`absolute left-1/2 -translate-x-1/2 whitespace-nowrap text-center font-semibold ${
                    transaction.type === 'EXPENSE' || transaction.type === 'TRANSFER_OUT'
                      ? 'text-red-500'
                      : 'text-green-600'
                  }`}
                >
                  {transaction.type === 'EXPENSE' || transaction.type === 'TRANSFER_OUT' ? '-' : '+'}
                  {Math.abs(transaction.amount).toLocaleString('pt-BR', {
                    style: 'currency',
                    currency: 'BRL',
                  })}
                </p>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => handleEdit(transaction)}
                    className="rounded-full border border-orange-100 p-2 text-orange-500 transition hover:bg-orange-100/60"
                    title="Editar transação"
                  >
                    <Pencil className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => handleDelete(transaction)}
                    className="rounded-full border border-red-100 p-2 text-red-500 transition hover:bg-red-100/60"
                    title="Excluir transação"
                    disabled={processingTransactionId === transaction.id}
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  );
};

export default Transactions;
