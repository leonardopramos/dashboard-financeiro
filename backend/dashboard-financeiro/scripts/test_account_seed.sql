/*
    Script de carga inicial (MySQL) para montar uma conta completa com dados suficientes
    para testar os gráficos do dashboard financeiro.

    ⚠️ Ajuste o valor de @UserId para o identificador do usuário que será usado nos testes,
    de acordo com o cadastro existente no serviço de autenticação.
*/

USE dashboard_financeiro;
SET @UserId = UUID_TO_BIN('311B8AF3-1790-4BA9-929D-A52172B81A17');
SET @Now = UTC_TIMESTAMP(6);

SET @Month0 = DATE_SUB(DATE(@Now), INTERVAL (DAY(@Now) - 1) DAY); -- mês corrente
SET @Month1 = DATE_ADD(@Month0, INTERVAL -1 MONTH);
SET @Month2 = DATE_ADD(@Month0, INTERVAL -2 MONTH);
SET @Month3 = DATE_ADD(@Month0, INTERVAL -3 MONTH);
SET @Month4 = DATE_ADD(@Month0, INTERVAL -4 MONTH);
SET @Month5 = DATE_ADD(@Month0, INTERVAL -5 MONTH);

START TRANSACTION;

    -- Limpa dados anteriores do usuário alvo
    DELETE t
    FROM transactions t
    INNER JOIN bank_accounts ba ON ba.id = t.bank_account_id
    WHERE ba.user_id = @UserId;

    DELETE FROM financial_goals
    WHERE user_id = @UserId;

    DELETE FROM categories
    WHERE user_id = @UserId;

    DELETE FROM bank_accounts
    WHERE user_id = @UserId;

    -- Identificadores reutilizados
SET @CheckingAccountId = UUID_TO_BIN(UUID());
SET @SavingsAccountId = UUID_TO_BIN(UUID());
SET @CreditCardAccountId = UUID_TO_BIN(UUID());
SET @CategorySalaryId = UUID_TO_BIN(UUID());
SET @CategorySideIncomeId = UUID_TO_BIN(UUID());
SET @CategoryInvestmentIncomeId = UUID_TO_BIN(UUID());
SET @CategoryRentId = UUID_TO_BIN(UUID());
SET @CategoryGroceriesId = UUID_TO_BIN(UUID());
SET @CategoryTransportId = UUID_TO_BIN(UUID());
SET @CategoryLeisureId = UUID_TO_BIN(UUID());
SET @CategoryUtilitiesId = UUID_TO_BIN(UUID());
SET @CategoryTransferId = UUID_TO_BIN(UUID());
SET @CategoryHealthId = UUID_TO_BIN(UUID());
SET @CategoryDiningId = UUID_TO_BIN(UUID());
SET @CategoryTravelId = UUID_TO_BIN(UUID());
SET @CategoryCreditId = UUID_TO_BIN(UUID());
SET @CategoryShoppingId = UUID_TO_BIN(UUID());

    -- Categorias usadas nos gráficos
    INSERT INTO categories (id, user_id, category_type, name, color, icon, active, created_at, updated_at)
    VALUES
        (@CategorySalaryId, @UserId, 'INCOME',  'Salario',              '#16A34A', 'mdi-briefcase',            1, @Now, @Now),
        (@CategorySideIncomeId, @UserId, 'INCOME',  'Servicos extras',      '#22C55E', 'mdi-cash-plus',           1, @Now, @Now),
        (@CategoryInvestmentIncomeId, @UserId, 'INCOME',  'Rendimentos',         '#0EA5E9', 'mdi-trending-up',         1, @Now, @Now),
        (@CategoryRentId, @UserId, 'EXPENSE', 'Moradia',              '#F97316', 'mdi-home-city',           1, @Now, @Now),
        (@CategoryGroceriesId, @UserId, 'EXPENSE', 'Mercado',              '#EF4444', 'mdi-cart',                 1, @Now, @Now),
        (@CategoryTransportId, @UserId, 'EXPENSE', 'Transporte',           '#6366F1', 'mdi-bus',                  1, @Now, @Now),
        (@CategoryLeisureId, @UserId, 'EXPENSE', 'Lazer',                 '#A855F7', 'mdi-party-popper',        1, @Now, @Now),
        (@CategoryUtilitiesId, @UserId, 'EXPENSE', 'Servicos',             '#F59E0B', 'mdi-lightbulb-on-outline',1, @Now, @Now),
        (@CategoryTransferId, @UserId, 'TRANSFER','Transferencias',        '#6B7280', 'mdi-swap-horizontal',     1, @Now, @Now),
        (@CategoryHealthId, @UserId, 'EXPENSE', 'Saude',                 '#DC2626', 'mdi-heart-pulse',         1, @Now, @Now),
        (@CategoryDiningId, @UserId, 'EXPENSE', 'Restaurantes',          '#FB7185', 'mdi-silverware-fork-knife',1, @Now, @Now),
        (@CategoryTravelId, @UserId, 'EXPENSE', 'Viagens',               '#0EA5E9', 'mdi-airplane',             1, @Now, @Now),
        (@CategoryCreditId, @UserId, 'EXPENSE', 'Cartao de credito',     '#FACC15', 'mdi-credit-card',          1, @Now, @Now),
        (@CategoryShoppingId, @UserId, 'EXPENSE', 'Compras online',       '#EC4899', 'mdi-basket-outline',       1, @Now, @Now);

    -- Contas bancárias e cartão
    INSERT INTO bank_accounts (id, user_id, institution_name, branch_number, account_number, account_digit, account_type, nickname, current_balance, created_at, updated_at)
    VALUES
        (@CheckingAccountId, @UserId, 'Banco Aurora', '0001', '123456', '7', 'CHECKING',   'Conta principal',     9820.00, DATE_ADD(CAST(@Month5 AS DATETIME), INTERVAL 9 HOUR), @Now),
        (@SavingsAccountId,  @UserId, 'Banco Aurora', '0001', '789012', '2', 'SAVINGS',    'Poupanca familia',   14850.00, DATE_ADD(CAST(@Month5 AS DATETIME), INTERVAL 9 HOUR), @Now),
        (@CreditCardAccountId,@UserId, 'Banco Aurora', '0001', '555000', '9', 'CREDIT_CARD','Cartao platinum',   -4950.00, DATE_ADD(CAST(@Month5 AS DATETIME), INTERVAL 9 HOUR), @Now);

    -- Transações da conta corrente (últimos 6 meses)
    INSERT INTO transactions (id, bank_account_id, transaction_type, amount, transaction_date, description, category_id, notes, created_at, updated_at)
    VALUES
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       7500.00, DATE_ADD(@Month5, INTERVAL 0 DAY), 'Salario mensal',               @CategorySalaryId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      3000.00, DATE_ADD(@Month5, INTERVAL 2 DAY), 'Aluguel apartamento',          @CategoryRentId,           NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1050.00, DATE_ADD(@Month5, INTERVAL 4 DAY), 'Compras supermercado',         @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 4 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 4 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       320.00, DATE_ADD(@Month5, INTERVAL 7 DAY), 'Transporte urbano',            @CategoryTransportId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       240.00, DATE_ADD(@Month5, INTERVAL 11 DAY), 'Cinema com amigos',            @CategoryLeisureId,        NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 11 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 11 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       600.00, DATE_ADD(@Month5, INTERVAL 14 DAY), 'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 14 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 14 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_OUT',  700.00, DATE_ADD(@Month5, INTERVAL 20 DAY), 'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1000.00, DATE_ADD(@Month5, INTERVAL 25 DAY), 'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       7500.00, DATE_ADD(@Month4, INTERVAL 0 DAY), 'Salario mensal',               @CategorySalaryId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      3000.00, DATE_ADD(@Month4, INTERVAL 3 DAY), 'Aluguel apartamento',          @CategoryRentId,           NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1100.00, DATE_ADD(@Month4, INTERVAL 5 DAY), 'Compras supermercado',         @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       330.00, DATE_ADD(@Month4, INTERVAL 8 DAY), 'Combustivel e transporte',     @CategoryTransportId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 8 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 8 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       420.00, DATE_ADD(@Month4, INTERVAL 12 DAY), 'Lazer fim de semana',          @CategoryLeisureId,        NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       620.00, DATE_ADD(@Month4, INTERVAL 15 DAY), 'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 15 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 15 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_OUT',  850.00, DATE_ADD(@Month4, INTERVAL 18 DAY), 'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 18 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 18 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',        800.00, DATE_ADD(@Month4, INTERVAL 20 DAY), 'Projeto freelance',            @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1100.00, DATE_ADD(@Month4, INTERVAL 25 DAY), 'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       7500.00, DATE_ADD(@Month3, INTERVAL 0 DAY), 'Salario mensal',               @CategorySalaryId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       1500.00, DATE_ADD(@Month3, INTERVAL 2 DAY), 'Bonus trimestral',             @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      3000.00, DATE_ADD(@Month3, INTERVAL 3 DAY), 'Aluguel apartamento',          @CategoryRentId,           NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1180.00, DATE_ADD(@Month3, INTERVAL 6 DAY), 'Compras supermercado',         @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       360.00, DATE_ADD(@Month3, INTERVAL 9 DAY), 'Transporte urbano',            @CategoryTransportId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 9 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 9 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1200.00, DATE_ADD(@Month3, INTERVAL 12 DAY), 'Planejamento viagem',          @CategoryTravelId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       610.00, DATE_ADD(@Month3, INTERVAL 15 DAY), 'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 15 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 15 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_OUT', 1100.00, DATE_ADD(@Month3, INTERVAL 18 DAY), 'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 18 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 18 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1200.00, DATE_ADD(@Month3, INTERVAL 24 DAY), 'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 24 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 24 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       7500.00, DATE_ADD(@Month2, INTERVAL 0 DAY), 'Salario mensal',               @CategorySalaryId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       1100.00, DATE_ADD(@Month2, INTERVAL 4 DAY), 'Projeto consultoria',          @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 4 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 4 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',        150.00, DATE_ADD(@Month2, INTERVAL 6 DAY), 'Reembolso despesas',           @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      3100.00, DATE_ADD(@Month2, INTERVAL 2 DAY), 'Aluguel apartamento',          @CategoryRentId,           NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1220.00, DATE_ADD(@Month2, INTERVAL 7 DAY), 'Compras supermercado',         @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       380.00, DATE_ADD(@Month2, INTERVAL 10 DAY), 'Transporte urbano',            @CategoryTransportId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 10 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 10 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       480.00, DATE_ADD(@Month2, INTERVAL 13 DAY), 'Passeio cultural',             @CategoryLeisureId,        NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 13 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 13 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       620.00, DATE_ADD(@Month2, INTERVAL 16 DAY), 'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 16 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 16 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_OUT',  950.00, DATE_ADD(@Month2, INTERVAL 19 DAY), 'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 19 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 19 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1300.00, DATE_ADD(@Month2, INTERVAL 25 DAY), 'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       7500.00, DATE_ADD(@Month1, INTERVAL 0 DAY), 'Salario mensal',               @CategorySalaryId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',        900.00, DATE_ADD(@Month1, INTERVAL 5 DAY), 'Projeto freelance',            @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      3100.00, DATE_ADD(@Month1, INTERVAL 2 DAY), 'Aluguel apartamento',          @CategoryRentId,           NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1260.00, DATE_ADD(@Month1, INTERVAL 7 DAY), 'Compras supermercado',         @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       360.00, DATE_ADD(@Month1, INTERVAL 9 DAY), 'Transporte urbano',            @CategoryTransportId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 9 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 9 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       420.00, DATE_ADD(@Month1, INTERVAL 12 DAY), 'Lazer com familia',            @CategoryLeisureId,        NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       590.00, DATE_ADD(@Month1, INTERVAL 15 DAY), 'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 15 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 15 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_OUT',  950.00, DATE_ADD(@Month1, INTERVAL 18 DAY), 'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 18 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 18 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       450.00, DATE_ADD(@Month1, INTERVAL 21 DAY), 'Consulta medica',              @CategoryHealthId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 21 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 21 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1250.00, DATE_ADD(@Month1, INTERVAL 25 DAY), 'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',       7600.00, DATE_ADD(@Month0, INTERVAL 0 DAY), 'Salario mensal',               @CategorySalaryId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 0 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',        900.00, DATE_ADD(@Month0, INTERVAL 3 DAY), 'Projeto freelance',            @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'INCOME',        250.00, DATE_ADD(@Month0, INTERVAL 5 DAY), 'Reembolso despesas',           @CategorySideIncomeId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      3100.00, DATE_ADD(@Month0, INTERVAL 2 DAY), 'Aluguel apartamento',          @CategoryRentId,           NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 2 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       680.00, DATE_ADD(@Month0, INTERVAL 6 DAY), 'Compras supermercado',         @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       620.00, DATE_ADD(@Month0, INTERVAL 9 DAY), 'Reposicao despensa',           @CategoryGroceriesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 9 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 9 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       390.00, DATE_ADD(@Month0, INTERVAL 11 DAY), 'Transporte urbano',            @CategoryTransportId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 11 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 11 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       460.00, DATE_ADD(@Month0, INTERVAL 14 DAY), 'Lazer fim de semana',          @CategoryLeisureId,        NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 14 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 14 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       610.00, DATE_ADD(@Month0, INTERVAL 17 DAY), 'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 17 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 17 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'TRANSFER_OUT', 1000.00, DATE_ADD(@Month0, INTERVAL 19 DAY), 'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 19 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 19 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',       320.00, DATE_ADD(@Month0, INTERVAL 22 DAY), 'Restaurante com amigos',       @CategoryDiningId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 22 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 22 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CheckingAccountId, 'EXPENSE',      1400.00, DATE_ADD(@Month0, INTERVAL 25 DAY), 'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR));

    -- Transações da conta poupança
    INSERT INTO transactions (id, bank_account_id, transaction_type, amount, transaction_date, description, category_id, notes, created_at, updated_at)
    VALUES
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_I', 700.00, DATE_ADD(@Month5, INTERVAL 20 DAY), 'Transferencia recebida',      @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'INCOME',        15.00, DATE_ADD(@Month5, INTERVAL 27 DAY), 'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_I', 850.00, DATE_ADD(@Month4, INTERVAL 20 DAY), 'Transferencia recebida',      @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'INCOME',        18.00, DATE_ADD(@Month4, INTERVAL 27 DAY), 'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_I', 1100.00, DATE_ADD(@Month3, INTERVAL 20 DAY), 'Transferencia recebida',      @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'INCOME',        20.00, DATE_ADD(@Month3, INTERVAL 27 DAY), 'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_I',  950.00, DATE_ADD(@Month2, INTERVAL 20 DAY), 'Transferencia recebida',      @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 400.00, DATE_ADD(@Month2, INTERVAL 23 DAY), 'Resgate para emergencias',   @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 23 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 23 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'INCOME',        22.00, DATE_ADD(@Month2, INTERVAL 27 DAY), 'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_I',  950.00, DATE_ADD(@Month1, INTERVAL 20 DAY), 'Transferencia recebida',      @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'INCOME',        24.00, DATE_ADD(@Month1, INTERVAL 27 DAY), 'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_I', 1000.00, DATE_ADD(@Month0, INTERVAL 20 DAY), 'Transferencia recebida',      @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 20 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'TRANSFER_OUT', 500.00, DATE_ADD(@Month0, INTERVAL 22 DAY), 'Aporte em investimentos',     @CategoryTransferId,         NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 22 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 22 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @SavingsAccountId, 'INCOME',        25.00, DATE_ADD(@Month0, INTERVAL 27 DAY), 'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 27 DAY) AS DATETIME), INTERVAL 10 HOUR));

    -- Transações do cartão de crédito
    INSERT INTO transactions (id, bank_account_id, transaction_type, amount, transaction_date, description, category_id, notes, created_at, updated_at)
    VALUES
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     820.00, DATE_ADD(@Month5, INTERVAL 3 DAY), 'Compras online',             @CategoryShoppingId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 3 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     380.00, DATE_ADD(@Month5, INTERVAL 8 DAY), 'Jantar fora',                @CategoryDiningId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 8 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 8 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'TRANSFER_I',1000.00, DATE_ADD(@Month5, INTERVAL 25 DAY), 'Pagamento recebido',         @CategoryTransferId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month5, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     940.00, DATE_ADD(@Month4, INTERVAL 4 DAY), 'Itens para casa',            @CategoryShoppingId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 4 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 4 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     420.00, DATE_ADD(@Month4, INTERVAL 10 DAY), 'Passeio e lazer',            @CategoryLeisureId,    NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 10 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 10 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'TRANSFER_I',1100.00, DATE_ADD(@Month4, INTERVAL 25 DAY), 'Pagamento recebido',         @CategoryTransferId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month4, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',    1120.00, DATE_ADD(@Month3, INTERVAL 5 DAY), 'Reserva de hotel',           @CategoryTravelId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 5 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     460.00, DATE_ADD(@Month3, INTERVAL 11 DAY), 'Restaurante viagem',         @CategoryDiningId,     NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 11 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 11 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'TRANSFER_I',1200.00, DATE_ADD(@Month3, INTERVAL 24 DAY), 'Pagamento recebido',         @CategoryTransferId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 24 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month3, INTERVAL 24 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',    1180.00, DATE_ADD(@Month2, INTERVAL 6 DAY), 'Eletronicos',                @CategoryShoppingId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 6 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     520.00, DATE_ADD(@Month2, INTERVAL 12 DAY), 'Entretenimento',             @CategoryLeisureId,    NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 12 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'TRANSFER_I',1300.00, DATE_ADD(@Month2, INTERVAL 25 DAY), 'Pagamento recebido',         @CategoryTransferId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month2, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',    1100.00, DATE_ADD(@Month1, INTERVAL 7 DAY), 'Compras supermercado',        @CategoryGroceriesId,  NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 7 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     480.00, DATE_ADD(@Month1, INTERVAL 13 DAY), 'Cinema e lanches',            @CategoryLeisureId,    NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 13 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 13 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'TRANSFER_I',1250.00, DATE_ADD(@Month1, INTERVAL 25 DAY), 'Pagamento recebido',         @CategoryTransferId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month1, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',    1050.00, DATE_ADD(@Month0, INTERVAL 8 DAY), 'Assinaturas e servicos',      @CategoryUtilitiesId,  NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 8 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 8 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'EXPENSE',     530.00, DATE_ADD(@Month0, INTERVAL 13 DAY), 'Compras online',             @CategoryShoppingId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 13 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 13 DAY) AS DATETIME), INTERVAL 10 HOUR)),
        (UUID_TO_BIN(UUID()), @CreditCardAccountId, 'TRANSFER_I',1400.00, DATE_ADD(@Month0, INTERVAL 25 DAY), 'Pagamento recebido',         @CategoryTransferId,   NULL, DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR), DATE_ADD(CAST(DATE_ADD(@Month0, INTERVAL 25 DAY) AS DATETIME), INTERVAL 10 HOUR));

    -- Metas financeiras utilizadas nos gráficos
SET @GoalEmergencyId = UUID_TO_BIN(UUID());
SET @GoalTripId = UUID_TO_BIN(UUID());
SET @GoalLeisureId = UUID_TO_BIN(UUID());

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
         20000.00, 15000.00,
         DATE_ADD(@Month0, INTERVAL -8 MONTH), DATE_ADD(@Month0, INTERVAL 4 MONTH),
         'IN_PROGRESS', 'Construcao de reserva equivalente a seis meses de despesas.',
         1, 1, 1, NULL,
         DATE_ADD(CAST(@Month0 AS DATETIME), INTERVAL -8 MONTH), @Now),
        (@GoalTripId, @UserId, 'Viagem internacional', 'SAVINGS', @CategoryTravelId,
         8000.00, 8200.00,
         DATE_ADD(@Month0, INTERVAL -10 MONTH), DATE_ADD(@Month0, INTERVAL 2 MONTH),
         'ACHIEVED', 'Guardar recursos para viagem de ferias no exterior.',
         1, 1, 1, DATE_ADD(CAST(@Month0 AS DATETIME), INTERVAL -1 MONTH),
         DATE_ADD(CAST(@Month0 AS DATETIME), INTERVAL -10 MONTH), @Now),
        (@GoalLeisureId, @UserId, 'Limite de gastos com lazer', 'EXPENSE_LIMIT', @CategoryLeisureId,
         1000.00, 1250.00,
         DATE_ADD(@Month0, INTERVAL -2 MONTH), DATE_ADD(@Month0, INTERVAL 1 MONTH),
         'EXCEEDED', 'Manter despesas de lazer sob controle mensal.',
         1, 0, 1, NULL,
         DATE_ADD(CAST(@Month0 AS DATETIME), INTERVAL -2 MONTH), @Now);

COMMIT;

-- Visão rápida das inserções
SELECT ba.id,
       ba.nickname,
       ba.account_type,
       ba.current_balance,
       ba.created_at
FROM bank_accounts AS ba
WHERE ba.user_id = @UserId
ORDER BY ba.created_at;

SELECT t.bank_account_id,
       t.transaction_date,
       t.transaction_type,
       t.amount,
       t.description,
       t.category_id
FROM transactions AS t
WHERE t.bank_account_id IN (@CheckingAccountId, @SavingsAccountId, @CreditCardAccountId)
ORDER BY t.transaction_date, t.created_at;

SELECT fg.name,
       fg.goal_type,
       fg.goal_status,
       fg.target_amount,
       fg.current_amount,
       fg.start_date,
       fg.end_date
FROM financial_goals AS fg
WHERE fg.user_id = @UserId
ORDER BY fg.end_date;
