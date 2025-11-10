package com.dashboard_financeiro.notificacoes.infrastructure.resend;

public class ResendEmailException extends RuntimeException {

    public ResendEmailException(String message) {
        super(message);
    }

    public ResendEmailException(String message, Throwable cause) {
        super(message, cause);
    }
}
