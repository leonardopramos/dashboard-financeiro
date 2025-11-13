/*
    Script de seed pontual para o dashboard financeiro.
    - Remove dados anteriores do usuario informado.
    - Cria as categorias, contas bancarias e transacoes fornecidas.

    Execute apos ajustar o identificador do usuario e apontar para o banco correto:
        mysql -u root -p < backend/dashboard-financeiro/scripts/custom_user_seed.sql
*/

USE dashboard_financeiro;

-- Substitua pelo identificador real do usuario proveniente do servico de autenticacao
SET @TargetUserId = UUID_TO_BIN('cd614a0c-46ae-43ef-8879-074ad5a6bada');

-- Datas originais informadas para criacao das contas
SET @ContaMovimentoCreatedAt      = STR_TO_DATE('2024-05-13 16:46:01.000000', '%Y-%m-%d %H:%i:%s.%f');
SET @CartaoVisionCreatedAt        = STR_TO_DATE('2024-06-13 16:46:01.000000', '%Y-%m-%d %H:%i:%s.%f');
SET @PoupancaObjetivosCreatedAt   = STR_TO_DATE('2024-06-13 16:46:01.000000', '%Y-%m-%d %H:%i:%s.%f');

-- Identificadores fornecidos
SET @ContaMovimentoId     = UUID_TO_BIN('43e2d1c1-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CartaoVisionId       = UUID_TO_BIN('450b9410-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @PoupancaObjetivosId  = UUID_TO_BIN('4480320d-c0b0-11f0-9c2d-a2aaf7edcf84');

SET @CategoriaComprasId        = UUID_TO_BIN('4b92d12b-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaEducacaoId       = UUID_TO_BIN('4c1ec563-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaLazerId          = UUID_TO_BIN('49edf762-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaMercadoId        = UUID_TO_BIN('47c0c14b-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaMoradiaId        = UUID_TO_BIN('4737be3d-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaRestaurantesId   = UUID_TO_BIN('48d88dd6-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaSaudeId          = UUID_TO_BIN('4964dfb5-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaServicosId       = UUID_TO_BIN('4b0717bf-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaTransporteId     = UUID_TO_BIN('484c6f4e-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaViagensId        = UUID_TO_BIN('4a7a1761-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaConsultoriasId   = UUID_TO_BIN('4622ca3e-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaRendimentosId    = UUID_TO_BIN('46acf018-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaSalarioId        = UUID_TO_BIN('4597875f-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CategoriaTransferenciasId = UUID_TO_BIN('4caa2cbe-c0b0-11f0-9c2d-a2aaf7edcf84');

SET @Now = UTC_TIMESTAMP(6);
SET @MonthsBack = 11; -- current month + 11 previous = 12 months
SET @MonthStart = DATE_SUB(DATE(@Now), INTERVAL (DAY(@Now) - 1) DAY);
SET @SeedNote = 'Seed Usuario Custom';
SET @TransferSavingsBase = 1650.00;
SET @TransferSavingsDelta = -18.00;
SET @CreditPaymentBase = 1950.00;
SET @CreditPaymentDelta = -22.00;

START TRANSACTION;

    -- Remove eventuais restos de execucoes anteriores (independente do usuario associado)
    DELETE FROM transactions
    WHERE id IN (
        UUID_TO_BIN('52d75f24-c0b0-11f0-9c2d-a2aaf7edcf84'),
        UUID_TO_BIN('510aa2a5-c0b0-11f0-9c2d-a2aaf7edcf84'),
        UUID_TO_BIN('510aaa03-c0b0-11f0-9c2d-a2aaf7edcf84'),
        UUID_TO_BIN('52d75e49-c0b0-11f0-9c2d-a2aaf7edcf84'),
        UUID_TO_BIN('510aaadc-c0b0-11f0-9c2d-a2aaf7edcf84'),
        UUID_TO_BIN('52d75a01-c0b0-11f0-9c2d-a2aaf7edcf84')
    );

    DELETE FROM bank_accounts
    WHERE id IN (
        @ContaMovimentoId,
        @CartaoVisionId,
        @PoupancaObjetivosId
    );

    DELETE gc
    FROM goal_contributions gc
    INNER JOIN financial_goals fg ON fg.id = gc.goal_id
    WHERE fg.category_id IN (
        @CategoriaComprasId,
        @CategoriaEducacaoId,
        @CategoriaLazerId,
        @CategoriaMercadoId,
        @CategoriaMoradiaId,
        @CategoriaRestaurantesId,
        @CategoriaSaudeId,
        @CategoriaServicosId,
        @CategoriaTransporteId,
        @CategoriaViagensId,
        @CategoriaConsultoriasId,
        @CategoriaRendimentosId,
        @CategoriaSalarioId,
        @CategoriaTransferenciasId
    );

    DELETE FROM financial_goals
    WHERE category_id IN (
        @CategoriaComprasId,
        @CategoriaEducacaoId,
        @CategoriaLazerId,
        @CategoriaMercadoId,
        @CategoriaMoradiaId,
        @CategoriaRestaurantesId,
        @CategoriaSaudeId,
        @CategoriaServicosId,
        @CategoriaTransporteId,
        @CategoriaViagensId,
        @CategoriaConsultoriasId,
        @CategoriaRendimentosId,
        @CategoriaSalarioId,
        @CategoriaTransferenciasId
    );

    DELETE FROM categories
    WHERE id IN (
        @CategoriaComprasId,
        @CategoriaEducacaoId,
        @CategoriaLazerId,
        @CategoriaMercadoId,
        @CategoriaMoradiaId,
        @CategoriaRestaurantesId,
        @CategoriaSaudeId,
        @CategoriaServicosId,
        @CategoriaTransporteId,
        @CategoriaViagensId,
        @CategoriaConsultoriasId,
        @CategoriaRendimentosId,
        @CategoriaSalarioId,
        @CategoriaTransferenciasId
    );

    -- Limpa qualquer registro anterior vinculado ao usuario
    DELETE t
    FROM transactions t
    INNER JOIN bank_accounts ba ON ba.id = t.bank_account_id
    WHERE ba.user_id = @TargetUserId;

    DELETE gc
    FROM goal_contributions gc
    INNER JOIN financial_goals fg ON fg.id = gc.goal_id
    WHERE fg.user_id = @TargetUserId
       OR gc.user_id = @TargetUserId;

    DELETE FROM financial_goals
    WHERE user_id = @TargetUserId;

    DELETE FROM bank_accounts
    WHERE user_id = @TargetUserId;

    DELETE FROM categories
    WHERE user_id = @TargetUserId;

    -- Categorias (todas como ativas)
    INSERT INTO categories (id, user_id, category_type, name, color, icon, active, created_at, updated_at)
    VALUES
        (@CategoriaComprasId,        @TargetUserId, 'EXPENSE',  'Compras',        '#EC4899', 'mdi-basket-outline',        1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaEducacaoId,       @TargetUserId, 'EXPENSE',  'Educacao',       '#0891B2', 'mdi-school',                1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaLazerId,          @TargetUserId, 'EXPENSE',  'Lazer',          '#A855F7', 'mdi-party-popper',          1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaMercadoId,        @TargetUserId, 'EXPENSE',  'Mercado',        '#EF4444', 'mdi-cart',                  1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaMoradiaId,        @TargetUserId, 'EXPENSE',  'Moradia',        '#F97316', 'mdi-home-city-outline',     1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaRestaurantesId,   @TargetUserId, 'EXPENSE',  'Restaurantes',   '#FB7185', 'mdi-silverware-fork-knife', 1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaSaudeId,          @TargetUserId, 'EXPENSE',  'Saude',          '#DC2626', 'mdi-heart-pulse',           1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaServicosId,       @TargetUserId, 'EXPENSE',  'Servicos',       '#FBBF24', 'mdi-lightning-bolt',        1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaTransporteId,     @TargetUserId, 'EXPENSE',  'Transporte',     '#6366F1', 'mdi-train-car',             1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaViagensId,        @TargetUserId, 'EXPENSE',  'Viagens',        '#0EA5E9', 'mdi-airplane',              1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaConsultoriasId,   @TargetUserId, 'INCOME',   'Consultorias',   '#22C55E', 'mdi-laptop',                1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaRendimentosId,    @TargetUserId, 'INCOME',   'Rendimentos',    '#0EA5E9', 'mdi-trending-up',           1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaSalarioId,        @TargetUserId, 'INCOME',   'Salario',        '#16A34A', 'mdi-briefcase',             1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6)),
        (@CategoriaTransferenciasId, @TargetUserId, 'TRANSFER', 'Transferencias', '#6B7280', 'mdi-swap-horizontal',       1, UTC_TIMESTAMP(6), UTC_TIMESTAMP(6));

    -- Contas bancarias e cartao
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
        (@ContaMovimentoId,    @TargetUserId, 'Banco Horizonte', '0001', '120045', '6', 'CHECKING',   'Conta Movimento',     12650.75, @ContaMovimentoCreatedAt,    @ContaMovimentoCreatedAt),
        (@CartaoVisionId,      @TargetUserId, 'Banco Horizonte', '0001', '770011', '0', 'CREDIT_CARD','Cartao Vision',       -3850.27, @CartaoVisionCreatedAt,        @CartaoVisionCreatedAt),
        (@PoupancaObjetivosId, @TargetUserId, 'Banco Horizonte', '0001', '880022', '4', 'SAVINGS',    'Poupanca Objetivos',  35850.40, @PoupancaObjetivosCreatedAt,   @PoupancaObjetivosCreatedAt);

    -- Transacoes recorrentes da conta movimento com 12 meses de historico
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT 'INCOME' AS transaction_type, 'Salario mensal' AS description, @CategoriaSalarioId AS category_id,
               4 AS day_offset, 9800.00 AS base_amount, -35.00 AS monthly_delta, 6 AS seasonal_period, 520.00 AS seasonal_boost, 9000.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Consultorias estrategicas', @CategoriaConsultoriasId,
               11, 2150.00, 55.00, 3, 310.00, 1200.00
        UNION ALL
        SELECT 'EXPENSE', 'Aluguel e condominio', @CategoriaMoradiaId,
               2, 3250.00, 0.00, 0, 0.00, 3250.00
        UNION ALL
        SELECT 'EXPENSE', 'Compras de mercado', @CategoriaMercadoId,
               6, 1210.00, -8.00, 4, 160.00, 880.00
        UNION ALL
        SELECT 'EXPENSE', 'Mobilidade urbana', @CategoriaTransporteId,
               8, 420.00, -3.00, 0, 0.00, 300.00
        UNION ALL
        SELECT 'EXPENSE', 'Aulas e cursos', @CategoriaEducacaoId,
               10, 390.00, -4.00, 2, 150.00, 200.00
        UNION ALL
        SELECT 'EXPENSE', 'Servicos e assinaturas', @CategoriaServicosId,
               15, 640.00, 6.00, 0, 0.00, 450.00
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes locais', @CategoriaRestaurantesId,
               17, 520.00, 4.50, 0, 0.00, 320.00
        UNION ALL
        SELECT 'EXPENSE', 'Cuidados pessoais', @CategoriaSaudeId,
               19, 310.00, 3.50, 4, 90.00, 200.00
        UNION ALL
        SELECT 'EXPENSE', 'Lazer presencial', @CategoriaLazerId,
               21, 460.00, 5.00, 0, 0.00, 260.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Aporte mensal poupanca', @CategoriaTransferenciasId,
               25, @TransferSavingsBase, @TransferSavingsDelta, 0, 0.00, 1000.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Pagamento fatura cartao', @CategoriaTransferenciasId,
               27, @CreditPaymentBase, @CreditPaymentDelta, 0, 0.00, 1500.00
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
        @ContaMovimentoId,
        generated.transaction_type,
        generated.amount,
        generated.tx_date,
        generated.description,
        generated.category_id,
        @SeedNote,
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

    -- Transacoes recorrentes da poupanca (aporte e rendimentos)
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT 'TRANSFER_IN' AS transaction_type, 'Transferencia conta movimento' AS description, @CategoriaTransferenciasId AS category_id,
               25 AS day_offset, @TransferSavingsBase AS base_amount, @TransferSavingsDelta AS monthly_delta, 0 AS seasonal_period, 0.00 AS seasonal_boost, 950.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Rendimento CDB mensal', @CategoriaRendimentosId,
               28, 165.00, -2.00, 3, 45.00, 110.00
        UNION ALL
        SELECT 'INCOME', 'Dividendos fundos', @CategoriaRendimentosId,
               9, 240.00, 3.50, 4, 95.00, 150.00
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
        @PoupancaObjetivosId,
        generated.transaction_type,
        generated.amount,
        generated.tx_date,
        generated.description,
        generated.category_id,
        @SeedNote,
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

    -- Resgates pontuais da poupanca conforme o historico informado
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
        (UUID_TO_BIN('510aa2a5-c0b0-11f0-9c2d-a2aaf7edcf84'), @PoupancaObjetivosId, 'TRANSFER_OUT', 3200.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 7 DAY),  'Reserva viagem familia',          @CategoriaTransferenciasId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 7 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 7 DAY) AS DATETIME), INTERVAL 9 HOUR)),
        (UUID_TO_BIN('510aaa03-c0b0-11f0-9c2d-a2aaf7edcf84'), @PoupancaObjetivosId, 'TRANSFER_OUT', 2800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH), INTERVAL 12 DAY), 'Curso especializacao',            @CategoriaTransferenciasId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 9 HOUR)),
        (UUID_TO_BIN('510aaadc-c0b0-11f0-9c2d-a2aaf7edcf84'), @PoupancaObjetivosId, 'TRANSFER_OUT', 2500.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH), INTERVAL 19 DAY), 'Reforma domestica',               @CategoriaTransferenciasId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH), INTERVAL 19 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH), INTERVAL 19 DAY) AS DATETIME), INTERVAL 9 HOUR));

    -- Transacoes recorrentes do cartao de credito
    WITH RECURSIVE month_window AS (
        SELECT 0 AS idx, @MonthStart AS month_start
        UNION ALL
        SELECT idx + 1, DATE_ADD(month_start, INTERVAL -1 MONTH)
        FROM month_window
        WHERE idx < @MonthsBack
    ),
    template AS (
        SELECT 'EXPENSE' AS transaction_type, 'Compras online e gadgets' AS description, @CategoriaComprasId AS category_id,
               8 AS day_offset, 640.00 AS base_amount, 7.50 AS monthly_delta, 3 AS seasonal_period, 180.00 AS seasonal_boost, 360.00 AS min_amount
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes premium', @CategoriaRestaurantesId,
               13, 430.00, 6.00, 0, 0.00, 220.00
        UNION ALL
        SELECT 'EXPENSE', 'Entretenimento e viagens curtas', @CategoriaViagensId,
               18, 780.00, -12.00, 4, 260.00, 450.00
        UNION ALL
        SELECT 'EXPENSE', 'Eventos e lazer', @CategoriaLazerId,
               21, 520.00, 5.50, 0, 0.00, 300.00
        UNION ALL
        SELECT 'TRANSFER_IN', 'Pagamento recebido conta movimento', @CategoriaTransferenciasId,
               27, @CreditPaymentBase, @CreditPaymentDelta, 0, 0.00, 1500.00
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
        @CartaoVisionId,
        generated.transaction_type,
        generated.amount,
        generated.tx_date,
        generated.description,
        generated.category_id,
        @SeedNote,
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 7 HOUR),
        DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 9 HOUR)
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

    -- Compras de maior valor registradas com os identificadores fornecidos
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
        (UUID_TO_BIN('52d75f24-c0b0-11f0-9c2d-a2aaf7edcf84'), @CartaoVisionId, 'EXPENSE', 2100.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 10 DAY), 'Pacote experiencia gastronomica', @CategoriaRestaurantesId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 10 DAY) AS DATETIME), INTERVAL 6 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 10 DAY) AS DATETIME), INTERVAL 8 HOUR)),
        (UUID_TO_BIN('52d75e49-c0b0-11f0-9c2d-a2aaf7edcf84'), @CartaoVisionId, 'EXPENSE', 1800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 13 DAY), 'Passagens aereas familia',        @CategoriaViagensId,     @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 13 DAY) AS DATETIME), INTERVAL 6 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 13 DAY) AS DATETIME), INTERVAL 8 HOUR)),
        (UUID_TO_BIN('52d75a01-c0b0-11f0-9c2d-a2aaf7edcf84'), @CartaoVisionId, 'EXPENSE', 2400.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 8 DAY), 'Reserva de hotel internacional',  @CategoriaViagensId,     @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 8 DAY) AS DATETIME), INTERVAL 6 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 8 DAY) AS DATETIME), INTERVAL 8 HOUR));

COMMIT;
