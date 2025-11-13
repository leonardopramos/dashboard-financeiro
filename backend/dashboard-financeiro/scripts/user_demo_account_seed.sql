/*
    Script para cadastrar contas bancárias iniciais do usuário de demonstração.

    Ajuste @UserId caso queira reaproveitar o arquivo para outro usuário.
    Requisitos:
      - MySQL 8+ (usa UUID_TO_BIN/BIN_TO_UUID)
      - Banco `dashboard_financeiro` já criado pela infraestrutura do projeto

    Execução recomendada:
        mysql -u root -p < backend/dashboard-financeiro/scripts/user_demo_account_seed.sql
*/

USE dashboard_financeiro;

SET @UserId = UUID_TO_BIN('9d329bc3-24ac-4cfa-81b0-1de71f4afa63'); -- Perfil Demonstração
SET @Now = UTC_TIMESTAMP(6);

/*
    Caso esteja reaplicando o seed e já existam contas, remova o comentário abaixo para
    limpar previamente. Mantenha comentado para evitar exclusões acidentais.
*/
-- DELETE FROM bank_accounts WHERE user_id = @UserId;

START TRANSACTION;

    /* Identificadores fixados para facilitar referência nas próximas etapas */
    SET @CheckingAccountId  = UUID_TO_BIN(UUID());
    SET @SavingsAccountId   = UUID_TO_BIN(UUID());
    SET @CreditCardAccountId= UUID_TO_BIN(UUID());

    INSERT INTO bank_accounts (
        id,
        user_id,
        institution_name,
        branch_number,
        account_number,
        account_digit,
        account_type,
        nickname,
        current_balance,
        created_at,
        updated_at
    )
    VALUES
        (
            @CheckingAccountId,
            @UserId,
            'Banco Horizonte',
            '0101',
            '458921',
            '3',
            'CHECKING',
            'Conta Movimento',
            12840.55,
            DATE_SUB(CAST(@Now AS DATETIME), INTERVAL 18 MONTH),
            @Now
        ),
        (
            @SavingsAccountId,
            @UserId,
            'Banco Horizonte',
            '0101',
            '880045',
            '4',
            'SAVINGS',
            'Poupanca Objetivos',
            36580.20,
            DATE_SUB(CAST(@Now AS DATETIME), INTERVAL 17 MONTH),
            @Now
        ),
        (
            @CreditCardAccountId,
            @UserId,
            'Banco Horizonte',
            '0101',
            '990067',
            '0',
            'CREDIT_CARD',
            'Cartao Vision',
            -3820.40,
            DATE_SUB(CAST(@Now AS DATETIME), INTERVAL 17 MONTH),
            @Now
        );

COMMIT;

/* Retorna os identificadores para uso nas próximas etapas (categorias, transações etc.) */
SELECT
    'CHECKING' AS account_type,
    'Conta Movimento' AS nickname,
    BIN_TO_UUID(@CheckingAccountId) AS account_id;

SELECT
    'SAVINGS' AS account_type,
    'Poupanca Objetivos' AS nickname,
    BIN_TO_UUID(@SavingsAccountId) AS account_id;

SELECT
    'CREDIT_CARD' AS account_type,
    'Cartao Vision' AS nickname,
    BIN_TO_UUID(@CreditCardAccountId) AS account_id;
