import { useEffect, useMemo, useState, type ChangeEvent, type FormEvent } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import financeService from '../services/finance';
import type {
  AccountType,
  BankAccount,
  CreateBankAccountPayload,
  UpdateBankAccountPayload,
} from '../types/finance';

type Feedback =
  | { type: 'success'; message: string }
  | { type: 'error'; message: string }
  | null;

const accountTypeLabels: Record<AccountType, string> = {
  CHECKING: 'Conta corrente',
  SAVINGS: 'Conta poupança',
  INVESTMENT: 'Investimento',
  CREDIT_CARD: 'Cartão de crédito',
};

interface BankAccountFormState {
  institutionName: string;
  branchNumber: string;
  accountNumber: string;
  accountDigit: string;
  accountType: AccountType;
  nickname: string;
  initialBalance: string;
}

const defaultFormState: BankAccountFormState = {
  institutionName: '',
  branchNumber: '',
  accountNumber: '',
  accountDigit: '',
  accountType: 'CHECKING',
  nickname: '',
  initialBalance: '',
};

const BankAccounts = () => {
  const [formData, setFormData] = useState<BankAccountFormState>(defaultFormState);
  const [accounts, setAccounts] = useState<BankAccount[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoadingAccounts, setIsLoadingAccounts] = useState(false);
  const [feedback, setFeedback] = useState<Feedback>(null);
  const [editingAccountId, setEditingAccountId] = useState<string | null>(null);
  const [processingAccountId, setProcessingAccountId] = useState<string | null>(null);

  const accountTypes = useMemo(() => Object.keys(accountTypeLabels) as AccountType[], []);

  const loadAccounts = async () => {
    setIsLoadingAccounts(true);
    try {
      const data = await financeService.listBankAccounts();
      setAccounts(data);
    } catch (error) {
      console.error('Erro ao listar contas bancárias:', error);
      setFeedback({ type: 'error', message: 'Não foi possível carregar suas contas bancárias.' });
    } finally {
      setIsLoadingAccounts(false);
    }
  };

  useEffect(() => {
    void loadAccounts();
  }, []);

  const normalizeCurrencyInput = (value: string) => {
    const cleaned = value.replace(/[^0-9.,-]/g, '');
    const isNegative = cleaned.startsWith('-');
    const unsigned = cleaned.replace(/-/g, '');
    const hasComma = unsigned.includes(',');
    const hasDot = unsigned.includes('.');

    let normalized = unsigned;
    if (hasComma && hasDot) {
      normalized = unsigned.replace(/\./g, '').replace(',', '.');
    } else if (hasComma) {
      normalized = unsigned.replace(',', '.');
    }

    return isNegative ? `-${normalized}` : normalized;
  };

  const handleChange = (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = event.target;
    setFormData((prev) => ({
      ...prev,
      [name]:
        name === 'branchNumber' || name === 'accountNumber' || name === 'accountDigit'
          ? value.replace(/[^0-9a-zA-Z]/g, '').toUpperCase()
          : name === 'initialBalance'
            ? normalizeCurrencyInput(value)
            : value,
    }));
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setIsSubmitting(true);
    setFeedback(null);

    const commonPayload = {
      institutionName: formData.institutionName.trim(),
      branchNumber: formData.branchNumber.trim(),
      accountNumber: formData.accountNumber.trim(),
      accountDigit: formData.accountDigit.trim() || undefined,
      accountType: formData.accountType,
      nickname: formData.nickname.trim() || undefined,
    } satisfies Omit<CreateBankAccountPayload, 'initialBalance'>;

    try {
      if (editingAccountId) {
        const updatePayload: UpdateBankAccountPayload = commonPayload;
        await financeService.updateBankAccount(editingAccountId, updatePayload);
        setFeedback({ type: 'success', message: 'Conta bancária atualizada com sucesso.' });
      } else {
        const payload: CreateBankAccountPayload = {
          ...commonPayload,
          initialBalance: formData.initialBalance ? Number(formData.initialBalance) : undefined,
        };
        await financeService.createBankAccount(payload);
        setFeedback({ type: 'success', message: 'Conta bancária cadastrada com sucesso.' });
      }
      setFormData(defaultFormState);
      setEditingAccountId(null);
      await loadAccounts();
    } catch (error: any) {
      console.error('Erro ao cadastrar conta bancária:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível salvar a conta bancária.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEdit = (account: BankAccount) => {
    setEditingAccountId(account.id);
    setFormData({
      institutionName: account.institutionName,
      branchNumber: account.branchNumber,
      accountNumber: account.accountNumber,
      accountDigit: account.accountDigit ?? '',
      accountType: account.accountType,
      nickname: account.nickname ?? '',
      initialBalance: '',
    });
    setFeedback(null);
  };

  const handleDelete = async (account: BankAccount) => {
    const confirmed = window.confirm(
      `Excluir a conta "${account.nickname || account.institutionName}"? Esta ação não pode ser desfeita.`
    );
    if (!confirmed) {
      return;
    }

    setProcessingAccountId(account.id);
    setFeedback(null);

    try {
      await financeService.deleteBankAccount(account.id);
      setFeedback({ type: 'success', message: 'Conta bancária removida com sucesso.' });
      if (editingAccountId === account.id) {
        setEditingAccountId(null);
        setFormData(defaultFormState);
      }
      await loadAccounts();
    } catch (error: any) {
      console.error('Erro ao excluir conta bancária:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível remover a conta bancária.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setProcessingAccountId(null);
    }
  };

  return (
    <section className="space-y-6">
      <div className="rounded-3xl bg-white p-8 shadow-lg shadow-orange-100/50">
        <div className="border-b border-orange-100 pb-4">
          <h2 className="text-2xl font-semibold text-gray-900">Contas bancárias</h2>
          <p className="text-sm text-gray-500">
            Cadastre suas contas para acompanhar saldos e movimentações.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-6">
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            <div className="space-y-2 md:col-span-2">
              <label className="text-sm font-medium text-gray-700">Instituição financeira</label>
              <input
                type="text"
                name="institutionName"
                value={formData.institutionName}
                onChange={handleChange}
                required
                placeholder="Banco do Brasil, Nubank, Itaú..."
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Agência</label>
              <input
                type="text"
                name="branchNumber"
                value={formData.branchNumber}
                onChange={handleChange}
                required
                placeholder="0001"
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Conta</label>
              <input
                type="text"
                name="accountNumber"
                value={formData.accountNumber}
                onChange={handleChange}
                required
                placeholder="123456"
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Dígito</label>
              <input
                type="text"
                name="accountDigit"
                value={formData.accountDigit}
                onChange={handleChange}
                placeholder="0-0"
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Tipo de conta</label>
              <select
                name="accountType"
                value={formData.accountType}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                {accountTypes.map((type) => (
                  <option key={type} value={type}>
                    {accountTypeLabels[type]}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Apelido (opcional)</label>
              <input
                type="text"
                name="nickname"
                value={formData.nickname}
                onChange={handleChange}
                placeholder="Conta salário, investimentos..."
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            {!editingAccountId && (
              <div className="space-y-2">
                <label className="text-sm font-medium text-gray-700">Saldo inicial</label>
                <input
                  type="number"
                  inputMode="decimal"
                  step="0.01"
                  name="initialBalance"
                  value={formData.initialBalance}
                  onChange={handleChange}
                  placeholder="0.00"
                  className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
                />
              </div>
            )}
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

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={isSubmitting}
              className="rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-8 py-3 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:from-orange-600 hover:to-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSubmitting
                ? editingAccountId
                  ? 'Atualizando...'
                  : 'Cadastrando...'
                : editingAccountId
                ? 'Atualizar conta'
                : 'Cadastrar conta'}
            </button>
            {editingAccountId && (
              <button
                type="button"
                onClick={() => {
                  setEditingAccountId(null);
                  setFormData(defaultFormState);
                }}
                className="ml-3 rounded-2xl border border-orange-200 px-6 py-3 text-sm font-semibold text-orange-500 transition hover:bg-orange-50"
              >
                Cancelar edição
              </button>
            )}
          </div>
        </form>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        {isLoadingAccounts ? (
          <div className="md:col-span-2 flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-orange-100 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Carregando suas contas bancárias...
          </div>
        ) : accounts.length === 0 ? (
          <div className="md:col-span-2 flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-dashed border-orange-200 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Nenhuma conta cadastrada ainda. Utilize o formulário acima para adicionar sua primeira
            conta.
          </div>
        ) : (
          accounts.map((account) => (
            <div
              key={account.id}
              className="rounded-3xl border border-orange-100 bg-white p-6 shadow-md shadow-orange-100/30 transition hover:shadow-lg hover:shadow-orange-100/60"
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center justify-between gap-4">
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900">
                        {account.nickname || account.institutionName}
                      </h3>
                      <p className="text-sm text-gray-500">
                        {account.institutionName} &bull; Agência {account.branchNumber} &bull; Conta{' '}
                        {account.accountNumber}
                        {account.accountDigit && `-${account.accountDigit}`}
                      </p>
                    </div>
                    <span className="inline-flex items-center justify-center rounded-full bg-orange-100 px-3 py-1 text-center text-xs font-semibold uppercase text-orange-600">
                      {accountTypeLabels[account.accountType]}
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => handleEdit(account)}
                    className="rounded-full border border-orange-100 p-2 text-orange-500 transition hover:bg-orange-50"
                    title="Editar conta"
                  >
                    <Pencil className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => handleDelete(account)}
                    className="rounded-full border border-red-100 p-2 text-red-500 transition hover:bg-red-50"
                    title="Excluir conta"
                    disabled={processingAccountId === account.id}
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>

              <div className="mt-4 flex items-center justify-between">
                <div>
                  <p className="text-xs font-medium uppercase tracking-wide text-gray-400">
                    Saldo atual
                  </p>
                  <p className="text-2xl font-semibold text-gray-900">
                    {account.currentBalance.toLocaleString('pt-BR', {
                      style: 'currency',
                      currency: 'BRL',
                    })}
                  </p>
                </div>
              </div>
              {processingAccountId === account.id && (
                <p className="mt-3 text-xs text-red-500">Processando exclusão...</p>
              )}
            </div>
          ))
        )}
      </div>
    </section>
  );
};

export default BankAccounts;
