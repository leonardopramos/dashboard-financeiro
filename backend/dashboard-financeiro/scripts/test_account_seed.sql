/*
    Script de carga inicial para montar uma conta completa com dados suficientes
    para testar os gráficos do dashboard financeiro.

    ⚠️ Ajuste o valor de @UserId para o identificador do usuário que será usado nos testes,
    de acordo com o cadastro existente no serviço de autenticação.
*/

USE [dashboard_financeiro];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @UserId UNIQUEIDENTIFIER = TRY_CONVERT(UNIQUEIDENTIFIER, '311B8AF3-1790-4BA9-929D-A52172B81A17');
DECLARE @Now DATETIME2(0) = SYSUTCDATETIME();

IF @UserId IS NULL
BEGIN
    RAISERROR('Defina um identificador de usuário válido antes de executar o script.', 16, 1);
    RETURN;
END;

DECLARE @Month0 DATE = DATEFROMPARTS(YEAR(@Now), MONTH(@Now), 1); -- mês corrente
DECLARE @Month1 DATE = DATEADD(MONTH, -1, @Month0);
DECLARE @Month2 DATE = DATEADD(MONTH, -2, @Month0);
DECLARE @Month3 DATE = DATEADD(MONTH, -3, @Month0);
DECLARE @Month4 DATE = DATEADD(MONTH, -4, @Month0);
DECLARE @Month5 DATE = DATEADD(MONTH, -5, @Month0);

BEGIN TRANSACTION;

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
    DECLARE @CheckingAccountId UNIQUEIDENTIFIER = NEWID();
    DECLARE @SavingsAccountId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CreditCardAccountId UNIQUEIDENTIFIER = NEWID();

    DECLARE @CategorySalaryId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategorySideIncomeId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryInvestmentIncomeId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryRentId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryGroceriesId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryTransportId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryLeisureId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryUtilitiesId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryTransferId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryHealthId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryDiningId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryTravelId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryCreditId UNIQUEIDENTIFIER = NEWID();
    DECLARE @CategoryShoppingId UNIQUEIDENTIFIER = NEWID();

    -- Categorias usadas nos gráficos
    INSERT INTO categories (id, user_id, category_type, name, color, icon, active, created_at, updated_at)
    VALUES
        (@CategorySalaryId, @UserId, 'INCOME',  N'Salario',              '#16A34A', 'mdi-briefcase',            1, @Now, @Now),
        (@CategorySideIncomeId, @UserId, 'INCOME',  N'Servicos extras',      '#22C55E', 'mdi-cash-plus',           1, @Now, @Now),
        (@CategoryInvestmentIncomeId, @UserId, 'INCOME',  N'Rendimentos',         '#0EA5E9', 'mdi-trending-up',         1, @Now, @Now),
        (@CategoryRentId, @UserId, 'EXPENSE', N'Moradia',              '#F97316', 'mdi-home-city',           1, @Now, @Now),
        (@CategoryGroceriesId, @UserId, 'EXPENSE', N'Mercado',              '#EF4444', 'mdi-cart',                 1, @Now, @Now),
        (@CategoryTransportId, @UserId, 'EXPENSE', N'Transporte',           '#6366F1', 'mdi-bus',                  1, @Now, @Now),
        (@CategoryLeisureId, @UserId, 'EXPENSE', N'Lazer',                 '#A855F7', 'mdi-party-popper',        1, @Now, @Now),
        (@CategoryUtilitiesId, @UserId, 'EXPENSE', N'Servicos',             '#F59E0B', 'mdi-lightbulb-on-outline',1, @Now, @Now),
        (@CategoryTransferId, @UserId, 'TRANSFER',N'Transferencias',        '#6B7280', 'mdi-swap-horizontal',     1, @Now, @Now),
        (@CategoryHealthId, @UserId, 'EXPENSE', N'Saude',                 '#DC2626', 'mdi-heart-pulse',         1, @Now, @Now),
        (@CategoryDiningId, @UserId, 'EXPENSE', N'Restaurantes',          '#FB7185', 'mdi-silverware-fork-knife',1, @Now, @Now),
        (@CategoryTravelId, @UserId, 'EXPENSE', N'Viagens',               '#0EA5E9', 'mdi-airplane',             1, @Now, @Now),
        (@CategoryCreditId, @UserId, 'EXPENSE', N'Cartao de credito',     '#FACC15', 'mdi-credit-card',          1, @Now, @Now),
        (@CategoryShoppingId, @UserId, 'EXPENSE', N'Compras online',       '#EC4899', 'mdi-basket-outline',       1, @Now, @Now);

    -- Contas bancárias e cartão
    INSERT INTO bank_accounts (id, user_id, institution_name, branch_number, account_number, account_digit, account_type, nickname, current_balance, created_at, updated_at)
    VALUES
        (@CheckingAccountId, @UserId, N'Banco Aurora', '0001', '123456', '7', 'CHECKING',   N'Conta principal',     9820.00, DATEADD(HOUR, 9, CAST(@Month5 AS DATETIME2)), @Now),
        (@SavingsAccountId,  @UserId, N'Banco Aurora', '0001', '789012', '2', 'SAVINGS',    N'Poupanca familia',   14850.00, DATEADD(HOUR, 9, CAST(@Month5 AS DATETIME2)), @Now),
        (@CreditCardAccountId,@UserId, N'Banco Aurora', '0001', '555000', '9', 'CREDIT_CARD',N'Cartao platinum',   -4950.00, DATEADD(HOUR, 9, CAST(@Month5 AS DATETIME2)), @Now);

    -- Transações da conta corrente (últimos 6 meses)
    INSERT INTO transactions (id, bank_account_id, transaction_type, amount, transaction_date, description, category_id, notes, created_at, updated_at)
    VALUES
        (NEWID(), @CheckingAccountId, 'INCOME',       7500.00, DATEADD(DAY, 0,  @Month5), N'Salario mensal',               @CategorySalaryId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      3000.00, DATEADD(DAY, 2,  @Month5), N'Aluguel apartamento',          @CategoryRentId,           NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1050.00, DATEADD(DAY, 4,  @Month5), N'Compras supermercado',         @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4,  @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4,  @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       320.00, DATEADD(DAY, 7,  @Month5), N'Transporte urbano',            @CategoryTransportId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       240.00, DATEADD(DAY, 11, @Month5), N'Cinema com amigos',            @CategoryLeisureId,        NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 11, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 11, @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       600.00, DATEADD(DAY, 14, @Month5), N'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 14, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 14, @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'TRANSFER_OUT',  700.00, DATEADD(DAY, 20, @Month5), N'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1000.00, DATEADD(DAY, 25, @Month5), N'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month5) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       7500.00, DATEADD(DAY, 0,  @Month4), N'Salario mensal',               @CategorySalaryId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      3000.00, DATEADD(DAY, 3,  @Month4), N'Aluguel apartamento',          @CategoryRentId,           NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1100.00, DATEADD(DAY, 5,  @Month4), N'Compras supermercado',         @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       330.00, DATEADD(DAY, 8,  @Month4), N'Combustivel e transporte',     @CategoryTransportId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 8,  @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 8,  @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       420.00, DATEADD(DAY, 12, @Month4), N'Lazer fim de semana',          @CategoryLeisureId,        NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       620.00, DATEADD(DAY, 15, @Month4), N'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 15, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 15, @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'TRANSFER_OUT',  850.00, DATEADD(DAY, 18, @Month4), N'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 18, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 18, @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',        800.00, DATEADD(DAY, 20, @Month4), N'Projeto freelance',            @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1100.00, DATEADD(DAY, 25, @Month4), N'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month4) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       7500.00, DATEADD(DAY, 0,  @Month3), N'Salario mensal',               @CategorySalaryId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       1500.00, DATEADD(DAY, 2,  @Month3), N'Bonus trimestral',             @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      3000.00, DATEADD(DAY, 3,  @Month3), N'Aluguel apartamento',          @CategoryRentId,           NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1180.00, DATEADD(DAY, 6,  @Month3), N'Compras supermercado',         @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       360.00, DATEADD(DAY, 9,  @Month3), N'Transporte urbano',            @CategoryTransportId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 9,  @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 9,  @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1200.00, DATEADD(DAY, 12, @Month3), N'Planejamento viagem',          @CategoryTravelId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       610.00, DATEADD(DAY, 15, @Month3), N'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 15, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 15, @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'TRANSFER_OUT', 1100.00, DATEADD(DAY, 18, @Month3), N'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 18, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 18, @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1200.00, DATEADD(DAY, 24, @Month3), N'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 24, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 24, @Month3) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       7500.00, DATEADD(DAY, 0,  @Month2), N'Salario mensal',               @CategorySalaryId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       1100.00, DATEADD(DAY, 4,  @Month2), N'Projeto consultoria',          @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4,  @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4,  @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',        150.00, DATEADD(DAY, 6,  @Month2), N'Reembolso despesas',           @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      3100.00, DATEADD(DAY, 2,  @Month2), N'Aluguel apartamento',          @CategoryRentId,           NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1220.00, DATEADD(DAY, 7,  @Month2), N'Compras supermercado',         @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       380.00, DATEADD(DAY, 10, @Month2), N'Transporte urbano',            @CategoryTransportId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 10, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 10, @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       480.00, DATEADD(DAY, 13, @Month2), N'Passeio cultural',             @CategoryLeisureId,        NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 13, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 13, @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       620.00, DATEADD(DAY, 16, @Month2), N'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 16, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 16, @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'TRANSFER_OUT',  950.00, DATEADD(DAY, 19, @Month2), N'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 19, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 19, @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1300.00, DATEADD(DAY, 25, @Month2), N'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month2) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       7500.00, DATEADD(DAY, 0,  @Month1), N'Salario mensal',               @CategorySalaryId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',        900.00, DATEADD(DAY, 5,  @Month1), N'Projeto freelance',            @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      3100.00, DATEADD(DAY, 2,  @Month1), N'Aluguel apartamento',          @CategoryRentId,           NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1260.00, DATEADD(DAY, 7,  @Month1), N'Compras supermercado',         @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       360.00, DATEADD(DAY, 9,  @Month1), N'Transporte urbano',            @CategoryTransportId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 9,  @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 9,  @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       420.00, DATEADD(DAY, 12, @Month1), N'Lazer com familia',            @CategoryLeisureId,        NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       590.00, DATEADD(DAY, 15, @Month1), N'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 15, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 15, @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'TRANSFER_OUT',  950.00, DATEADD(DAY, 18, @Month1), N'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 18, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 18, @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       450.00, DATEADD(DAY, 21, @Month1), N'Consulta medica',              @CategoryHealthId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 21, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 21, @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1250.00, DATEADD(DAY, 25, @Month1), N'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month1) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',       7600.00, DATEADD(DAY, 0,  @Month0), N'Salario mensal',               @CategorySalaryId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 0,  @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',        900.00, DATEADD(DAY, 3,  @Month0), N'Projeto freelance',            @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'INCOME',        250.00, DATEADD(DAY, 5,  @Month0), N'Reembolso despesas',           @CategorySideIncomeId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      3100.00, DATEADD(DAY, 2,  @Month0), N'Aluguel apartamento',          @CategoryRentId,           NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 2,  @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       680.00, DATEADD(DAY, 6,  @Month0), N'Compras supermercado',         @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       620.00, DATEADD(DAY, 9,  @Month0), N'Reposicao despensa',           @CategoryGroceriesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 9,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 9,  @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       390.00, DATEADD(DAY, 11, @Month0), N'Transporte urbano',            @CategoryTransportId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 11, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 11, @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       460.00, DATEADD(DAY, 14, @Month0), N'Lazer fim de semana',          @CategoryLeisureId,        NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 14, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 14, @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       610.00, DATEADD(DAY, 17, @Month0), N'Contas de servicos',           @CategoryUtilitiesId,      NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 17, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 17, @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'TRANSFER_OUT', 1000.00, DATEADD(DAY, 19, @Month0), N'Transferencia para poupanca',  @CategoryTransferId,       NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 19, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 19, @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',       320.00, DATEADD(DAY, 22, @Month0), N'Restaurante com amigos',       @CategoryDiningId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 22, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 22, @Month0) AS DATETIME2))),
        (NEWID(), @CheckingAccountId, 'EXPENSE',      1400.00, DATEADD(DAY, 25, @Month0), N'Pagamento fatura cartao',      @CategoryCreditId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month0) AS DATETIME2)));

    -- Transações da conta poupança
    INSERT INTO transactions (id, bank_account_id, transaction_type, amount, transaction_date, description, category_id, notes, created_at, updated_at)
    VALUES
        (NEWID(), @SavingsAccountId, 'TRANSFER_IN', 700.00, DATEADD(DAY, 20, @Month5), N'Transferencia recebida',      @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month5) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'INCOME',        15.00, DATEADD(DAY, 27, @Month5), N'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month5) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_IN', 850.00, DATEADD(DAY, 20, @Month4), N'Transferencia recebida',      @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month4) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'INCOME',        18.00, DATEADD(DAY, 27, @Month4), N'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month4) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_IN', 1100.00, DATEADD(DAY, 20, @Month3), N'Transferencia recebida',      @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month3) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'INCOME',        20.00, DATEADD(DAY, 27, @Month3), N'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month3) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_IN',  950.00, DATEADD(DAY, 20, @Month2), N'Transferencia recebida',      @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month2) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_OUT', 400.00, DATEADD(DAY, 23, @Month2), N'Resgate para emergencias',   @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 23, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 23, @Month2) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'INCOME',        22.00, DATEADD(DAY, 27, @Month2), N'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month2) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_IN',  950.00, DATEADD(DAY, 20, @Month1), N'Transferencia recebida',      @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month1) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'INCOME',        24.00, DATEADD(DAY, 27, @Month1), N'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month1) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_IN', 1000.00, DATEADD(DAY, 20, @Month0), N'Transferencia recebida',      @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 20, @Month0) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'TRANSFER_OUT', 500.00, DATEADD(DAY, 22, @Month0), N'Aporte em investimentos',     @CategoryTransferId,         NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 22, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 22, @Month0) AS DATETIME2))),
        (NEWID(), @SavingsAccountId, 'INCOME',        25.00, DATEADD(DAY, 27, @Month0), N'Rendimento poupanca',        @CategoryInvestmentIncomeId, NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 27, @Month0) AS DATETIME2)));

    -- Transações do cartão de crédito
    INSERT INTO transactions (id, bank_account_id, transaction_type, amount, transaction_date, description, category_id, notes, created_at, updated_at)
    VALUES
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     820.00, DATEADD(DAY, 3,  @Month5), N'Compras online',             @CategoryShoppingId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 3,  @Month5) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     380.00, DATEADD(DAY, 8,  @Month5), N'Jantar fora',                @CategoryDiningId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 8,  @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 8,  @Month5) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'TRANSFER_IN',1000.00, DATEADD(DAY, 25, @Month5), N'Pagamento recebido',         @CategoryTransferId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month5) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month5) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     940.00, DATEADD(DAY, 4,  @Month4), N'Itens para casa',            @CategoryShoppingId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4,  @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 4,  @Month4) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     420.00, DATEADD(DAY, 10, @Month4), N'Passeio e lazer',            @CategoryLeisureId,    NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 10, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 10, @Month4) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'TRANSFER_IN',1100.00, DATEADD(DAY, 25, @Month4), N'Pagamento recebido',         @CategoryTransferId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month4) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month4) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',    1120.00, DATEADD(DAY, 5,  @Month3), N'Reserva de hotel',           @CategoryTravelId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 5,  @Month3) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     460.00, DATEADD(DAY, 11, @Month3), N'Restaurante viagem',         @CategoryDiningId,     NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 11, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 11, @Month3) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'TRANSFER_IN',1200.00, DATEADD(DAY, 24, @Month3), N'Pagamento recebido',         @CategoryTransferId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 24, @Month3) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 24, @Month3) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',    1180.00, DATEADD(DAY, 6,  @Month2), N'Eletronicos',                @CategoryShoppingId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 6,  @Month2) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     520.00, DATEADD(DAY, 12, @Month2), N'Entretenimento',             @CategoryLeisureId,    NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 12, @Month2) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'TRANSFER_IN',1300.00, DATEADD(DAY, 25, @Month2), N'Pagamento recebido',         @CategoryTransferId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month2) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month2) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',    1100.00, DATEADD(DAY, 7,  @Month1), N'Compras supermercado',        @CategoryGroceriesId,  NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 7,  @Month1) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     480.00, DATEADD(DAY, 13, @Month1), N'Cinema e lanches',            @CategoryLeisureId,    NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 13, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 13, @Month1) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'TRANSFER_IN',1250.00, DATEADD(DAY, 25, @Month1), N'Pagamento recebido',         @CategoryTransferId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month1) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month1) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',    1050.00, DATEADD(DAY, 8,  @Month0), N'Assinaturas e servicos',      @CategoryUtilitiesId,  NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 8,  @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 8,  @Month0) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'EXPENSE',     530.00, DATEADD(DAY, 13, @Month0), N'Compras online',             @CategoryShoppingId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 13, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 13, @Month0) AS DATETIME2))),
        (NEWID(), @CreditCardAccountId, 'TRANSFER_IN',1400.00, DATEADD(DAY, 25, @Month0), N'Pagamento recebido',         @CategoryTransferId,   NULL, DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month0) AS DATETIME2)), DATEADD(HOUR, 10, CAST(DATEADD(DAY, 25, @Month0) AS DATETIME2)));

    -- Metas financeiras utilizadas nos gráficos
    DECLARE @GoalEmergencyId UNIQUEIDENTIFIER = NEWID();
    DECLARE @GoalTripId UNIQUEIDENTIFIER = NEWID();
    DECLARE @GoalLeisureId UNIQUEIDENTIFIER = NEWID();

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
        (@GoalEmergencyId, @UserId, N'Reserva de emergencia', 'SAVINGS', NULL,
         20000.00, 15000.00,
         DATEADD(MONTH, -8, @Month0), DATEADD(MONTH, 4, @Month0),
         'IN_PROGRESS', N'Construcao de reserva equivalente a seis meses de despesas.',
         1, 1, 1, NULL,
         DATEADD(MONTH, -8, CAST(@Month0 AS DATETIME2)), @Now),
        (@GoalTripId, @UserId, N'Viagem internacional', 'SAVINGS', @CategoryTravelId,
         8000.00, 8200.00,
         DATEADD(MONTH, -10, @Month0), DATEADD(MONTH, 2, @Month0),
         'ACHIEVED', N'Guardar recursos para viagem de ferias no exterior.',
         1, 1, 1, DATEADD(MONTH, -1, CAST(@Month0 AS DATETIME2)),
         DATEADD(MONTH, -10, CAST(@Month0 AS DATETIME2)), @Now),
        (@GoalLeisureId, @UserId, N'Limite de gastos com lazer', 'EXPENSE_LIMIT', @CategoryLeisureId,
         1000.00, 1250.00,
         DATEADD(MONTH, -2, @Month0), DATEADD(MONTH, 1, @Month0),
         'EXCEEDED', N'Manter despesas de lazer sob controle mensal.',
         1, 0, 1, NULL,
         DATEADD(MONTH, -2, CAST(@Month0 AS DATETIME2)), @Now);

COMMIT TRANSACTION;

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
