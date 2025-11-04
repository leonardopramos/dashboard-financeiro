import { useEffect, useMemo, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { authService, PENDING_EMAIL_KEY } from '../../services/api';

const VerifyEmail = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const state = location.state as { email?: string; name?: string } | null;
  const initialEmail = state?.email ?? sessionStorage.getItem(PENDING_EMAIL_KEY) ?? '';
  const firstName = useMemo(() => {
    const nameSource = state?.name ?? '';
    if (!nameSource) {
      return 'Usuário';
    }
    const trimmed = nameSource.trim();
    const spaceIndex = trimmed.indexOf(' ');
    return spaceIndex > 0 ? trimmed.substring(0, spaceIndex) : trimmed;
  }, [state?.name]);

  const [email, setEmail] = useState(initialEmail);
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isResending, setIsResending] = useState(false);

  useEffect(() => {
    if (initialEmail) {
      sessionStorage.setItem(PENDING_EMAIL_KEY, initialEmail);
    }
  }, [initialEmail]);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError('');
    setSuccess('');

    const trimmedEmail = email.trim().toLowerCase();
    const trimmedCode = code.trim();

    if (!trimmedEmail || !trimmedCode) {
      setError('Informe seu e-mail e o código recebido.');
      return;
    }

    try {
      setIsSubmitting(true);
      await authService.verifyEmail({ email: trimmedEmail, code: trimmedCode });
      sessionStorage.removeItem(PENDING_EMAIL_KEY);
      setSuccess('E-mail verificado com sucesso! Redirecionando para o login...');
      setTimeout(() => {
        navigate('/login', {
          replace: true,
          state: { email: trimmedEmail, verified: true },
        });
      }, 1800);
    } catch (err: any) {
      const detail = err.response?.data?.detail ?? err.response?.data?.message ?? 'Não foi possível verificar o e-mail.';
      setError(detail);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleResend = async () => {
    setError('');
    setSuccess('');

    const trimmedEmail = email.trim().toLowerCase();
    if (!trimmedEmail) {
      setError('Informe um e-mail válido para reenviar o código.');
      return;
    }

    try {
      setIsResending(true);
      const message = await authService.resendVerification({ email: trimmedEmail });
      sessionStorage.setItem(PENDING_EMAIL_KEY, trimmedEmail);
      setSuccess(message ?? 'Novo código enviado com sucesso!');
    } catch (err: any) {
      const detail = err.response?.data?.detail ?? err.response?.data?.message ?? 'Não foi possível reenviar o código.';
      setError(detail);
    } finally {
      setIsResending(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full border border-gray-200 relative overflow-hidden">
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-orange-500 to-orange-400 rounded-t-3xl"></div>

        <div className="p-10 text-center mb-2">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-400 rounded-2xl text-white mb-6 shadow-lg text-2xl">
            📬
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Confirme seu e-mail</h1>
          <p className="text-gray-600 text-base">
            Enviamos um código de verificação para <strong className="text-orange-500">{email || 'seu e-mail'}</strong>.
          </p>
          <p className="text-sm text-gray-500 mt-2">Olá, {firstName}! Digite o código de 6 dígitos para ativar sua conta.</p>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-600 px-3 py-2 rounded-lg mb-4 text-sm mx-10">
            {error}
          </div>
        )}

        {success && (
          <div className="bg-green-50 border border-green-200 text-green-700 px-3 py-2 rounded-lg mb-4 text-sm mx-10">
            {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5 px-10 pb-4">
          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">E-mail</label>
            <input
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="seu-email@exemplo.com"
              required
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-base transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">Código de verificação</label>
            <input
              type="text"
              value={code}
              onChange={(event) => setCode(event.target.value.replace(/\D/g, '').slice(0, 6))}
              placeholder="000000"
              required
              inputMode="numeric"
              maxLength={6}
              className="w-full tracking-widest text-center text-xl px-4 py-3 border-2 border-gray-200 rounded-xl transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full py-3.5 px-6 bg-gradient-to-r from-orange-500 to-orange-400 text-white border-none rounded-xl text-base font-semibold cursor-pointer shadow-md hover:shadow-lg transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSubmitting ? 'Verificando...' : 'Verificar e-mail'}
          </button>
        </form>

        <div className="px-10 pb-6">
          <button
            type="button"
            onClick={handleResend}
            disabled={isResending}
            className="w-full py-3 px-6 border-2 border-orange-200 text-orange-500 rounded-xl text-sm font-semibold bg-orange-50/60 hover:bg-orange-100 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isResending ? 'Reenviando...' : 'Reenviar código'}
          </button>
          <p className="text-xs text-gray-500 mt-3 text-center">
            Verifique também a caixa de spam ou lixo eletrônico.
          </p>
        </div>

        <div className="text-center mt-4 pt-4 border-t border-gray-200 px-10 pb-8">
          <p className="text-gray-600 text-sm">
            Já confirmou o e-mail?{' '}
            <Link to="/login" className="text-orange-500 no-underline font-medium hover:text-orange-600 transition-colors">
              Entrar na minha conta
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default VerifyEmail;

