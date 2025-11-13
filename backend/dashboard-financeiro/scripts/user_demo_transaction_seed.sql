/*
    Script para gerar 12 meses de transações do usuário de demonstração.

    Pré-requisitos:
      - Contas e categorias já inseridas para o usuário abaixo.
      - Ajuste os identificadores apenas se estiver reaproveitando para outro usuário.

    Execução sugerida:
        mysql -u root -p < backend/dashboard-financeiro/scripts/user_demo_transaction_seed.sql
*/

USE dashboard_financeiro;

SET @UserId = UUID_TO_BIN('9d329bc3-24ac-4cfa-81b0-1de71f4afa63');

SET @CheckingAccountId   = UUID_TO_BIN('70ff8a58-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @SavingsAccountId    = UUID_TO_BIN('718aa51f-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CreditCardAccountId = UUID_TO_BIN('721437ff-c0bd-11f0-9c2d-a2aaf7edcf84');

SET @CategorySalaryId            = UUID_TO_BIN('bb32f784-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryFreelanceId         = UUID_TO_BIN('bbb91956-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryBonusId             = UUID_TO_BIN('bc434f8e-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryInvestmentId        = UUID_TO_BIN('bccdbbe4-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryHousingId           = UUID_TO_BIN('bd599932-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryUtilitiesId         = UUID_TO_BIN('bde26833-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryGroceriesId         = UUID_TO_BIN('be6a812a-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryTransportId         = UUID_TO_BIN('bef0ff86-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryDiningId            = UUID_TO_BIN('bf79d679-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryHealthId            = UUID_TO_BIN('c004b9bc-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryLeisureId           = UUID_TO_BIN('c08f7437-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryTravelId            = UUID_TO_BIN('c1176066-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryShoppingId          = UUID_TO_BIN('c1a18eaf-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryEducationId         = UUID_TO_BIN('c22a1210-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryInsuranceId         = UUID_TO_BIN('c2b35fdc-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategorySubscriptionsId     = UUID_TO_BIN('c33bd715-c0bd-11f0-9c2d-a2aaf7edcf84');
SET @CategoryTransfersId         = UUID_TO_BIN('c3c763e7-c0bd-11f0-9c2d-a2aaf7edcf84');

SET @Now = UTC_TIMESTAMP(6);
SET @MonthStart = DATE_SUB(DATE(@Now), INTERVAL (DAY(@Now) - 1) DAY);
SET @MonthsBack = 11; -- 12 meses (0..11)
SET @SeedNote = 'Seed Perfil Demonstracao';

SET @TransferSavingsBase = 1100.00;
SET @TransferSavingsDelta = -25.00;
SET @CreditPaymentBase = 1820.00;
SET @CreditPaymentDelta = -30.00;

/*
    Caso precise reaplicar o seed, descomente os blocos de limpeza abaixo:
*/
-- DELETE t
-- FROM transactions t
-- INNER JOIN bank_accounts ba ON ba.id = t.bank_account_id
-- WHERE ba.user_id = @UserId;

START TRANSACTION;

    -- Transações mensais da conta corrente (12 meses)
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
        template.transaction_type,
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
        ) AS amount,
        DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS tx_date,
        template.description,
        template.category_id,
        @SeedNote,
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 9 HOUR
        ),
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 12 HOUR
        )
    FROM (
        SELECT 0 AS idx UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
        SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    ) AS mw
    CROSS JOIN (
        SELECT 'INCOME' AS transaction_type, 'Salario CLT' AS description, @CategorySalaryId AS category_id,
               3 AS day_offset, 9850.00 AS base_amount, -38.00 AS monthly_delta, 6 AS seasonal_period, 620.00 AS seasonal_boost, 9400.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Consultorias e freelas', @CategoryFreelanceId,
               11, 1750.00, 42.00, 3, 310.00, 1150.00
        UNION ALL
        SELECT 'INCOME', 'Bonus e variaveis', @CategoryBonusId,
               25, 420.00, -18.00, 4, 1250.00, 300.00
        UNION ALL
        SELECT 'EXPENSE', 'Aluguel e condominio', @CategoryHousingId,
               2, 3280.00, 0.00, 0, 0.00, 3280.00
        UNION ALL
        SELECT 'EXPENSE', 'Servicos essenciais (agua, luz, internet)', @CategoryUtilitiesId,
               5, 640.00, 5.50, 0, 0.00, 520.00
        UNION ALL
        SELECT 'EXPENSE', 'Compras de mercado', @CategoryGroceriesId,
               7, 1230.00, -9.50, 4, 170.00, 920.00
        UNION ALL
        SELECT 'EXPENSE', 'Mobilidade urbana', @CategoryTransportId,
               9, 410.00, -4.00, 0, 0.00, 280.00
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes e cafes', @CategoryDiningId,
               15, 520.00, 6.00, 0, 0.00, 260.00
        UNION ALL
        SELECT 'EXPENSE', 'Plano de saude e consultas', @CategoryHealthId,
               18, 360.00, 4.80, 4, 90.00, 260.00
        UNION ALL
        SELECT 'EXPENSE', 'Lazer e streaming', @CategoryLeisureId,
               20, 440.00, 5.20, 0, 0.00, 260.00
        UNION ALL
        SELECT 'EXPENSE', 'Compras pessoais loja fisica', @CategoryShoppingId,
               22, 480.00, 8.00, 3, 200.00, 180.00
        UNION ALL
        SELECT 'EXPENSE', 'Cursos e educacao continuada', @CategoryEducationId,
               23, 360.00, -4.50, 2, 150.00, 220.00
        UNION ALL
        SELECT 'EXPENSE', 'Seguros veicular e residencial', @CategoryInsuranceId,
               12, 280.00, 3.00, 6, 320.00, 220.00
        UNION ALL
        SELECT 'EXPENSE', 'Assinaturas e aplicativos', @CategorySubscriptionsId,
               6, 180.00, 1.50, 0, 0.00, 150.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Aporte mensal poupanca', @CategoryTransfersId,
               27, @TransferSavingsBase, @TransferSavingsDelta, 0, 0.00, 780.00
        UNION ALL
        SELECT 'TRANSFER_OUT', 'Pagamento fatura cartao', @CategoryTransfersId,
               28, @CreditPaymentBase, @CreditPaymentDelta, 0, 0.00, 1250.00
    ) AS template (
        transaction_type,
        description,
        category_id,
        day_offset,
        base_amount,
        monthly_delta,
        seasonal_period,
        seasonal_boost,
        min_amount
    );

    -- Eventos adicionais da conta corrente
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
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      2150.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -10 MONTH), INTERVAL 16 DAY), 'Reforma do escritorio',        @CategoryHousingId,       @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -10 MONTH), INTERVAL 16 DAY) AS DATETIME), INTERVAL 9 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -10 MONTH), INTERVAL 16 DAY) AS DATETIME), INTERVAL 12 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_IN',   2500.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH),  INTERVAL 4 DAY),  'Resgate poupanca para viagem', @CategoryTransfersId,     @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH),  INTERVAL 4 DAY) AS DATETIME),  INTERVAL 9 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH),  INTERVAL 4 DAY) AS DATETIME),  INTERVAL 12 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1850.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH),  INTERVAL 5 DAY),  'Compra pacote litoral',        @CategoryTravelId,        @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH),  INTERVAL 5 DAY) AS DATETIME),  INTERVAL 9 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -8 MONTH),  INTERVAL 5 DAY) AS DATETIME),  INTERVAL 12 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_IN',   1800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -3 MONTH),  INTERVAL 7 DAY),  'Reembolso empresa',            @CategoryTransfersId,     @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -3 MONTH),  INTERVAL 7 DAY) AS DATETIME),  INTERVAL 9 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -3 MONTH),  INTERVAL 7 DAY) AS DATETIME),  INTERVAL 12 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1320.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH),  INTERVAL 14 DAY), 'Seguro viagem familia',        @CategoryInsuranceId,     @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH),  INTERVAL 14 DAY) AS DATETIME), INTERVAL 9 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -1 MONTH),  INTERVAL 14 DAY) AS DATETIME), INTERVAL 12 HOUR));

    -- Transações recorrentes da poupança (aportes + rendimentos)
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
        template.transaction_type,
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
        ) AS amount,
        DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS tx_date,
        template.description,
        template.category_id,
        @SeedNote,
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 8 HOUR
        ),
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 10 HOUR
        )
    FROM (
        SELECT 0 AS idx UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
        SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    ) AS mw
    CROSS JOIN (
        SELECT 'TRANSFER_IN' AS transaction_type, 'Transferencia conta corrente' AS description, @CategoryTransfersId AS category_id,
               27 AS day_offset, @TransferSavingsBase AS base_amount, @TransferSavingsDelta AS monthly_delta, 0 AS seasonal_period, 0.00 AS seasonal_boost, 780.00 AS min_amount
        UNION ALL
        SELECT 'INCOME', 'Rendimento CDB mensal', @CategoryInvestmentId,
               28, 145.00, -2.00, 3, 44.00, 95.00
        UNION ALL
        SELECT 'INCOME', 'Dividendos fundos imob.', @CategoryInvestmentId,
               10, 215.00, 4.20, 4, 88.00, 140.00
    ) AS template (
        transaction_type,
        description,
        category_id,
        day_offset,
        base_amount,
        monthly_delta,
        seasonal_period,
        seasonal_boost,
        min_amount
    );

    -- Resgates pontuais da poupança para grandes despesas
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
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 3200.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH),  INTERVAL 6 DAY),  'Reserva viagem internacional', @CategoryTravelId,    @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH),  INTERVAL 6 DAY) AS DATETIME),  INTERVAL 8 HOUR),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -9 MONTH),  INTERVAL 6 DAY) AS DATETIME),  INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 2800.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH),  INTERVAL 18 DAY), 'Curso especializacao',         @CategoryEducationId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH),  INTERVAL 18 DAY) AS DATETIME),  INTERVAL 8 HOUR),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -6 MONTH),  INTERVAL 18 DAY) AS DATETIME),  INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 2550.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH),  INTERVAL 11 DAY), 'Obra planejada apartamento',   @CategoryHousingId,   @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH),  INTERVAL 11 DAY) AS DATETIME),  INTERVAL 8 HOUR),  DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -4 MONTH),  INTERVAL 11 DAY) AS DATETIME),  INTERVAL 10 HOUR));

    -- Movimentações recorrentes do cartão de crédito
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
        @CreditCardAccountId,
        template.transaction_type,
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
        ) AS amount,
        DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS tx_date,
        template.description,
        template.category_id,
        @SeedNote,
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 11 HOUR
        ),
        DATE_ADD(
            CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -mw.idx MONTH), INTERVAL template.day_offset DAY) AS DATETIME),
            INTERVAL 13 HOUR
        )
    FROM (
        SELECT 0 AS idx UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
        SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    ) AS mw
    CROSS JOIN (
        SELECT 'EXPENSE' AS transaction_type, 'Compras online e gadgets', @CategoryShoppingId AS category_id,
               8 AS day_offset, 610.00 AS base_amount, 9.50 AS monthly_delta, 3 AS seasonal_period, 190.00 AS seasonal_boost, 320.00 AS min_amount
        UNION ALL
        SELECT 'EXPENSE', 'Restaurantes no cartao', @CategoryDiningId,
               13, 430.00, 6.00, 0, 0.00, 220.00
        UNION ALL
        SELECT 'EXPENSE', 'Entretenimento e shows', @CategoryLeisureId,
               17, 520.00, 6.50, 4, 210.00, 260.00
        UNION ALL
        SELECT 'EXPENSE', 'Assinaturas premium', @CategorySubscriptionsId,
               5, 210.00, 2.00, 0, 0.00, 180.00
        UNION ALL
        SELECT 'EXPENSE', 'Cursos online parcelados', @CategoryEducationId,
               21, 460.00, -6.00, 2, 140.00, 200.00
        UNION ALL
        SELECT 'EXPENSE', 'Passagens e viagens no credito', @CategoryTravelId,
               9, 980.00, -12.00, 6, 900.00, 640.00
        UNION ALL
        SELECT 'TRANSFER_IN', 'Pagamento vindo conta corrente', @CategoryTransfersId,
               28, @CreditPaymentBase, @CreditPaymentDelta, 0, 0.00, 1250.00
    ) AS template (
        transaction_type,
        description,
        category_id,
        day_offset,
        base_amount,
        monthly_delta,
        seasonal_period,
        seasonal_boost,
        min_amount
    );

    -- Compras expressivas no cartão
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
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE', 2380.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 7 DAY), 'Reserva resort Patagonia',     @CategoryTravelId,    @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 7 DAY) AS DATETIME), INTERVAL 11 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -11 MONTH), INTERVAL 7 DAY) AS DATETIME), INTERVAL 13 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE', 1840.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH),  INTERVAL 12 DAY), 'Upgrade notebook trabalho',   @CategoryShoppingId, @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH),  INTERVAL 12 DAY) AS DATETIME), INTERVAL 11 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -5 MONTH),  INTERVAL 12 DAY) AS DATETIME), INTERVAL 13 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE', 2100.00, DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH),  INTERVAL 9 DAY),  'Pacote experiencias gourmet', @CategoryDiningId,    @SeedNote, DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH),  INTERVAL 9 DAY) AS DATETIME),  INTERVAL 11 HOUR), DATE_ADD(CAST(DATE_ADD(DATE_ADD(@MonthStart, INTERVAL -2 MONTH),  INTERVAL 9 DAY) AS DATETIME),  INTERVAL 13 HOUR));

COMMIT;

-- Resumo rápido para validar a carga
SELECT 'CHECKING' AS account_type,
       COUNT(*) AS total_transactions,
       MIN(transaction_date) AS first_transaction,
       MAX(transaction_date) AS last_transaction,
       SUM(CASE WHEN transaction_type = 'INCOME' THEN amount ELSE 0 END) AS total_in,
       SUM(CASE WHEN transaction_type IN ('EXPENSE', 'TRANSFER_OUT') THEN amount ELSE 0 END) AS total_out
FROM transactions
WHERE bank_account_id = @CheckingAccountId;

SELECT 'SAVINGS' AS account_type,
       COUNT(*) AS total_transactions,
       MIN(transaction_date) AS first_transaction,
       MAX(transaction_date) AS last_transaction,
       SUM(CASE WHEN transaction_type IN ('INCOME', 'TRANSFER_IN') THEN amount ELSE 0 END) AS total_in,
       SUM(CASE WHEN transaction_type IN ('EXPENSE', 'TRANSFER_OUT') THEN amount ELSE 0 END) AS total_out
FROM transactions
WHERE bank_account_id = @SavingsAccountId;

SELECT 'CREDIT_CARD' AS account_type,
       COUNT(*) AS total_transactions,
       MIN(transaction_date) AS first_transaction,
       MAX(transaction_date) AS last_transaction,
       SUM(CASE WHEN transaction_type IN ('INCOME', 'TRANSFER_IN') THEN amount ELSE 0 END) AS total_in,
       SUM(CASE WHEN transaction_type = 'EXPENSE' THEN amount ELSE 0 END) AS total_out
FROM transactions
WHERE bank_account_id = @CreditCardAccountId;
