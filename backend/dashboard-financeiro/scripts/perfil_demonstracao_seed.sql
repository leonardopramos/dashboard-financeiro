/*
    Script de carga para o usuário de demonstração (MySQL 8+).
    - Localiza (ou cria) o usuário "Perfil Demonstração" no serviço de cadastro/autenticação.
    - Remove dados anteriores do mesmo usuário nas tabelas financeiras.
    - Gera 12 meses completos de transações, contas, categorias, metas e contribuições.

    Execute o arquivo uma única vez após subir os bancos:
        mysql -u root -p < backend/dashboard-financeiro/scripts/perfil_demonstracao_seed.sql
*/

SET @ProvidedUserId = UUID_TO_BIN('a0db9f59-d463-4e6d-bfd3-4d560f60d72e');
SET @DemoCpfFormatted = '307.838.650-31';
SET @DemoCpfDigits = REPLACE(REPLACE(@DemoCpfFormatted, '.', ''), '-', '');
SET @DemoEmail = 'perfil.demonstracao@dashboard.local';
SET @DemoUserName = 'Perfil Demonstração';
SET @DemoPasswordHash = '$2b$12$Z0tWpKkd/d0GVeSbxWPuv.5vVkxKCe252ap5qEFUGAVWEvWdOjRR.';

USE dashboard_financeiro_cadastro_autenticacao;

SET @UserId = NULL;
SELECT @UserId := id
FROM users
WHERE cpf = @DemoCpfDigits
LIMIT 1;

SET @UserId = IFNULL(@UserId, @ProvidedUserId);

INSERT INTO users (
    id,
    cpf,
    name,
    email,
    password,
    role,
    street,
    number,
    neighborhood,
    complement,
    city,
    state,
    zip_code,
    email_verified,
    active,
    registered_at,
    updated_at
)
SELECT
    @UserId,
    @DemoCpfDigits,
    @DemoUserName,
    @DemoEmail,
    @DemoPasswordHash,
    'ADMIN',
    'Av. Dashboard',
    100,
    'Centro',
    'Sala 1205',
    'Sao Paulo',
    'SP',
    '01000-000',
    1,
    1,
    UTC_TIMESTAMP(6),
    UTC_TIMESTAMP(6)
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE cpf = @DemoCpfDigits
);

USE dashboard_financeiro;

SET @Now = UTC_TIMESTAMP(6);
SET @MonthsBack = 11; -- 0 (mês atual) + 11 meses anteriores = 12 meses de histórico
SET @MonthStart = DATE_SUB(DATE(@Now), INTERVAL (DAY(@Now) - 1) DAY);
SET @TransferSavingsBase = 1100.00;
SET @TransferSavingsDelta = -25.00;
SET @CreditPaymentBase = 1850.00;
SET @CreditPaymentDelta = -30.00;

START TRANSACTION;

    DELETE gc
    FROM goal_contributions gc
    WHERE gc.user_id = @UserId;

    DELETE FROM financial_goals
    WHERE user_id = @UserId;

    DELETE t
    FROM transactions t
    INNER JOIN bank_accounts ba ON ba.id = t.bank_account_id
    WHERE ba.user_id = @UserId;

    DELETE FROM bank_accounts
    WHERE user_id = @UserId;

    DELETE FROM categories
    WHERE user_id = @UserId;

    -- Identificadores fixados para reaproveitar nas inserções
    SET @CheckingAccountId = UUID_TO_BIN(UUID());
    SET @SavingsAccountId = UUID_TO_BIN(UUID());
    SET @CreditAccountId = UUID_TO_BIN(UUID());

    SET @CategorySalaryId = UUID_TO_BIN(UUID());
    SET @CategoryFreelanceId = UUID_TO_BIN(UUID());
    SET @CategoryInvestmentIncomeId = UUID_TO_BIN(UUID());
    SET @CategoryHousingId = UUID_TO_BIN(UUID());
    SET @CategoryGroceriesId = UUID_TO_BIN(UUID());
    SET @CategoryTransportId = UUID_TO_BIN(UUID());
    SET @CategoryDiningId = UUID_TO_BIN(UUID());
    SET @CategoryHealthId = UUID_TO_BIN(UUID());
    SET @CategoryLeisureId = UUID_TO_BIN(UUID());
    SET @CategoryTravelId = UUID_TO_BIN(UUID());
    SET @CategoryUtilitiesId = UUID_TO_BIN(UUID());
    SET @CategoryShoppingId = UUID_TO_BIN(UUID());
    SET @CategoryEducationId = UUID_TO_BIN(UUID());
    SET @CategoryTransfersId = UUID_TO_BIN(UUID());

    INSERT INTO categories (id, user_id, category_type, name, color, icon, active, created_at, updated_at)
    VALUES
        (@CategorySalaryId,          @UserId, 'INCOME',   'Salario',               '#16A34A', 'mdi-briefcase',             1, @Now, @Now),
        (@CategoryFreelanceId,       @UserId, 'INCOME',   'Consultorias',          '#22C55E', 'mdi-laptop',                1, @Now, @Now),
        (@CategoryInvestmentIncomeId,@UserId, 'INCOME',   'Rendimentos',           '#0EA5E9', 'mdi-trending-up',           1, @Now, @Now),
        (@CategoryHousingId,         @UserId, 'EXPENSE',  'Moradia',               '#F97316', 'mdi-home-city-outline',     1, @Now, @Now),
        (@CategoryGroceriesId,       @UserId, 'EXPENSE',  'Mercado',               '#EF4444', 'mdi-cart',                  1, @Now, @Now),
        (@CategoryTransportId,       @UserId, 'EXPENSE',  'Transporte',            '#6366F1', 'mdi-train-car',             1, @Now, @Now),
        (@CategoryDiningId,          @UserId, 'EXPENSE',  'Restaurantes',          '#FB7185', 'mdi-silverware-fork-knife', 1, @Now, @Now),
        (@CategoryHealthId,          @UserId, 'EXPENSE',  'Saude',                 '#DC2626', 'mdi-heart-pulse',           1, @Now, @Now),
        (@CategoryLeisureId,         @UserId, 'EXPENSE',  'Lazer',                 '#A855F7', 'mdi-party-popper',          1, @Now, @Now),
        (@CategoryTravelId,          @UserId, 'EXPENSE',  'Viagens',               '#0EA5E9', 'mdi-airplane',              1, @Now, @Now),
        (@CategoryUtilitiesId,       @UserId, 'EXPENSE',  'Servicos',              '#FBBF24', 'mdi-lightning-bolt',        1, @Now, @Now),
        (@CategoryShoppingId,        @UserId, 'EXPENSE',  'Compras',               '#EC4899', 'mdi-basket-outline',        1, @Now, @Now),
        (@CategoryEducationId,       @UserId, 'EXPENSE',  'Educacao',              '#0891B2', 'mdi-school',                1, @Now, @Now),
        (@CategoryTransfersId,       @UserId, 'TRANSFER', 'Transferencias',        '#6B7280', 'mdi-swap-horizontal',       1, @Now, @Now);

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
        (@CheckingAccountId, @UserId, 'Banco Horizonte', '0101', '450021', '1', 'CHECKING',    'Conta Movimento',      12650.75, DATE_SUB(CAST(@Now AS DATETIME), INTERVAL 18 MONTH), @Now),
        (@SavingsAccountId,  @UserId, 'Banco Horizonte', '0101', '880045', '4', 'SAVINGS',     'Poupanca Objetivos',   35850.40, DATE_SUB(CAST(@Now AS DATETIME), INTERVAL 17 MONTH), @Now),
        (@CreditAccountId,   @UserId, 'Banco Horizonte', '0101', '990067', '0', 'CREDIT_CARD', 'Cartao Vision',        -3850.27, DATE_SUB(CAST(@Now AS DATETIME), INTERVAL 17 MONTH), @Now);

    -- Transações recorrentes da conta corrente
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT 'INCOME' AS transaction_type, 'Salario CLT' AS description, @CategorySalaryId AS category_id,
               4 AS day_offset, 9800.00 AS base_amount, -45.00 AS monthly_delta, 6 AS seasonal_period, 650.00 AS seasonal_boost, 9300.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Consultorias e freelas', @CategoryFreelanceId,
               11, 1850.00, 35.00, 3, 320.00, 1200.00
        UNION ALL
        SELECT 'EXPENSE', 'Aluguel apartamento urbano', @CategoryHousingId,
               2, 3300.00, 0.00, 0, 0.00, 3300.00
        UNION ALL
        SELECT 'EXPENSE', 'Compras de mercado', @CategoryGroceriesId,
               6, 1180.00, -9.00, 4, 150.00, 950.00
        UNION ALL
        SELECT 'EXPENSE', 'Mobilidade e transporte', @CategoryTransportId,
               8, 420.00, -2.50, 0, 0.00, 300.00
        UNION ALL
        SELECT 'EXPENSE', 'Saude preventiva', @CategoryHealthId,
               13, 360.00, 6.00, 4, 110.00, 250.00
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes e cafes', @CategoryDiningId,
               17, 560.00, 5.50, 0, 0.00, 300.00
        UNION ALL
        SELECT 'EXPENSE', 'Lazer e streaming', @CategoryLeisureId,
               21, 480.00, 4.00, 0, 0.00, 280.00
        UNION ALL
        SELECT 'EXPENSE', 'Utilidades essenciais', @CategoryUtilitiesId,
               24, 640.00, 4.50, 0, 0.00, 500.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Aporte poupanca familiar', @CategoryTransfersId,
               26, @TransferSavingsBase, @TransferSavingsDelta, 0, 0.00, 750.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Pagamento fatura cartao', @CategoryTransfersId,
               27, @CreditPaymentBase, @CreditPaymentDelta, 0, 0.00, 1300.00
    )
    INSERT INTO transactions (
        id,
        bank_account_id,
        transaction_type,
        amount,
        transaction_date,
        description,
        category_id,
        notes,
        created_at,
        updated_at
    )
    SELECT
        UUID_TO_BIN(UUID()),
        @CheckingAccountId,
        generated.transaction_type,
        generated.amount,
        generated.tx_date,
        generated.description,
        generated.category_id,
        'Seed Perfil Demonstracao',
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 9 HOUR),
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 12 HOUR)
    FROM (
        SELECT
            template.transaction_type,
            template.description,
            template.category_id,
            DATE_ADD(month_window.month_start, INTERVAL template.day_offset DAY) AS tx_date,
            ROUND(
                GREATEST(
                    template.min_amount,
                    template.base_amount + (month_window.idx * template.monthly_delta) +
                    (CASE
                        WHEN template.seasonal_period > 0 AND MOD(month_window.idx, template.seasonal_period) = 0
                        THEN template.seasonal_boost
                        ELSE 0
                    END)
                ),
                2
            ) AS amount
        FROM month_window
        CROSS JOIN template
    ) AS generated;

    -- Transações recorrentes da poupança
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT 'TRANSFER_IN' AS transaction_type, 'Transferencia conta corrente' AS description, @CategoryTransfersId AS category_id,
               26 AS day_offset, @TransferSavingsBase AS base_amount, @TransferSavingsDelta AS monthly_delta, 0 AS seasonal_period, 0.00 AS seasonal_boost, 750.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Rendimento CDB mensal', @CategoryInvestmentIncomeId,
               28, 135.00, -2.50, 3, 40.00, 90.00
        UNION ALL
        SELECT 'INCOME', 'Dividendos fundos', @CategoryInvestmentIncomeId,
               9, 210.00, 4.00, 4, 90.00, 120.00
    )
    INSERT INTO transactions (
        id,
        bank_account_id,
        transaction_type,
        amount,
        transaction_date,
        description,
        category_id,
        notes,
        created_at,
        updated_at
    )
    SELECT
        UUID_TO_BIN(UUID()),
        @SavingsAccountId,
        generated.transaction_type,
        generated.amount,
        generated.tx_date,
        generated.description,
        generated.category_id,
        'Seed Perfil Demonstracao',
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 8 HOUR),
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 10 HOUR)
    FROM (
        SELECT
            template.transaction_type,
            template.description,
            template.category_id,
            DATE_ADD(month_window.month_start, INTERVAL template.day_offset DAY) AS tx_date,
            ROUND(
                GREATEST(
                    template.min_amount,
                    template.base_amount + (month_window.idx * template.monthly_delta) +
                    (CASE
                        WHEN template.seasonal_period > 0 AND MOD(month_window.idx, template.seasonal_period) = 0
                        THEN template.seasonal_boost
                        ELSE 0
                    END)
                ),
                2
            ) AS amount
        FROM month_window
        CROSS JOIN template
    ) AS generated;

    -- Resgates pontuais da poupança
    INSERT INTO transactions (
        id,
        bank_account_id,
        transaction_type,
        amount,
        transaction_date,
        description,
        category_id,
        notes,
        created_at,
        updated_at
    )
    VALUES
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 3200.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 5 DAY),  'Reserva viagem familia',          @CategoryTravelId,    'Seed Perfil Demonstracao', DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 5 DAY) AS DATETIME), INTERVAL 7 HOUR),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 5 DAY) AS DATETIME), INTERVAL 9 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 2800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH), INTERVAL 12 DAY), 'Curso especializacao',           @CategoryEducationId, 'Seed Perfil Demonstracao', DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 9 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 2500.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH), INTERVAL 18 DAY), 'Reforma domestica',             @CategoryHousingId,   'Seed Perfil Demonstracao', DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH), INTERVAL 18 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH), INTERVAL 18 DAY) AS DATETIME), INTERVAL 9 HOUR));

    -- Transações recorrentes do cartão de crédito
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT 'EXPENSE' AS transaction_type, 'Compras online e gadgets' AS description, @CategoryShoppingId AS category_id,
               8 AS day_offset, 620.00 AS base_amount, 8.00 AS monthly_delta, 3 AS seasonal_period, 180.00 AS seasonal_boost, 350.00 AS min_amount
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes no cartao', @CategoryDiningId,
               13, 430.00, 5.50, 0, 0.00, 220.00
        UNION ALL
        SELECT 'EXPENSE', 'Entretenimento e shows', @CategoryLeisureId,
               17, 520.00, 6.50, 4, 210.00, 260.00
        UNION ALL
        SELECT 'EXPENSE', 'Cursos e educacao', @CategoryEducationId,
               20, 480.00, -6.00, 2, 160.00, 220.00
        UNION ALL
        SELECT 'TRANSFER_IN', 'Pagamento recebido conta corrente', @CategoryTransfersId,
               27, @CreditPaymentBase, @CreditPaymentDelta, 0, 0.00, 1300.00
    )
    INSERT INTO transactions (
        id,
        bank_account_id,
        transaction_type,
        amount,
        transaction_date,
        description,
        category_id,
        notes,
        created_at,
        updated_at
    )
    SELECT
        UUID_TO_BIN(UUID()),
        @CreditAccountId,
        generated.transaction_type,
        generated.amount,
        generated.tx_date,
        generated.description,
        generated.category_id,
        'Seed Perfil Demonstracao',
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 11 HOUR),
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 13 HOUR)
    FROM (
        SELECT
            template.transaction_type,
            template.description,
            template.category_id,
            DATE_ADD(month_window.month_start, INTERVAL template.day_offset DAY) AS tx_date,
            ROUND(
                GREATEST(
                    template.min_amount,
                    template.base_amount + (month_window.idx * template.monthly_delta) +
                    (CASE
                        WHEN template.seasonal_period > 0 AND MOD(month_window.idx, template.seasonal_period) = 0
                        THEN template.seasonal_boost
                        ELSE 0
                    END)
                ),
                2
            ) AS amount
        FROM month_window
        CROSS JOIN template
    ) AS generated;

    -- Compras de viagem relevantes no cartão
    INSERT INTO transactions (
        id,
        bank_account_id,
        transaction_type,
        amount,
        transaction_date,
        description,
        category_id,
        notes,
        created_at,
        updated_at
    )
    VALUES
        (UUID_TO_BIN(UUID()), @CreditAccountId, 'EXPENSE', 2400.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -10 MONTH), INTERVAL 7 DAY), 'Reserva de hotel internacional',   @CategoryTravelId, 'Seed Perfil Demonstracao', DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -10 MONTH), INTERVAL 7 DAY) AS DATETIME), INTERVAL 11 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -10 MONTH), INTERVAL 7 DAY) AS DATETIME), INTERVAL 13 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditAccountId, 'EXPENSE', 1800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 12 DAY),  'Passagens aereas familia',        @CategoryTravelId, 'Seed Perfil Demonstracao', DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 11 HOUR),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 13 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditAccountId, 'EXPENSE', 2100.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 9 DAY),   'Pacote experiencia gastronomica', @CategoryTravelId, 'Seed Perfil Demonstracao', DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 9 DAY) AS DATETIME), INTERVAL 11 HOUR),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 9 DAY) AS DATETIME), INTERVAL 13 HOUR));

    -- Metas financeiras
    SET @GoalEmergencyId = UUID_TO_BIN(UUID());
    SET @GoalTripId = UUID_TO_BIN(UUID());
    SET @GoalEducationId = UUID_TO_BIN(UUID());
    SET @GoalLeisureLimitId = UUID_TO_BIN(UUID());

    INSERT INTO financial_goals (
        id,
        user_id,
        name,
        goal_type,
        category_id,
        target_amount,
        current_amount,
        start_date,
        end_date,
        goal_status,
        description,
        active,
        notify_on_achieve,
        notify_on_exceed,
        achieved_at,
        created_at,
        updated_at
    )
    VALUES
        (@GoalEmergencyId, @UserId, 'Reserva de emergencia', 'SAVINGS', NULL,
         40000.00, 28500.00,
         DATE_ADD(@MonthStart, INTERVAL -24 MONTH), DATE_ADD(@MonthStart, INTERVAL 6 MONTH),
         'IN_PROGRESS', 'Cobertura de seis meses das despesas fixas.',
         1, 1, 1, NULL,
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -24 MONTH), @Now),
        (@GoalTripId, @UserId, 'Viagem internacional anual', 'SAVINGS', @CategoryTravelId,
         15000.00, 15200.00,
         DATE_ADD(@MonthStart, INTERVAL -10 MONTH), DATE_ADD(@MonthStart, INTERVAL 2 MONTH),
         'ACHIEVED', 'Planejamento de ferias com experiencias culturais.',
         1, 1, 1, DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -1 MONTH),
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -10 MONTH), @Now),
        (@GoalEducationId, @UserId, 'MBA e cursos de atualizacao', 'SAVINGS', @CategoryEducationId,
         12000.00, 8600.00,
         DATE_ADD(@MonthStart, INTERVAL -18 MONTH), DATE_ADD(@MonthStart, INTERVAL 12 MONTH),
         'IN_PROGRESS', 'Fundo para cursos de lideranca e tecnologia.',
         1, 1, 1, NULL,
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -18 MONTH), @Now),
        (@GoalLeisureLimitId, @UserId, 'Controle de gastos com lazer', 'EXPENSE_LIMIT', @CategoryLeisureId,
         1200.00, 1340.00,
         DATE_ADD(@MonthStart, INTERVAL -5 MONTH), DATE_ADD(@MonthStart, INTERVAL 1 MONTH),
         'EXCEEDED', 'Meta mensal para manter lazer em equilibrio.',
         1, 0, 1, NULL,
         DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -5 MONTH), @Now);

    -- Contribuições para metas de poupança
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT @GoalEmergencyId AS goal_id, 'Aporte reserva emergencia' AS description,
               26 AS day_offset, 950.00 AS base_amount, -12.00 AS monthly_delta, 0 AS seasonal_period, 0.00 AS seasonal_boost, 750.00 AS min_amount, @MonthsBack AS max_month_offset
        UNION ALL
        SELECT @GoalTripId, 'Poupanca viagem anual',
               8, 780.00, -22.00, 4, 320.00, 600.00, 8
        UNION ALL
        SELECT @GoalEducationId, 'Fundo educacao e cursos',
               18, 520.00, -6.00, 3, 150.00, 380.00, @MonthsBack
    )
    INSERT INTO goal_contributions (
        id,
        goal_id,
        user_id,
        amount,
        description,
        allocation_date,
        created_at,
        updated_at
    )
    SELECT
        UUID_TO_BIN(UUID()),
        generated.goal_id,
        @UserId,
        generated.amount,
        generated.description,
        generated.allocation_date,
        DATE_ADD(CAST(generated.allocation_date AS DATETIME), INTERVAL 18 HOUR),
        DATE_ADD(CAST(generated.allocation_date AS DATETIME), INTERVAL 18 HOUR)
    FROM (
        SELECT
            template.goal_id,
            template.description,
            DATE_ADD(month_window.month_start, INTERVAL template.day_offset DAY) AS allocation_date,
            ROUND(
                GREATEST(
                    template.min_amount,
                    template.base_amount + (month_window.idx * template.monthly_delta) +
                    (CASE
                        WHEN template.seasonal_period > 0 AND MOD(month_window.idx, template.seasonal_period) = 0
                        THEN template.seasonal_boost
                        ELSE 0
                    END)
                ),
                2
            ) AS amount
        FROM month_window
        JOIN template
        WHERE month_window.idx <= template.max_month_offset
    ) AS generated;

COMMIT;

-- Verificações rápidas do estado inserido
SELECT BIN_TO_UUID(@UserId) AS demo_user_id;

SELECT
    ba.nickname,
    ba.account_type,
    ba.current_balance,
    ba.created_at
FROM bank_accounts AS ba
WHERE ba.user_id = @UserId
ORDER BY ba.created_at;

SELECT
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS ano_mes,
    SUM(CASE WHEN t.transaction_type = 'INCOME' THEN t.amount ELSE 0 END)            AS total_in,
    SUM(CASE WHEN t.transaction_type IN ('EXPENSE', 'TRANSFER_OUT') THEN t.amount ELSE 0 END) AS total_out
FROM transactions AS t
INNER JOIN bank_accounts ba ON ba.id = t.bank_account_id
WHERE ba.user_id = @UserId
GROUP BY ano_mes
ORDER BY ano_mes DESC
LIMIT 6;

SELECT
    fg.name,
    fg.goal_type,
    fg.goal_status,
    fg.current_amount,
    fg.target_amount,
    fg.end_date
FROM financial_goals fg
WHERE fg.user_id = @UserId
ORDER BY fg.end_date;
