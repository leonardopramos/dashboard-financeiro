import { useEffect, useMemo, useRef, useState, type ChangeEvent, type FormEvent } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import financeService from '../services/finance';
import type {
  Category,
  CategoryType,
  CreateCategoryPayload,
  UpdateCategoryPayload,
} from '../types/finance';

type Feedback =
  | { type: 'success'; message: string }
  | { type: 'error'; message: string }
  | null;

const categoryTypeLabels: Record<CategoryType, string> = {
  INCOME: 'Receita',
  EXPENSE: 'Despesa',
  TRANSFER: 'Transferência',
};

interface CategoryFormState {
  name: string;
  type: CategoryType;
  color: string;
  icon: string;
  active: boolean;
}

const defaultFormState: CategoryFormState = {
  name: '',
  type: 'EXPENSE',
  color: '',
  icon: '',
  active: true,
};

const DEFAULT_CATEGORY_COLOR = '#FF6B35';
const BASE_ICON_CHOICES = ['💰', '🍽️', '🛒', '🚗', '🏠', '🎉', '🏥', '📚', '💡', '✈️', '🏋️'];

const ICON_STORAGE_PREFIX = 'emoji:';

const isAscii = (value: string) => /^[\x00-\x7F]*$/.test(value);

const serializeIcon = (icon: string): string | undefined => {
  const trimmed = icon.trim();
  if (!trimmed) {
    return undefined;
  }
  if (isAscii(trimmed)) {
    return trimmed;
  }
  return `${ICON_STORAGE_PREFIX}${encodeURIComponent(trimmed)}`;
};

const deserializeIcon = (icon?: string | null): string => {
  if (!icon) {
    return '';
  }
  if (icon.startsWith(ICON_STORAGE_PREFIX)) {
    try {
      return decodeURIComponent(icon.slice(ICON_STORAGE_PREFIX.length));
    } catch (error) {
      console.warn('Não foi possível decodificar ícone armazenado:', icon, error);
      return '';
    }
  }
  if (icon === '??' || icon.startsWith('mdi-')) {
    return '';
  }
  return icon;
};

const isLikelyEmoji = (value: string) => /\p{Extended_Pictographic}/u.test(value);

const getIconForDisplay = (icon: string | undefined, name: string) => {
  const decoded = deserializeIcon(icon);
  if (decoded && isLikelyEmoji(decoded)) {
    return decoded;
  }
  return name.charAt(0).toUpperCase();
};

const Categories = () => {
  const [formData, setFormData] = useState<CategoryFormState>(defaultFormState);
  const [categories, setCategories] = useState<Category[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [feedback, setFeedback] = useState<Feedback>(null);
  const [editingCategoryId, setEditingCategoryId] = useState<string | null>(null);
  const [processingCategoryId, setProcessingCategoryId] = useState<string | null>(null);
  const [isIconPickerOpen, setIsIconPickerOpen] = useState(false);
  const colorInputRef = useRef<HTMLInputElement | null>(null);

  const categoryTypes = useMemo(() => Object.keys(categoryTypeLabels) as CategoryType[], []);
  const iconOptions = useMemo(() => {
    if (formData.icon && isLikelyEmoji(formData.icon) && !BASE_ICON_CHOICES.includes(formData.icon)) {
      return [formData.icon, ...BASE_ICON_CHOICES];
    }
    return BASE_ICON_CHOICES;
  }, [formData.icon]);

  const loadCategories = async () => {
    setIsLoading(true);
    try {
      const data = await financeService.listCategories();
      const normalizedCategories = data.map((category) => ({
        ...category,
        icon: deserializeIcon(category.icon),
      }));
      setCategories(normalizedCategories);
    } catch (error) {
      console.error('Erro ao listar categorias:', error);
      setFeedback({
        type: 'error',
        message: 'Não foi possível carregar suas categorias. Tente novamente em instantes.',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    void loadCategories();
  }, []);

  const handleChange = (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = event.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleCheckboxChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { checked } = event.target;
    setFormData((prev) => ({
      ...prev,
      active: checked,
    }));
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setIsSubmitting(true);
    setFeedback(null);

    try {
      if (editingCategoryId) {
        const payload: UpdateCategoryPayload = {
          name: formData.name.trim(),
          type: formData.type,
          color: formData.color ? formData.color : undefined,
          icon: serializeIcon(formData.icon),
          active: formData.active,
        };
        await financeService.updateCategory(editingCategoryId, payload);
        setFeedback({ type: 'success', message: 'Categoria atualizada com sucesso.' });
      } else {
        const payload: CreateCategoryPayload = {
          name: formData.name.trim(),
          type: formData.type,
          color: formData.color ? formData.color : undefined,
          icon: serializeIcon(formData.icon),
        };
        await financeService.createCategory(payload);
        setFeedback({ type: 'success', message: 'Categoria cadastrada com sucesso.' });
      }
      setFormData(defaultFormState);
      setEditingCategoryId(null);
      await loadCategories();
    } catch (error: any) {
      console.error('Erro ao cadastrar categoria:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível salvar a categoria.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEdit = (category: Category) => {
    setEditingCategoryId(category.id);
    setFormData({
      name: category.name,
      type: category.type,
      color: category.color ?? '',
      icon: deserializeIcon(category.icon),
      active: category.active,
    });
    setFeedback(null);
  };

  const handleDelete = async (category: Category) => {
    const confirmed = window.confirm(
      `Excluir a categoria "${category.name}"? Transações existentes não serão removidas automaticamente.`
    );
    if (!confirmed) {
      return;
    }

    setProcessingCategoryId(category.id);
    setFeedback(null);
    try {
      await financeService.deleteCategory(category.id);
      setFeedback({ type: 'success', message: 'Categoria removida com sucesso.' });
      if (editingCategoryId === category.id) {
        setEditingCategoryId(null);
        setFormData(defaultFormState);
      }
      await loadCategories();
    } catch (error: any) {
      console.error('Erro ao excluir categoria:', error);
      const detail =
        error.response?.data?.detail ??
        error.response?.data?.message ??
        'Não foi possível remover a categoria.';
      setFeedback({ type: 'error', message: detail });
    } finally {
      setProcessingCategoryId(null);
    }
  };

  const handleColorChange = (color: string) => {
    setFormData((prev) => ({
      ...prev,
      color,
    }));
  };

  const handleIconSelect = (icon: string) => {
    setFormData((prev) => ({
      ...prev,
      icon,
    }));
    setIsIconPickerOpen(false);
  };

  const resolveColor = (color?: string) => {
    if (!color) {
      return DEFAULT_CATEGORY_COLOR;
    }
    return color;
  };

  return (
    <section className="space-y-6">
      <div className="rounded-3xl bg-white p-8 shadow-lg shadow-orange-100/50">
        <div className="border-b border-orange-100 pb-4">
          <h2 className="text-2xl font-semibold text-gray-900">Categorias</h2>
          <p className="text-sm text-gray-500">
            Organize receitas, despesas e transferências criando categorias personalizadas.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-6 space-y-6">
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Nome</label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                maxLength={80}
                placeholder="Alimentação, Salário, Transporte..."
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 shadow-inner shadow-orange-100 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Tipo</label>
              <select
                name="type"
                value={formData.type}
                onChange={handleChange}
                className="w-full rounded-2xl border border-orange-100 bg-orange-50/50 px-4 py-3 text-sm font-medium text-gray-900 focus:border-orange-400 focus:outline-none focus:ring-2 focus:ring-orange-200"
              >
                {categoryTypes.map((type) => (
                  <option key={type} value={type}>
                    {categoryTypeLabels[type]}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Cor (opcional)</label>
              <div className="flex flex-wrap items-center gap-3">
                <button
                  type="button"
                  onClick={() => colorInputRef.current?.click()}
                  className="inline-flex items-center gap-2 rounded-2xl border border-orange-100 bg-white px-4 py-2 text-sm font-semibold text-orange-500 transition hover:border-orange-200 hover:text-orange-600"
                >
                  <span
                    className="h-6 w-6 rounded-full border border-orange-100"
                    style={{ backgroundColor: resolveColor(formData.color) }}
                    aria-hidden
                  />
                  Escolher cor
                </button>
                <input
                  ref={colorInputRef}
                  type="color"
                  className="sr-only"
                  value={formData.color || DEFAULT_CATEGORY_COLOR}
                  onChange={(event) => handleColorChange(event.target.value)}
                />
                {formData.color ? (
                  <span className="text-sm font-medium text-gray-600">
                    {formData.color.toUpperCase()}
                  </span>
                ) : (
                  <span className="text-sm text-gray-500">Nenhuma cor selecionada</span>
                )}
                {formData.color && (
                  <button
                    type="button"
                    onClick={() => handleColorChange('')}
                    className="text-xs font-semibold text-gray-500 underline decoration-dotted underline-offset-4 transition hover:text-gray-700"
                  >
                    Remover cor
                  </button>
                )}
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-gray-700">Ícone (opcional)</label>
              <div className="flex flex-wrap items-center gap-3">
                <button
                  type="button"
                  onClick={() => setIsIconPickerOpen((prev) => !prev)}
                  className={`inline-flex items-center gap-2 rounded-2xl border px-4 py-2 text-sm font-semibold transition ${
                    isIconPickerOpen
                      ? 'border-orange-400 bg-orange-50 text-orange-600 shadow-inner shadow-orange-100'
                      : 'border-orange-100 bg-white text-orange-500 hover:border-orange-200 hover:text-orange-600'
                  }`}
                >
                  {formData.icon ? (
                    <>
                      <span className="flex h-6 w-6 items-center justify-center rounded-full bg-orange-50 text-base">
                        {formData.icon}
                      </span>
                      {isIconPickerOpen ? 'Fechar seleção' : 'Trocar ícone'}
                    </>
                  ) : (
                    <>{isIconPickerOpen ? 'Fechar seleção' : 'Adicionar ícone'}</>
                  )}
                </button>
                <button
                  type="button"
                  onClick={() => handleIconSelect('')}
                  className={`rounded-2xl border px-4 py-2 text-sm font-medium transition ${
                    !formData.icon
                      ? 'border-orange-400 bg-orange-50 text-orange-600 shadow-inner shadow-orange-100'
                      : 'border-orange-100 bg-white text-gray-600 hover:border-orange-200 hover:text-orange-500'
                  }`}
                >
                  Sem ícone
                </button>
              </div>
              {isIconPickerOpen && (
                <div className="rounded-3xl border border-orange-100 bg-white p-4 shadow-lg shadow-orange-100/60">
                  <div className="pb-3">
                    <h4 className="text-sm font-semibold text-gray-700">Selecione um ícone</h4>
                  </div>
                  <div className="grid grid-cols-4 gap-3 md:grid-cols-6">
                    {iconOptions.map((iconOption) => {
                      const isSelected = formData.icon === iconOption;
                      return (
                        <button
                          key={iconOption}
                          type="button"
                          onClick={() => handleIconSelect(iconOption)}
                          className={`flex h-12 w-12 items-center justify-center rounded-2xl border text-lg transition ${
                            isSelected
                              ? 'border-orange-400 bg-orange-50 shadow-inner shadow-orange-100'
                              : 'border-orange-100 bg-white text-gray-600 hover:border-orange-200 hover:bg-orange-50/70'
                          }`}
                          aria-pressed={isSelected}
                        >
                          <span>{iconOption}</span>
                        </button>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>

            <div className="flex items-center gap-3 rounded-2xl border border-orange-100 bg-orange-50/60 p-4 md:col-span-2">
              <input
                id="category-active"
                type="checkbox"
                checked={formData.active}
                onChange={handleCheckboxChange}
                className="h-4 w-4 rounded border-orange-300 text-orange-500 focus:ring-orange-400"
              />
              <label htmlFor="category-active" className="text-sm font-medium text-gray-700">
                Categoria ativa
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

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={isSubmitting}
              className="rounded-2xl bg-gradient-to-r from-orange-500 to-orange-400 px-8 py-3 text-sm font-semibold text-white shadow-lg shadow-orange-200 transition hover:from-orange-600 hover:to-orange-500 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isSubmitting
                ? editingCategoryId
                  ? 'Atualizando...'
                  : 'Cadastrando...'
                : editingCategoryId
                ? 'Atualizar categoria'
                : 'Cadastrar categoria'}
            </button>
            {editingCategoryId && (
              <button
                type="button"
                onClick={() => {
                  setEditingCategoryId(null);
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
        {isLoading ? (
          <div className="md:col-span-2 flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-orange-100 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Carregando suas categorias...
          </div>
        ) : categories.length === 0 ? (
          <div className="md:col-span-2 flex min-h-[160px] w-full flex-col items-center justify-center rounded-3xl border border-dashed border-orange-200 bg-orange-50/40 p-6 text-center text-sm text-gray-600">
            Nenhuma categoria cadastrada até o momento. Utilize o formulário acima para registrar a
            primeira categoria.
          </div>
        ) : (
          categories.map((category) => (
            <div
              key={category.id}
              className="rounded-3xl border border-orange-100 bg-white p-6 shadow-md shadow-orange-100/30 transition hover:shadow-lg hover:shadow-orange-100/60"
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-center gap-3">
                  <span
                    className="flex h-12 w-12 items-center justify-center rounded-2xl text-lg font-semibold text-white shadow-inner shadow-orange-100"
                    style={{ backgroundColor: resolveColor(category.color) }}
                  >
                    {getIconForDisplay(category.icon, category.name)}
                  </span>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">{category.name}</h3>
                    <p className="text-sm text-gray-500">
                      {categoryTypeLabels[category.type]}
                      {category.color ? ` • ${category.color}` : ''}
                    </p>
                    <span
                      className={`mt-2 inline-block rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-wide ${
                        category.active ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-600'
                      }`}
                    >
                      {category.active ? 'Ativa' : 'Inativa'}
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => handleEdit(category)}
                    className="rounded-full border border-orange-100 p-2 text-orange-500 transition hover:bg-orange-50"
                    title="Editar categoria"
                  >
                    <Pencil className="h-4 w-4" />
                  </button>
                  <button
                    type="button"
                    onClick={() => handleDelete(category)}
                    className="rounded-full border border-red-100 p-2 text-red-500 transition hover:bg-red-50"
                    title="Excluir categoria"
                    disabled={processingCategoryId === category.id}
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>

              <div className="mt-4 text-xs text-gray-500">
                Criada em{' '}
                {new Date(category.createdAt).toLocaleDateString('pt-BR', {
                  day: '2-digit',
                  month: 'long',
                  year: 'numeric',
                })}
              </div>
              {processingCategoryId === category.id && (
                <p className="mt-3 text-xs text-red-500">Processando exclusão...</p>
              )}
            </div>
          ))
        )}
      </div>
    </section>
  );
};

export default Categories;
