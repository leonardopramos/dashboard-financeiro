/*
    Seed completo pensado para execucao direta no DataGrip.
    - Remove qualquer dado previo do usuario cd614a0c-46ae-43ef-8879-074ad5a6bada.
    - Insere categorias, contas, transacoes (12 meses), metas e contribuicoes.
    - So utiliza SQL basico + tabelas temporarias para garantir compatibilidade.
*/

USE dashboard_financeiro;

SET @TargetUserId = UUID_TO_BIN('cd614a0c-46ae-43ef-8879-074ad5a6bada');

SET @ContaMovimentoId    = UUID_TO_BIN('43e2d1c1-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @CartaoVisionId      = UUID_TO_BIN('450b9410-c0b0-11f0-9c2d-a2aaf7edcf84');
SET @PoupancaObjetivosId = UUID_TO_BIN('4480320d-c0b0-11f0-9c2d-a2aaf7edcf84');

SET @ContaMovimentoCreatedAt    = STR_TO_DATE('2023-08-15 14:00:00.000000', '%Y-%m-%d %H:%i:%s.%f');
SET @CartaoVisionCreatedAt      = STR_TO_DATE('2023-08-18 10:20:00.000000', '%Y-%m-%d %H:%i:%s.%f');
SET @PoupancaObjetivosCreatedAt = STR_TO_DATE('2023-08-20 09:10:00.000000', '%Y-%m-%d %H:%i:%s.%f');

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

SET @GoalEmergencyId = UUID_TO_BIN('7b1c9a70-cdd2-4ceb-9bda-e3a5e6177890');
SET @GoalTripId      = UUID_TO_BIN('8fb7379f-3597-4f9a-b5f2-f8f5b4a3f6a0');
SET @GoalUpgradeId   = UUID_TO_BIN('a3e61534-0718-4f65-8332-5ecaac3f3e87');

SET @Now = UTC_TIMESTAMP(6);
SET @MonthStart = DATE_SUB(DATE(@Now), INTERVAL (DAY(@Now) - 1) DAY);
SET @MonthsBack = 11;
SET @SeedNote = 'Dashboard Seed';

START TRANSACTION;

DELETE gc
FROM goal_contributions gc
INNER JOIN financial_goals fg ON fg.id = gc.goal_id
WHERE fg.user_id = @TargetUserId OR gc.user_id = @TargetUserId;

DELETE FROM financial_goals
WHERE user_id = @TargetUserId;

DELETE t
FROM transactions t
INNER JOIN bank_accounts ba ON ba.id = t.bank_account_id
WHERE ba.user_id = @TargetUserId;

DELETE FROM bank_accounts
WHERE user_id = @TargetUserId;

DELETE FROM categories
WHERE user_id = @TargetUserId;

INSERT INTO categories (id, user_id, category_type, name, color, icon, active, created_at, updated_at) VALUES
(@CategoriaSalarioId,        @TargetUserId, 'INCOME',   'Salario',        '#16A34A', 'mdi-briefcase',             1, @Now, @Now),
(@CategoriaConsultoriasId,   @TargetUserId, 'INCOME',   'Consultorias',   '#22C55E', 'mdi-laptop',                1, @Now, @Now),
(@CategoriaRendimentosId,    @TargetUserId, 'INCOME',   'Rendimentos',    '#0EA5E9', 'mdi-trending-up',           1, @Now, @Now),
(@CategoriaMoradiaId,        @TargetUserId, 'EXPENSE',  'Moradia',        '#F97316', 'mdi-home-city-outline',     1, @Now, @Now),
(@CategoriaMercadoId,        @TargetUserId, 'EXPENSE',  'Mercado',        '#EF4444', 'mdi-cart',                  1, @Now, @Now),
(@CategoriaTransporteId,     @TargetUserId, 'EXPENSE',  'Transporte',     '#6366F1', 'mdi-train-car',             1, @Now, @Now),
(@CategoriaSaudeId,          @TargetUserId, 'EXPENSE',  'Saude',          '#DC2626', 'mdi-heart-pulse',           1, @Now, @Now),
(@CategoriaServicosId,       @TargetUserId, 'EXPENSE',  'Servicos',       '#FBBF24', 'mdi-lightning-bolt',        1, @Now, @Now),
(@CategoriaRestaurantesId,   @TargetUserId, 'EXPENSE',  'Restaurantes',   '#FB7185', 'mdi-silverware-fork-knife', 1, @Now, @Now),
(@CategoriaLazerId,          @TargetUserId, 'EXPENSE',  'Lazer',          '#A855F7', 'mdi-party-popper',          1, @Now, @Now),
(@CategoriaEducacaoId,       @TargetUserId, 'EXPENSE',  'Educacao',       '#0891B2', 'mdi-school',                1, @Now, @Now),
(@CategoriaComprasId,        @TargetUserId, 'EXPENSE',  'Compras',        '#EC4899', 'mdi-basket-outline',        1, @Now, @Now),
(@CategoriaViagensId,        @TargetUserId, 'EXPENSE',  'Viagens',        '#0EA5E9', 'mdi-airplane',              1, @Now, @Now),
(@CategoriaTransferenciasId, @TargetUserId, 'TRANSFER', 'Transferencias', '#6B7280', 'mdi-swap-horizontal',       1, @Now, @Now);

INSERT INTO bank_accounts (
    id, user_id, institution_name, branch_number, account_number,
    account_digit, account_type, nickname, current_balance, created_at, updated_at
) VALUES
(@ContaMovimentoId,    @TargetUserId, 'Banco Horizonte', '0101', '450021', '1', 'CHECKING',   'Conta Movimento',     14820.55, @ContaMovimentoCreatedAt,    @Now),
(@PoupancaObjetivosId, @TargetUserId, 'Banco Horizonte', '0101', '880045', '4', 'SAVINGS',    'Poupanca Objetivos',  40210.90, @PoupancaObjetivosCreatedAt, @Now),
(@CartaoVisionId,      @TargetUserId, 'Banco Horizonte', '0101', '990067', '0', 'CREDIT_CARD','Cartao Vision',       -4280.35, @CartaoVisionCreatedAt,      @Now);

DROP TEMPORARY TABLE IF EXISTS tmp_months;
CREATE TEMPORARY TABLE tmp_months (
    idx INT PRIMARY KEY,
    month_start DATE NOT NULL
) ENGINE = MEMORY;

INSERT INTO tmp_months (idx, month_start)
SELECT seq.idx, DATE_ADD(@MonthStart, INTERVAL -seq.idx MONTH)
FROM (
    SELECT 0 AS idx UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
) AS seq;

/* Conta movimento: receitas principais, despesas fixas e transferencias */
INSERT INTO transactions (
    id, bank_account_id, transaction_type, amount, transaction_date,
    description, category_id, notes, created_at, updated_at
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
        DATE_ADD(mw.month_start, INTERVAL template.day_offset DAY) AS tx_date,
        ROUND(
            GREATEST(
                template.min_amount,
                template.base_amount + (mw.idx * template.monthly_delta) +
                (CASE
                    WHEN template.seasonal_period > 0 AND MOD(mw.idx, template.seasonal_period) = 0
                    THEN template.seasonal_boost
                    ELSE 0
                END)
            ),
            2
        ) AS amount
    FROM tmp_months mw
    CROSS JOIN (
        SELECT 'INCOME' AS transaction_type, 'Salario CLT' AS description, @CategoriaSalarioId AS category_id,
               5 AS day_offset, 9800.00 AS base_amount, -40.00 AS monthly_delta, 6 AS seasonal_period, 520.00 AS seasonal_boost, 9100.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Consultoria estrategica', @CategoriaConsultoriasId,
               12, 2150.00, 65.00, 3, 290.00, 1200.00
        UNION ALL
        SELECT 'EXPENSE', 'Aluguel e condominio', @CategoriaMoradiaId,
               3, 3300.00, 0.00, 0, 0.00, 3300.00
        UNION ALL
        SELECT 'EXPENSE', 'Compras de mercado', @CategoriaMercadoId,
               7, 1180.00, -9.00, 4, 150.00, 900.00
        UNION ALL
        SELECT 'EXPENSE', 'Mobilidade urbana', @CategoriaTransporteId,
               9, 420.00, -2.50, 0, 0.00, 280.00
        UNION ALL
        SELECT 'EXPENSE', 'Cuidados de saude', @CategoriaSaudeId,
               14, 360.00, 4.00, 4, 95.00, 240.00
        UNION ALL
        SELECT 'EXPENSE', 'Servicos e assinaturas', @CategoriaServicosId,
               17, 640.00, 6.00, 0, 0.00, 420.00
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes locais', @CategoriaRestaurantesId,
               20, 520.00, 5.00, 0, 0.00, 300.00
        UNION ALL
        SELECT 'EXPENSE', 'Lazer presencial', @CategoriaLazerId,
               23, 460.00, 4.50, 0, 0.00, 250.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Aporte mensal poupanca', @CategoriaTransferenciasId,
               26, 1550.00, -18.00, 0, 0.00, 980.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Pagamento cartao Vision', @CategoriaTransferenciasId,
               28, 1950.00, -22.00, 0, 0.00, 1400.00
    ) AS template
) AS generated;

/* Poupanca: aportes recebidos e rendimentos */
INSERT INTO transactions (
    id, bank_account_id, transaction_type, amount, transaction_date,
    description, category_id, notes, created_at, updated_at
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
        DATE_ADD(mw.month_start, INTERVAL template.day_offset DAY) AS tx_date,
        ROUND(
            GREATEST(
                template.min_amount,
                template.base_amount + (mw.idx * template.monthly_delta) +
                (CASE
                    WHEN template.seasonal_period > 0 AND MOD(mw.idx, template.seasonal_period) = 0
                    THEN template.seasonal_boost
                    ELSE 0
                END)
            ),
            2
        ) AS amount
    FROM tmp_months mw
    CROSS JOIN (
        SELECT 'TRANSFER_IN' AS transaction_type, 'Transferencia conta movimento' AS description, @CategoriaTransferenciasId AS category_id,
               26 AS day_offset, 1550.00 AS base_amount, -18.00 AS monthly_delta, 0 AS seasonal_period, 0.00 AS seasonal_boost, 950.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Rendimento CDB', @CategoriaRendimentosId,
               28, 175.00, -2.00, 3, 40.00, 120.00
        UNION ALL
        SELECT 'INCOME', 'Dividendos fundos', @CategoriaRendimentosId,
               10, 240.00, 3.50, 4, 95.00, 150.00
    ) AS template
) AS generated;

INSERT INTO transactions (
    id, bank_account_id, transaction_type, amount, transaction_date,
    description, category_id, notes, created_at, updated_at
) VALUES
(UUID_TO_BIN('510aa2a5-c0b0-11f0-9c2d-a2aaf7edcf84'), @PoupancaObjetivosId, 'TRANSFER_OUT', 3200.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 6 DAY),  'Reserva viagem familia', @CategoriaTransferenciasId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 6 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH), INTERVAL 6 DAY) AS DATETIME), INTERVAL 9 HOUR)),
(UUID_TO_BIN('510aaa03-c0b0-11f0-9c2d-a2aaf7edcf84'), @PoupancaObjetivosId, 'TRANSFER_OUT', 2800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH), INTERVAL 11 DAY), 'Curso especializacao',   @CategoriaTransferenciasId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH), INTERVAL 11 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH), INTERVAL 11 DAY) AS DATETIME), INTERVAL 9 HOUR)),
(UUID_TO_BIN('510aaadc-c0b0-11f0-9c2d-a2aaf7edcf84'), @PoupancaObjetivosId, 'TRANSFER_OUT', 2500.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH), INTERVAL 18 DAY), 'Reforma domestica',      @CategoriaTransferenciasId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH), INTERVAL 18 DAY) AS DATETIME), INTERVAL 7 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH), INTERVAL 18 DAY) AS DATETIME), INTERVAL 9 HOUR));

/* Cartao Vision: despesas parceladas e pagamento da fatura */
INSERT INTO transactions (
    id, bank_account_id, transaction_type, amount, transaction_date,
    description, category_id, notes, created_at, updated_at
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
    DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 6 HOUR),
    DATE_ADD(CAST(generated.tx_date AS DATETIME), INTERVAL 8 HOUR)
FROM (
    SELECT
        template.transaction_type,
        template.description,
        template.category_id,
        DATE_ADD(mw.month_start, INTERVAL template.day_offset DAY) AS tx_date,
        ROUND(
            GREATEST(
                template.min_amount,
                template.base_amount + (mw.idx * template.monthly_delta) +
                (CASE
                    WHEN template.seasonal_period > 0 AND MOD(mw.idx, template.seasonal_period) = 0
                    THEN template.seasonal_boost
                    ELSE 0
                END)
            ),
            2
        ) AS amount
    FROM tmp_months mw
    CROSS JOIN (
        SELECT 'EXPENSE' AS transaction_type, 'Compras online e gadgets' AS description, @CategoriaComprasId AS category_id,
               8 AS day_offset, 620.00 AS base_amount, 8.00 AS monthly_delta, 3 AS seasonal_period, 180.00 AS seasonal_boost, 360.00 AS min_amount
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes especiais', @CategoriaRestaurantesId,
               13, 430.00, 5.50, 0, 0.00, 220.00
        UNION ALL
        SELECT 'EXPENSE', 'Entretenimento e viagens curtas', @CategoriaViagensId,
               18, 760.00, -11.00, 4, 260.00, 450.00
        UNION ALL
        SELECT 'EXPENSE', 'Eventos e lazer', @CategoriaLazerId,
               22, 480.00, 4.50, 0, 0.00, 260.00
        UNION ALL
        SELECT 'TRANSFER_IN', 'Pagamento recebido conta movimento', @CategoriaTransferenciasId,
               27, 1950.00, -22.00, 0, 0.00, 1500.00
    ) AS template
) AS generated;

INSERT INTO transactions (
    id, bank_account_id, transaction_type, amount, transaction_date,
    description, category_id, notes, created_at, updated_at
) VALUES
(UUID_TO_BIN('52d75a01-c0b0-11f0-9c2d-a2aaf7edcf84'), @CartaoVisionId, 'EXPENSE', 2400.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 9 DAY), 'Reserva hotel internacional',   @CategoriaViagensId,      @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 9 DAY) AS DATETIME), INTERVAL 6 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 9 DAY) AS DATETIME), INTERVAL 8 HOUR)),
(UUID_TO_BIN('52d75e49-c0b0-11f0-9c2d-a2aaf7edcf84'), @CartaoVisionId, 'EXPENSE', 1800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 12 DAY), 'Passagens aereas familia',      @CategoriaViagensId,      @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 6 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH), INTERVAL 12 DAY) AS DATETIME), INTERVAL 8 HOUR)),
(UUID_TO_BIN('52d75f24-c0b0-11f0-9c2d-a2aaf7edcf84'), @CartaoVisionId, 'EXPENSE', 2100.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 11 DAY), 'Experiencia gastronomica',     @CategoriaRestaurantesId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 11 DAY) AS DATETIME), INTERVAL 6 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH), INTERVAL 11 DAY) AS DATETIME), INTERVAL 8 HOUR));

/* Metas financeiras */
INSERT INTO financial_goals (
    id, user_id, name, goal_type, category_id, target_amount, current_amount,
    start_date, end_date, goal_status, description,
    active, notify_on_achieve, notify_on_exceed, achieved_at, created_at, updated_at
) VALUES
(@GoalEmergencyId, @TargetUserId, 'Reserva de emergencia', 'SAVINGS', NULL,
 30000.00, 18500.00,
 DATE_ADD(@MonthStart, INTERVAL -8 MONTH), DATE_ADD(@MonthStart, INTERVAL 7 MONTH),
 'IN_PROGRESS', 'Construir reserva equivalente a 6 meses de despesas.',
 1, 1, 1, NULL,
 DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -8 MONTH), @Now),
(@GoalTripId, @TargetUserId, 'Viagem internacional familia', 'SAVINGS', @CategoriaViagensId,
 15000.00, 9400.00,
 DATE_ADD(@MonthStart, INTERVAL -10 MONTH), DATE_ADD(@MonthStart, INTERVAL 3 MONTH),
 'IN_PROGRESS', 'Planejamento da proxima grande viagem.',
 1, 1, 1, NULL,
 DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -10 MONTH), @Now),
(@GoalUpgradeId, @TargetUserId, 'Atualizacao setup profissional', 'EXPENSE_LIMIT', @CategoriaConsultoriasId,
 8000.00, 4200.00,
 DATE_ADD(@MonthStart, INTERVAL -5 MONTH), DATE_ADD(@MonthStart, INTERVAL 5 MONTH),
 'ON_TRACK', 'Controle de investimentos em cursos e equipamentos.',
 1, 1, 0, NULL,
 DATE_ADD(CAST(@MonthStart AS DATETIME), INTERVAL -5 MONTH), @Now);

INSERT INTO goal_contributions (
    id, goal_id, user_id, amount, description, allocation_date, created_at, updated_at
) VALUES
(UUID_TO_BIN(UUID()), @GoalEmergencyId, @TargetUserId, 1800.00, 'Aporte mensal reserva', DATE_ADD(@MonthStart, INTERVAL -1 MONTH), @Now, @Now),
(UUID_TO_BIN(UUID()), @GoalEmergencyId, @TargetUserId, 1750.00, 'Aporte mensal reserva', DATE_ADD(@MonthStart, INTERVAL -2 MONTH), @Now, @Now),
(UUID_TO_BIN(UUID()), @GoalTripId,      @TargetUserId, 2200.00, 'Economia viagem', DATE_ADD(@MonthStart, INTERVAL -3 MONTH), @Now, @Now),
(UUID_TO_BIN(UUID()), @GoalTripId,      @TargetUserId, 2100.00, 'Economia viagem', DATE_ADD(@MonthStart, INTERVAL -4 MONTH), @Now, @Now),
(UUID_TO_BIN(UUID()), @GoalUpgradeId,   @TargetUserId, 900.00,  'Compra de cursos e equipamentos', DATE_ADD(@MonthStart, INTERVAL -1 MONTH), @Now, @Now);

DROP TEMPORARY TABLE IF EXISTS tmp_months;

COMMIT;
