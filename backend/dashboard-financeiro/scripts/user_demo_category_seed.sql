/*
    Script para cadastrar categorias financeiras do usuário de demonstração.

    Execute após criar as contas bancárias. Ajuste @UserId se quiser reaproveitar
    para outro usuário.

    Execução sugerida:
        mysql -u root -p < backend/dashboard-financeiro/scripts/user_demo_category_seed.sql
*/

USE dashboard_financeiro;

SET @UserId = UUID_TO_BIN('9d329bc3-24ac-4cfa-81b0-1de71f4afa63'); -- Perfil Demonstração
SET @Now = UTC_TIMESTAMP(6);

/*
    Remova o comentário abaixo se precisar limpar categorias existentes
    antes de reaplicar o seed.
*/
-- DELETE FROM categories WHERE user_id = @UserId;

START TRANSACTION;

    /* Identificadores reutilizados nas etapas seguintes (transações, metas etc.) */
    SET @CategorySalaryId             = UUID_TO_BIN(UUID());
    SET @CategoryFreelanceId          = UUID_TO_BIN(UUID());
    SET @CategoryBonusId              = UUID_TO_BIN(UUID());
    SET @CategoryInvestmentIncomeId   = UUID_TO_BIN(UUID());
    SET @CategoryHousingId            = UUID_TO_BIN(UUID());
    SET @CategoryUtilitiesId          = UUID_TO_BIN(UUID());
    SET @CategoryGroceriesId          = UUID_TO_BIN(UUID());
    SET @CategoryTransportId          = UUID_TO_BIN(UUID());
    SET @CategoryDiningId             = UUID_TO_BIN(UUID());
    SET @CategoryHealthId             = UUID_TO_BIN(UUID());
    SET @CategoryLeisureId            = UUID_TO_BIN(UUID());
    SET @CategoryTravelId             = UUID_TO_BIN(UUID());
    SET @CategoryShoppingId           = UUID_TO_BIN(UUID());
    SET @CategoryEducationId          = UUID_TO_BIN(UUID());
    SET @CategoryInsuranceId          = UUID_TO_BIN(UUID());
    SET @CategorySubscriptionsId      = UUID_TO_BIN(UUID());
    SET @CategoryTransfersId          = UUID_TO_BIN(UUID());

    INSERT INTO categories (
        id,
        user_id,
        category_type,
        name,
        color,
        icon,
        active,
        created_at,
        updated_at
    )
    VALUES
        (@CategorySalaryId,            @UserId, 'INCOME',   'Salario',                '#16A34A', 'mdi-briefcase',             1, @Now, @Now),
        (@CategoryFreelanceId,         @UserId, 'INCOME',   'Consultorias e freelas', '#22C55E', 'mdi-laptop',                1, @Now, @Now),
        (@CategoryBonusId,             @UserId, 'INCOME',   'Bonus e variaveis',      '#4ADE80', 'mdi-cash-plus',             1, @Now, @Now),
        (@CategoryInvestmentIncomeId,  @UserId, 'INCOME',   'Rendimentos',            '#0EA5E9', 'mdi-trending-up',           1, @Now, @Now),
        (@CategoryHousingId,           @UserId, 'EXPENSE',  'Moradia',                '#F97316', 'mdi-home-city-outline',     1, @Now, @Now),
        (@CategoryUtilitiesId,         @UserId, 'EXPENSE',  'Servicos essenciais',    '#FBBF24', 'mdi-lightning-bolt',        1, @Now, @Now),
        (@CategoryGroceriesId,         @UserId, 'EXPENSE',  'Mercado',                '#EF4444', 'mdi-cart',                  1, @Now, @Now),
        (@CategoryTransportId,         @UserId, 'EXPENSE',  'Transporte',             '#6366F1', 'mdi-train-car',             1, @Now, @Now),
        (@CategoryDiningId,            @UserId, 'EXPENSE',  'Restaurantes',           '#FB7185', 'mdi-silverware-fork-knife', 1, @Now, @Now),
        (@CategoryHealthId,            @UserId, 'EXPENSE',  'Saude',                  '#DC2626', 'mdi-heart-pulse',           1, @Now, @Now),
        (@CategoryLeisureId,           @UserId, 'EXPENSE',  'Lazer e streaming',      '#A855F7', 'mdi-party-popper',          1, @Now, @Now),
        (@CategoryTravelId,            @UserId, 'EXPENSE',  'Viagens',                '#0EA5E9', 'mdi-airplane',              1, @Now, @Now),
        (@CategoryShoppingId,          @UserId, 'EXPENSE',  'Compras pessoais',       '#EC4899', 'mdi-basket-outline',        1, @Now, @Now),
        (@CategoryEducationId,         @UserId, 'EXPENSE',  'Educacao',               '#0891B2', 'mdi-school',                1, @Now, @Now),
        (@CategoryInsuranceId,         @UserId, 'EXPENSE',  'Seguros',                '#EA580C', 'mdi-shield-check',          1, @Now, @Now),
        (@CategorySubscriptionsId,     @UserId, 'EXPENSE',  'Assinaturas e apps',     '#94A3B8', 'mdi-monitor-cellphone',     1, @Now, @Now),
        (@CategoryTransfersId,         @UserId, 'TRANSFER', 'Transferencias',         '#6B7280', 'mdi-swap-horizontal',       1, @Now, @Now);

COMMIT;

/* Retorna os IDs para referência nas próximas seeds */
SELECT 'Salario' AS name, BIN_TO_UUID(@CategorySalaryId) AS category_id;
SELECT 'Consultorias e freelas' AS name, BIN_TO_UUID(@CategoryFreelanceId) AS category_id;
SELECT 'Bonus e variaveis' AS name, BIN_TO_UUID(@CategoryBonusId) AS category_id;
SELECT 'Rendimentos' AS name, BIN_TO_UUID(@CategoryInvestmentIncomeId) AS category_id;
SELECT 'Moradia' AS name, BIN_TO_UUID(@CategoryHousingId) AS category_id;
SELECT 'Servicos essenciais' AS name, BIN_TO_UUID(@CategoryUtilitiesId) AS category_id;
SELECT 'Mercado' AS name, BIN_TO_UUID(@CategoryGroceriesId) AS category_id;
SELECT 'Transporte' AS name, BIN_TO_UUID(@CategoryTransportId) AS category_id;
SELECT 'Restaurantes' AS name, BIN_TO_UUID(@CategoryDiningId) AS category_id;
SELECT 'Saude' AS name, BIN_TO_UUID(@CategoryHealthId) AS category_id;
SELECT 'Lazer e streaming' AS name, BIN_TO_UUID(@CategoryLeisureId) AS category_id;
SELECT 'Viagens' AS name, BIN_TO_UUID(@CategoryTravelId) AS category_id;
SELECT 'Compras pessoais' AS name, BIN_TO_UUID(@CategoryShoppingId) AS category_id;
SELECT 'Educacao' AS name, BIN_TO_UUID(@CategoryEducationId) AS category_id;
SELECT 'Seguros' AS name, BIN_TO_UUID(@CategoryInsuranceId) AS category_id;
SELECT 'Assinaturas e apps' AS name, BIN_TO_UUID(@CategorySubscriptionsId) AS category_id;
SELECT 'Transferencias' AS name, BIN_TO_UUID(@CategoryTransfersId) AS category_id;
