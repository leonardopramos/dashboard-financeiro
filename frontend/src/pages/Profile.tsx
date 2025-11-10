import { useEffect, useState, type ChangeEvent, type FormEvent } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { authService } from '../services/api';
import type { UpdateUserRequest } from '../types/auth';
import { formatCep, formatCpf, onlyDigits } from '../utils/format';

type FeedbackState =
  | { type: 'success'; message: string }
  | { type: 'error'; message: string }
  | { type: 'info'; message: string }
  | null;

interface ProfileFormState {
  name: string;
  cpf: string;
  street: string;
  number: string;
  neighborhood: string;
  complement: string;
  city: string;
  state: string;
  zipCode: string;
}

const Profile = () => {
  const { user, refreshUser, logout } = useAuth();
  const [formData, setFormData] = useState<ProfileFormState>({
    name: '',
    cpf: '',
    street: '',
    number: '',
    neighborhood: '',
    complement: '',
    city: '',
    state: '',
    zipCode: '',
  });
  const [feedback, setFeedback] = useState<FeedbackState>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isFetchingCep, setIsFetchingCep] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    if (user) {
      setFormData({
        name: user.name ?? '',
        cpf: formatCpf(user.cpf ?? ''),
        street: user.street ?? '',
        number: user.number ? String(user.number) : '',
        neighborhood: user.neighborhood ?? '',
        complement: user.complement ?? '',
        city: user.city ?? '',
        state: user.state ?? '',
        zipCode: formatCep(user.zipCode ?? ''),
      });
    }
  }, [user]);

  const handleCepLookup = async () => {
    const cepDigits = onlyDigits(formData.zipCode);
    if (cepDigits.length !== 8) {
      setFeedback({ type: 'error', message: 'Informe um CEP válido com 8 dígitos.' });
      return;
    }

    setIsFetchingCep(true);
    setFeedback({ type: 'info', message: 'Consultando endereço na base ViaCEP...' });

    try {
      const response = await fetch(`https://viacep.com.br/ws/${cepDigits}/json/`);
      const data = await response.json();

      if (data.erro) {
        throw new Error('CEP não encontrado');
      }

      setFormData((prev) => ({
        ...prev,
        street: data.logradouro ?? prev.street,
        neighborhood: data.bairro ?? prev.neighborhood,
        city: data.localidade ?? prev.city,
        state: data.uf ?? prev.state,
      }));

      setFeedback({ type: 'success', message: 'Endereço preenchido automaticamente com sucesso!' });
    } catch (error) {
      console.error('Erro ao consultar CEP:', error);
      setFeedback({ type: 'error', message: 'Não foi possível localizar o CEP informado.' });
    } finally {
      setIsFetchingCep(false);
    }
  };

  const handleChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;

    setFormData((prev) => {
      if (name === 'cpf') {
        return { ...prev, cpf: formatCpf(value) };
      }

      if (name === 'zipCode') {
        return { ...prev, zipCode: formatCep(value) };
      }

      if (name === 'number') {
        const digits = value.replace(/\D/g, '');
        return { ...prev, number: digits };
      }

      return { ...prev, [name]: value };
    });
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    if (!user) {
      return;
    }

    setIsSaving(true);
    setFeedback(null);

    const payload: UpdateUserRequest = {
      name: formData.name.trim(),
      cpf: onlyDigits(formData.cpf),
      street: formData.street.trim() || undefined,
      number: formData.number ? Number(formData.number) : undefined,
      neighborhood: formData.neighborhood.trim() || undefined,
      complement: formData.complement.trim() || undefined,
      city: formData.city.trim() || undefined,
      state: formData.state.trim() || undefined,
      zipCode: onlyDigits(formData.zipCode) || undefined,
    };

    try {
      await authService.updateUser(user.id, payload);
      await refreshUser();
      setFeedback({ type: 'success', message: 'Dados atualizados com sucesso.' });
    } catch (error: any) {
      console.error('Erro ao atualizar perfil:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível salvar as alterações.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setIsSaving(false);
    }
  };

  const handleDeleteAccount = async () => {
    if (!user) {
      return;
    }

    const confirmed = window.confirm(
      'Tem certeza de que deseja excluir sua conta? Essa ação é permanente e não pode ser desfeita.'
    );

    if (!confirmed) {
      return;
    }

    setIsDeleting(true);
    setFeedback(null);

    try {
      await authService.deleteUser(user.id);
      logout();
    } catch (error: any) {
      console.error('Erro ao excluir perfil:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível excluir seu perfil no momento.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <section className="space-y-6">
      <div className="rounded-3xl bg-white p-8 shadow-lg shadow-orange-100/50">
        <div className="border-b border-orange-100 pb-4">
          <h2 className="text-2xl font-semibold text-gray-900">Perfil</h2>
          <p className="text-sm text-gray-500">
            Atualize seus dados pessoais e de endereço para manter sua conta sempre em dia.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-6">
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Nome completo</label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">CPF</label>
              <input
                type="text"
                name="cpf"
                value={formData.cpf}
                onChange={handleChange}
                placeholder="000.000.000-00"
                required
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">CEP</label>
              <div className="flex gap-3">
                <input
                  type="text"
                  name="zipCode"
                  value={formData.zipCode}
                  onChange={handleChange}
                  onBlur={handleCepLookup}
                  placeholder="00000-000"
                  className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
                />
                <button
                  type="button"
                  onClick={handleCepLookup}
                  disabled={isFetchingCep}
                  className="rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:from-orange-600 hover:to-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  {isFetchingCep ? 'Buscando...' : 'Buscar'}
                </button>
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Rua</label>
              <input
                type="text"
                name="street"
                value={formData.street}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Número</label>
              <input
                type="text"
                name="number"
                value={formData.number}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Bairro</label>
              <input
                type="text"
                name="neighborhood"
                value={formData.neighborhood}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Complemento</label>
              <input
                type="text"
                name="complement"
                value={formData.complement}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Cidade</label>
              <input
                type="text"
                name="city"
                value={formData.city}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Estado</label>
              <input
                type="text"
                name="state"
                value={formData.state}
                onChange={handleChange}
                maxLength={2}
                className="uppercase tracking-widest w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>
          </div>

          {feedback && (
            <div
              className={`rounded-2xl border px-4 py-3 text-sm font-medium ${
                feedback.type === 'success'
                  ? 'border-green-200 bg-green-50 text-green-700'
                  : feedback.type === 'error'
                  ? 'border-red-200 bg-red-50 text-red-600'
                  : 'border-orange-200 bg-orange-50 text-orange-600'
              }`}
            >
              {feedback.message}
            </div>
          )}

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={isSaving}
              className="rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-8 py-3 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:from-orange-600 hover:to-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSaving ? 'Salvando...' : 'Salvar alterações'}
            </button>
          </div>
        </form>
      </div>

      <div className="rounded-3xl border border-red-100 bg-white p-6 shadow-lg shadow-red-100/50">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Encerrar conta</h3>
            <p className="text-sm text-gray-500">
              A exclusão é permanente e removerá todos os seus dados deste ambiente.
            </p>
          </div>
          <button
            type="button"
            onClick={handleDeleteAccount}
            disabled={isDeleting}
            className="rounded-2xl border border-red-200 px-6 py-3 text-sm font-semibold text-red-600 shadow-sm transition hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {isDeleting ? 'Excluindo...' : 'Excluir conta'}
          </button>
        </div>
      </div>
    </section>
  );
};

export default Profile;
